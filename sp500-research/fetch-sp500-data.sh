#!/usr/bin/env bash
# fetch-sp500-data.sh - Fetches current S&P 500 data via Yahoo Finance (yfinance)
# Output: sp500-data.json

set -euo pipefail

OUTPUT_FILE="$(dirname "$0")/sp500-data.json"

echo "Checking Python dependencies..."
python3 -c "import yfinance" 2>/dev/null || {
    echo "Installing yfinance..."
    pip3 install yfinance --quiet
}

echo "Fetching S&P 500 data from Yahoo Finance..."

python3 - "$OUTPUT_FILE" << 'PYEOF'
import json
import sys
import yfinance as yf
from datetime import datetime, timedelta, date

output_file = sys.argv[1]
today = date.today()

def calc_perf(hist, start_date):
    """Return % change from start_date to latest close."""
    sub = hist[hist.index.normalize().date >= start_date]
    if sub.empty:
        return None
    return round(((hist["Close"].iloc[-1] - sub["Close"].iloc[0]) / sub["Close"].iloc[0]) * 100, 2)

# ── 1. S&P 500 current price & daily change ────────────────────────────────
print("  [1/4] Fetching S&P 500 index data...", flush=True)
sp500 = yf.Ticker("^GSPC")
hist_2d = sp500.history(period="2d")
hist_1y = sp500.history(period="1y")

cur_price   = round(float(hist_2d["Close"].iloc[-1]), 2)
prev_close  = round(float(hist_2d["Close"].iloc[-2]), 2) if len(hist_2d) >= 2 else cur_price
day_chg     = round(cur_price - prev_close, 2)
day_chg_pct = round((day_chg / prev_close) * 100, 2)

result = {
    "timestamp": datetime.now().isoformat(),
    "data_date": today.isoformat(),
    "source": "Yahoo Finance (yfinance)",
    "index": {
        "name": "S&P 500",
        "ticker": "^GSPC",
        "current_price": cur_price,
        "previous_close": prev_close,
        "daily_change": day_chg,
        "daily_change_pct": day_chg_pct,
        "open":   round(float(hist_2d["Open"].iloc[-1]), 2),
        "high":   round(float(hist_2d["High"].iloc[-1]), 2),
        "low":    round(float(hist_2d["Low"].iloc[-1]),  2),
        "volume": int(hist_2d["Volume"].iloc[-1]),
    }
}

# ── 2. Performance metrics ─────────────────────────────────────────────────
print("  [2/4] Computing performance metrics...", flush=True)
ytd_start         = date(today.year, 1, 1)
week_ago          = today - timedelta(days=7)
month_ago         = today - timedelta(days=30)
three_months_ago  = today - timedelta(days=90)
one_year_ago      = today - timedelta(days=365)

result["performance"] = {
    "1W":  calc_perf(hist_1y, week_ago),
    "1M":  calc_perf(hist_1y, month_ago),
    "3M":  calc_perf(hist_1y, three_months_ago),
    "YTD": calc_perf(hist_1y, ytd_start),
    "1Y":  calc_perf(hist_1y, one_year_ago),
}

# ── 3. Top 10 Holdings (via SPY ETF) ──────────────────────────────────────
print("  [3/4] Fetching SPY top 10 holdings...", flush=True)
try:
    spy = yf.Ticker("SPY")
    funds_data = spy.funds_data
    top = funds_data.top_holdings          # DataFrame indexed by ticker symbol
    holdings = []
    for sym, row in top.head(10).iterrows():
        holdings.append({
            "symbol":     sym,
            "name":       str(row.get("holdingName", "")),
            "weight_pct": round(float(row.get("holdingPercent", 0)) * 100, 2),
        })
    result["top_10_holdings"] = holdings
except Exception as exc:
    result["top_10_holdings"] = {"error": str(exc)}

# ── 4. Sector breakdown (SPDR sector ETFs) ────────────────────────────────
print("  [4/4] Fetching sector breakdown...", flush=True)
SECTOR_ETFS = {
    "Technology":             "XLK",
    "Health Care":            "XLV",
    "Financials":             "XLF",
    "Consumer Discretionary": "XLY",
    "Communication Services": "XLC",
    "Industrials":            "XLI",
    "Consumer Staples":       "XLP",
    "Energy":                 "XLE",
    "Utilities":              "XLU",
    "Real Estate":            "XLRE",
    "Materials":              "XLB",
}

sectors = {}
for sector_name, etf_sym in SECTOR_ETFS.items():
    try:
        etf      = yf.Ticker(etf_sym)
        h2d      = etf.history(period="2d")
        h1y      = etf.history(period="1y")
        cur      = round(float(h2d["Close"].iloc[-1]), 2)
        prev     = round(float(h2d["Close"].iloc[-2]), 2) if len(h2d) >= 2 else cur
        d_pct    = round(((cur - prev) / prev) * 100, 2)
        sectors[sector_name] = {
            "etf":              etf_sym,
            "current_price":    cur,
            "daily_change_pct": d_pct,
            "1M":               calc_perf(h1y, month_ago),
            "3M":               calc_perf(h1y, three_months_ago),
            "YTD":              calc_perf(h1y, ytd_start),
            "1Y":               calc_perf(h1y, one_year_ago),
        }
    except Exception as exc:
        sectors[sector_name] = {"etf": etf_sym, "error": str(exc)}

result["sector_breakdown"] = sectors

# ── Write output ───────────────────────────────────────────────────────────
with open(output_file, "w") as fh:
    json.dump(result, fh, indent=2)

print(f"\nData saved to: {output_file}")

# Pretty-print summary
idx = result["index"]
print(f"\n{'='*50}")
print(f"  S&P 500 Summary  ({result['data_date']})")
print(f"{'='*50}")
print(f"  Price:       {idx['current_price']:>10,.2f}")
print(f"  Daily Chg:   {idx['daily_change']:>+10.2f}  ({idx['daily_change_pct']:>+.2f}%)")
print(f"{'─'*50}")
print(f"  Performance:")
for period, val in result["performance"].items():
    pct_str = f"{val:>+.2f}%" if val is not None else "N/A"
    print(f"    {period:<6}  {pct_str:>8}")
print(f"{'─'*50}")
print(f"  Top 10 Holdings (SPY):")
if isinstance(result["top_10_holdings"], list):
    for h in result["top_10_holdings"]:
        print(f"    {h['symbol']:<6}  {h['name']:<30}  {h['weight_pct']:>5.2f}%")
print(f"{'─'*50}")
print(f"  Sector Performance (YTD):")
for s, d in result["sector_breakdown"].items():
    if "error" not in d:
        ytd = d.get("YTD")
        ytd_str = f"{ytd:>+.2f}%" if ytd is not None else "N/A"
        print(f"    {d['etf']:<5}  {s:<25}  {ytd_str:>8}")
print(f"{'='*50}")
PYEOF

echo ""
echo "Done. Output written to: $OUTPUT_FILE"
