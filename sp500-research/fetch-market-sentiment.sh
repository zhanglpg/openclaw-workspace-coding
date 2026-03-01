#!/usr/bin/env bash
# fetch-market-sentiment.sh - Fetches S&P 500 market sentiment indicators
# Sources:
#   - VIX: Yahoo Finance (unofficial chart API, no key required)
#   - Put/Call Ratio: CBOE public data (multiple fallback endpoints)
#   - Sentiment: CNN Fear & Greed Index + AAII weekly survey
#   - News Headlines: Yahoo Finance RSS, MarketWatch RSS, Reuters RSS, AP RSS
# Output: market-sentiment.json

set -euo pipefail

OUTPUT_FILE="$(dirname "$0")/market-sentiment.json"

echo "Checking Python dependencies..."
python3 -c "import requests" 2>/dev/null || pip3 install requests --quiet
python3 -c "import feedparser" 2>/dev/null || pip3 install feedparser --quiet

echo "Fetching S&P 500 market sentiment data..."

python3 - "$OUTPUT_FILE" << 'PYEOF'
import json, sys, re, calendar, time as _time
from datetime import datetime, date, timedelta, timezone
import requests

try:
    import feedparser
    HAS_FEEDPARSER = True
except ImportError:
    import xml.etree.ElementTree as ET
    HAS_FEEDPARSER = False

output_file = sys.argv[1]
today = date.today()
cutoff_dt = datetime.now(timezone.utc) - timedelta(days=7)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json, text/html, */*",
}

def interpret_vix(v):
    if v < 12:  return "Extreme low / complacency"
    if v < 15:  return "Low volatility / calm market"
    if v < 20:  return "Normal volatility"
    if v < 25:  return "Elevated volatility / mild concern"
    if v < 30:  return "High volatility / fear"
    if v < 40:  return "Very high volatility / significant fear"
    return              "Extreme volatility / panic"

def interpret_pc(v):
    if v < 0.6:  return "Very bullish (excessive call buying)"
    if v < 0.75: return "Bullish"
    if v < 0.90: return "Neutral-bullish"
    if v < 1.05: return "Neutral-bearish"
    if v < 1.20: return "Bearish"
    return               "Very bearish (excessive put buying / panic hedging)"

result = {
    "timestamp": datetime.now().isoformat(),
    "data_date": today.isoformat(),
    "period": "last_7_days",
    "vix": {},
    "put_call_ratio": {},
    "sentiment": {},
    "news_headlines": [],
    "sources": [],
    "errors": [],
}

W = 62

# ── 1. VIX via Yahoo Finance ──────────────────────────────────────────────
print("\n[1/4] Fetching VIX (^VIX) from Yahoo Finance...", flush=True)
try:
    resp = requests.get(
        "https://query1.finance.yahoo.com/v8/finance/chart/%5EVIX",
        params={"interval": "1d", "range": "5d"},
        headers=HEADERS, timeout=20,
    )
    resp.raise_for_status()
    data = resp.json()
    meta = data["chart"]["result"][0]["meta"]
    vix_now  = round(float(meta["regularMarketPrice"]), 2)
    vix_prev = round(float(meta["previousClose"]), 2)
    ts = meta.get("regularMarketTime")
    result["vix"] = {
        "current":        vix_now,
        "previous_close": vix_prev,
        "change":         round(vix_now - vix_prev, 2),
        "change_pct":     round((vix_now - vix_prev) / vix_prev * 100, 2),
        "interpretation": interpret_vix(vix_now),
        "note":           "VIX > 20 = elevated fear; VIX > 30 = high anxiety",
        "source":         "Yahoo Finance",
        "as_of":          datetime.fromtimestamp(ts).isoformat() if ts else None,
    }
    result["sources"].append("Yahoo Finance (^VIX)")
    print(f"  VIX: {vix_now:.2f}  ({result['vix']['interpretation']})")
except Exception as e:
    result["vix"] = {"error": str(e)}
    result["errors"].append(f"VIX: {e}")
    print(f"  ERROR: {e}")

# ── 2. Put/Call Ratio via CBOE ────────────────────────────────────────────
print("\n[2/4] Fetching Put/Call Ratio from CBOE...", flush=True)
pc_fetched = False

# Attempt A: CBOE CDN delayed-quote JSON (multiple ticker aliases)
for ticker in ("_PCALL", "_PC", "_PCTOTAL", "_PCINDEX", "_PCEQUITY"):
    if pc_fetched:
        break
    try:
        url = f"https://cdn.cboe.com/api/global/delayed_quotes/charts/historical/{ticker}.json"
        resp = requests.get(url, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        data = resp.json()
        rows = data.get("data", [])
        if not rows:
            continue
        last = rows[-1]
        if isinstance(last, dict):
            pc_val  = last.get("close") or last.get("value") or last.get("close_price")
            pc_date = last.get("date", "")
        elif isinstance(last, (list, tuple)):
            # format: [unix_ts, open, high, low, close]
            pc_val  = last[-1]
            pc_date = datetime.utcfromtimestamp(last[0]/1000).strftime("%Y-%m-%d") if last[0] > 1e9 else str(last[0])
        else:
            continue
        if pc_val is None:
            continue
        pc_val = round(float(pc_val), 2)
        result["put_call_ratio"] = {
            "value":          pc_val,
            "date":           pc_date,
            "type":           ticker.lstrip("_"),
            "interpretation": interpret_pc(pc_val),
            "note":           "Total P/C < 0.80 = bullish; > 1.10 = bearish",
            "source":         f"CBOE ({ticker})",
        }
        result["sources"].append(f"CBOE ({ticker})")
        print(f"  Put/Call ({ticker}): {pc_val:.2f}  ({result['put_call_ratio']['interpretation']})")
        pc_fetched = True
    except Exception:
        pass

# Attempt B: CBOE legacy CSV (datahouse)
if not pc_fetched:
    for csv_name in ("totalpc", "equitypc", "indexpc"):
        try:
            url = f"https://www.cboe.com/publish/ScheduledTask/MktData/datahouse/{csv_name}.csv"
            resp = requests.get(url, headers=HEADERS, timeout=20)
            resp.raise_for_status()
            lines = [l.strip() for l in resp.text.strip().splitlines()
                     if l.strip() and not l.upper().startswith("DATE")]
            if not lines:
                continue
            parts = lines[-1].split(",")
            if len(parts) < 2:
                continue
            pc_date = parts[0].strip()
            pc_val  = round(float(parts[1].strip()), 2)
            result["put_call_ratio"] = {
                "value":          pc_val,
                "date":           pc_date,
                "type":           csv_name.upper(),
                "interpretation": interpret_pc(pc_val),
                "note":           "Total P/C < 0.80 = bullish; > 1.10 = bearish",
                "source":         f"CBOE ({csv_name}.csv)",
            }
            result["sources"].append(f"CBOE ({csv_name}.csv)")
            print(f"  Put/Call ({csv_name}): {pc_val:.2f}  ({result['put_call_ratio']['interpretation']})")
            pc_fetched = True
            break
        except Exception:
            pass

if not pc_fetched:
    result["put_call_ratio"] = {
        "error":  "Could not fetch — CBOE endpoints may have changed or require authentication",
        "status": "unavailable",
        "manual": "Check https://www.cboe.com/us/options/market_statistics/daily/",
    }
    result["errors"].append("Put/Call Ratio: unavailable from free CBOE endpoints")
    print("  Put/Call Ratio: unavailable (all CBOE endpoints failed)")

# ── 3. Sentiment Indicators ───────────────────────────────────────────────
print("\n[3/4] Fetching sentiment indicators...", flush=True)
result["sentiment"] = {}

# 3a. CNN Fear & Greed Index
try:
    resp = requests.get(
        "https://production.dataviz.cnn.io/index/fearandgreed/graphdata/",
        headers=HEADERS, timeout=20,
    )
    resp.raise_for_status()
    data  = resp.json()
    fg    = data.get("fear_and_greed", {})
    score = round(float(fg.get("score", 0)), 1)
    rating = fg.get("rating", "").replace("_", " ").title()
    prev_close = fg.get("previous_close")
    result["sentiment"]["cnn_fear_greed"] = {
        "score":          score,
        "rating":         rating,
        "previous_close": round(float(prev_close), 1) if prev_close else None,
        "change":         round(score - float(prev_close), 1) if prev_close else None,
        "interpretation": f"{rating} ({score}/100)",
        "scale":          "0=Extreme Fear | 25=Fear | 50=Neutral | 75=Greed | 100=Extreme Greed",
        "source":         "CNN Fear & Greed Index",
    }
    result["sources"].append("CNN Fear & Greed Index")
    print(f"  CNN Fear & Greed: {score:.1f} / 100  ({rating})")
except Exception as e:
    result["sentiment"]["cnn_fear_greed"] = {"error": str(e)}
    result["errors"].append(f"CNN Fear & Greed: {e}")
    print(f"  CNN Fear & Greed ERROR: {e}")

# 3b. AAII Investor Sentiment Survey (weekly)
try:
    resp = requests.get(
        "https://www.aaii.com/sentimentsurvey/sent_results",
        headers={**HEADERS, "Accept": "text/csv, text/plain, */*"},
        timeout=20,
    )
    resp.raise_for_status()
    lines = [l for l in resp.text.strip().splitlines() if l.strip()]
    # First non-empty line is the header
    header = [h.strip().lower().replace(" ", "_").replace("-", "_").replace("/", "_")
              for h in lines[0].split(",")]
    last   = lines[-1].split(",")
    row    = {header[i]: last[i].strip() for i in range(min(len(header), len(last)))}

    def to_pct(v):
        f = float(v)
        return round(f * 100 if f <= 1.0 else f, 1)

    bullish = to_pct(row.get("bullish", "0"))
    neutral = to_pct(row.get("neutral", "0"))
    bearish = to_pct(row.get("bearish", "0"))
    spread  = round(bullish - bearish, 1)
    result["sentiment"]["aaii_survey"] = {
        "survey_date":      row.get("date", ""),
        "bullish_pct":      bullish,
        "neutral_pct":      neutral,
        "bearish_pct":      bearish,
        "bull_bear_spread": spread,
        "interpretation":   f"Bull {bullish}% | Neut {neutral}% | Bear {bearish}%  (spread {spread:+.1f}%)",
        "historical_avg":   "Bullish 37.5% | Neutral 31.5% | Bearish 31.0%",
        "note":             "Contrarian indicator: extreme bearishness can signal buying opportunities",
        "source":           "AAII Investor Sentiment Survey",
    }
    result["sources"].append("AAII Investor Sentiment Survey")
    print(f"  AAII: Bull {bullish}% | Neut {neutral}% | Bear {bearish}%  (spread {spread:+.1f}%)")
except Exception as e:
    result["sentiment"]["aaii_survey"] = {
        "error": str(e),
        "note":  "Free access may be limited; check https://www.aaii.com/sentimentsurvey",
    }
    result["errors"].append(f"AAII Sentiment: {e}")
    print(f"  AAII Sentiment ERROR: {e}")

# ── 4. News Headlines via RSS ─────────────────────────────────────────────
print("\n[4/4] Fetching recent S&P 500 news headlines (last 7 days)...", flush=True)

RSS_FEEDS = [
    ("Yahoo Finance – S&P 500",
     "https://feeds.finance.yahoo.com/rss/2.0/headline?s=%5EGSPC&region=US&lang=en-US"),
    ("MarketWatch Top Stories",
     "https://feeds.content.dowjones.io/public/rss/mw_topstories"),
    ("Reuters Business",
     "https://feeds.reuters.com/reuters/businessNews"),
    ("AP Finance",
     "https://feeds.apnews.com/rss/APfinance"),
]

SP500_KW = {
    "s&p", "sp500", "spx", "stock market", "wall street",
    "dow jones", "nasdaq", "fed", "federal reserve",
    "interest rate", "inflation", "recession", "earnings",
    "market rally", "sell-off", "selloff", "tariff", "equities",
    "bull market", "bear market", "rate cut", "rate hike",
}

def parse_dt_from_entry(entry):
    """Return a UTC-aware datetime from a feedparser entry, or None."""
    tp = entry.get("published_parsed") or entry.get("updated_parsed")
    if tp:
        try:
            return datetime(tp.tm_year, tp.tm_mon, tp.tm_mday,
                            tp.tm_hour, tp.tm_min, tp.tm_sec,
                            tzinfo=timezone.utc)
        except Exception:
            pass
    raw = entry.get("published", "") or entry.get("updated", "")
    if raw:
        try:
            from email.utils import parsedate_to_datetime
            return parsedate_to_datetime(raw)
        except Exception:
            pass
    return None

def parse_dt_from_xml_item(item):
    """Return UTC-aware datetime from an xml.etree item's <pubDate>."""
    el = item.find("pubDate")
    if el is None or not el.text:
        return None
    try:
        from email.utils import parsedate_to_datetime
        return parsedate_to_datetime(el.text.strip())
    except Exception:
        return None

def text_of(item, tag):
    el = item.find(tag)
    return (el.text or "").strip() if el is not None else ""

headlines = []

for feed_name, feed_url in RSS_FEEDS:
    feed_count = 0
    try:
        if HAS_FEEDPARSER:
            feed    = feedparser.parse(feed_url)
            entries = feed.get("entries", [])
            for entry in entries:
                title   = (entry.get("title") or "").strip()
                link    = (entry.get("link")  or "").strip()
                summary = (entry.get("summary") or entry.get("description") or "").strip()
                pub_dt  = parse_dt_from_entry(entry)

                if pub_dt and pub_dt < cutoff_dt:
                    continue  # older than 7 days

                combined = (title + " " + summary).lower()
                is_yahoo = "Yahoo Finance" in feed_name
                if not is_yahoo and not any(kw in combined for kw in SP500_KW):
                    continue

                headlines.append({
                    "title":     title,
                    "source":    feed_name,
                    "published": pub_dt.isoformat() if pub_dt else "",
                    "url":       link,
                })
                feed_count += 1
                if feed_count >= 15:
                    break
        else:
            resp = requests.get(feed_url, headers=HEADERS, timeout=20)
            resp.raise_for_status()
            root  = ET.fromstring(resp.content)
            items = root.findall(".//item")
            for item in items:
                title   = text_of(item, "title")
                link    = text_of(item, "link")
                summary = text_of(item, "description")
                pub_dt  = parse_dt_from_xml_item(item)

                if pub_dt and pub_dt < cutoff_dt:
                    continue

                combined = (title + " " + summary).lower()
                is_yahoo = "Yahoo Finance" in feed_name
                if not is_yahoo and not any(kw in combined for kw in SP500_KW):
                    continue

                headlines.append({
                    "title":     title,
                    "source":    feed_name,
                    "published": pub_dt.isoformat() if pub_dt else "",
                    "url":       link,
                })
                feed_count += 1
                if feed_count >= 15:
                    break

        print(f"  {feed_name}: {feed_count} relevant articles")
    except Exception as e:
        result["errors"].append(f"News ({feed_name}): {e}")
        print(f"  {feed_name} ERROR: {e}")

headlines.sort(key=lambda x: x.get("published", ""), reverse=True)
result["news_headlines"] = headlines[:30]
print(f"  Total headlines collected: {len(result['news_headlines'])}")

# ── Derive overall market mood ─────────────────────────────────────────────
mood_signals = []
vix_val = result["vix"].get("current")
if vix_val:
    if   vix_val < 15: mood_signals.append("low_volatility")
    elif vix_val < 20: mood_signals.append("calm")
    elif vix_val < 25: mood_signals.append("cautious")
    elif vix_val < 30: mood_signals.append("fearful")
    else:              mood_signals.append("panic")

fg_score = result["sentiment"].get("cnn_fear_greed", {}).get("score")
fg_rating = result["sentiment"].get("cnn_fear_greed", {}).get("rating")
if fg_score is not None:
    if   fg_score < 25: mood_signals.append("extreme_fear")
    elif fg_score < 45: mood_signals.append("fear")
    elif fg_score < 55: mood_signals.append("neutral")
    elif fg_score < 75: mood_signals.append("greed")
    else:               mood_signals.append("extreme_greed")

result["market_mood_summary"] = {
    "signals":           mood_signals,
    "vix":               vix_val,
    "fear_greed_score":  fg_score,
    "fear_greed_rating": fg_rating,
}

# ── Write JSON ─────────────────────────────────────────────────────────────
with open(output_file, "w") as fh:
    json.dump(result, fh, indent=2)

# ── Print summary ──────────────────────────────────────────────────────────
print(f"\n{'='*W}")
print(f"  S&P 500 Market Sentiment Summary  ({result['data_date']})")
print(f"{'='*W}")

vix = result["vix"]
if "current" in vix:
    chg = f"({vix['change']:+.2f})"
    print(f"  VIX (Fear Index)      {vix['current']:>7.2f}  {chg:<10}  {vix['interpretation']}")
else:
    print(f"  VIX                   ERROR: {vix.get('error','?')[:42]}")

pc = result["put_call_ratio"]
if "value" in pc:
    print(f"  Put/Call Ratio        {pc['value']:>7.2f}  ({pc['type']:<8})  {pc['interpretation']}")
else:
    print(f"  Put/Call Ratio        unavailable")

fg = result["sentiment"].get("cnn_fear_greed", {})
if "score" in fg:
    chg = f"({fg['change']:+.1f})" if fg.get("change") is not None else ""
    print(f"  CNN Fear & Greed      {fg['score']:>7.1f}  {chg:<10}  {fg['rating']}")
else:
    print(f"  CNN Fear & Greed      ERROR: {fg.get('error','?')[:42]}")

aaii = result["sentiment"].get("aaii_survey", {})
if "bullish_pct" in aaii:
    print(f"  AAII Sentiment        Bull:{aaii['bullish_pct']:.0f}%  Neut:{aaii['neutral_pct']:.0f}%  Bear:{aaii['bearish_pct']:.0f}%"
          f"  (spread {aaii['bull_bear_spread']:+.1f}%)")
else:
    print(f"  AAII Sentiment        ERROR/unavailable")

print(f"  Headlines collected   {len(result['news_headlines']):>7d}")
print(f"  Mood signals          {', '.join(mood_signals) if mood_signals else 'n/a'}")
print(f"{'='*W}")

if result["errors"]:
    print(f"\n  Warnings ({len(result['errors'])}):")
    for e in result["errors"]:
        print(f"    - {e}")

print(f"\nData saved to: {output_file}")
PYEOF

echo ""
echo "Done. Output written to: $OUTPUT_FILE"
