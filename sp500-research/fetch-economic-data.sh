#!/usr/bin/env bash
# fetch-economic-data.sh - Fetches US economic indicators from FRED (no API key needed)
# Indicators: Fed Funds Rate, CPI Inflation, Unemployment, GDP Growth, Consumer Confidence
# Output: economic-data.json

set -euo pipefail

OUTPUT_FILE="$(dirname "$0")/economic-data.json"

echo "Checking Python dependencies..."
python3 -c "import requests, pandas" 2>/dev/null || {
    echo "Installing dependencies..."
    pip3 install requests pandas --quiet
}

echo "Fetching US economic indicators from FRED..."

python3 - "$OUTPUT_FILE" << 'PYEOF'
import json
import sys
import io
import requests
import pandas as pd
from datetime import datetime, date

output_file = sys.argv[1]
today = date.today()

# FRED public CSV download endpoint — no API key required
FRED_CSV = "https://fred.stlouisfed.org/graph/fredgraph.csv"
HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; economic-data-fetcher/1.0)"}

def fetch_fred(series_id, label):
    """Fetch a FRED series as a clean DataFrame (DATE, VALUE)."""
    print(f"  [{label}] Fetching {series_id}...", flush=True)
    resp = requests.get(FRED_CSV, params={"id": series_id}, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    df = pd.read_csv(io.StringIO(resp.text))
    df.columns = [c.strip().lstrip('\ufeff') for c in df.columns]
    df.columns = ["date", "value"]
    df["date"] = pd.to_datetime(df["date"])
    df = df[df["value"] != "."].copy()
    df["value"] = pd.to_numeric(df["value"])
    return df.dropna().reset_index(drop=True)

result = {
    "timestamp": datetime.now().isoformat(),
    "data_date": today.isoformat(),
    "source": "Federal Reserve Bank of St. Louis (FRED)",
    "source_url": "https://fred.stlouisfed.org",
    "indicators": {}
}

# ── 1. Federal Funds Rate ──────────────────────────────────────────────────
try:
    df = fetch_fred("FEDFUNDS", "1/5")
    latest, prev = df.iloc[-1], df.iloc[-2]
    result["indicators"]["federal_funds_rate"] = {
        "name": "Federal Funds Rate",
        "value": round(float(latest["value"]), 2),
        "unit": "%",
        "period": str(latest["date"].date()),
        "previous_period": str(prev["date"].date()),
        "previous_value": round(float(prev["value"]), 2),
        "change": round(float(latest["value"]) - float(prev["value"]), 2),
        "frequency": "monthly",
        "series_id": "FEDFUNDS",
    }
except Exception as e:
    result["indicators"]["federal_funds_rate"] = {"error": str(e)}

# ── 2. CPI Inflation (YoY & MoM) ──────────────────────────────────────────
try:
    df = fetch_fred("CPIAUCSL", "2/5")
    latest = df.iloc[-1]
    prev   = df.iloc[-2]
    # YoY: find the row closest to 12 months ago
    target_yoy = latest["date"] - pd.DateOffset(months=12)
    yoy_idx = (df["date"] - target_yoy).abs().idxmin()
    cpi_now       = float(latest["value"])
    cpi_year_ago  = float(df.loc[yoy_idx, "value"])
    cpi_prev_month = float(prev["value"])
    yoy_pct = round(((cpi_now - cpi_year_ago) / cpi_year_ago) * 100, 2)
    mom_pct = round(((cpi_now - cpi_prev_month) / cpi_prev_month) * 100, 2)
    result["indicators"]["cpi_inflation"] = {
        "name": "CPI Inflation (All Urban Consumers)",
        "yoy_pct": yoy_pct,
        "mom_pct": mom_pct,
        "cpi_index": round(cpi_now, 3),
        "unit": "% YoY",
        "period": str(latest["date"].date()),
        "frequency": "monthly",
        "series_id": "CPIAUCSL",
        "note": "CPI-U, seasonally adjusted; YoY = year-over-year, MoM = month-over-month",
    }
except Exception as e:
    result["indicators"]["cpi_inflation"] = {"error": str(e)}

# ── 3. Unemployment Rate ───────────────────────────────────────────────────
try:
    df = fetch_fred("UNRATE", "3/5")
    latest, prev = df.iloc[-1], df.iloc[-2]
    result["indicators"]["unemployment_rate"] = {
        "name": "Unemployment Rate",
        "value": round(float(latest["value"]), 1),
        "unit": "%",
        "period": str(latest["date"].date()),
        "previous_period": str(prev["date"].date()),
        "previous_value": round(float(prev["value"]), 1),
        "change": round(float(latest["value"]) - float(prev["value"]), 1),
        "frequency": "monthly",
        "series_id": "UNRATE",
        "note": "Civilian unemployment rate, seasonally adjusted",
    }
except Exception as e:
    result["indicators"]["unemployment_rate"] = {"error": str(e)}

# ── 4. Real GDP Growth Rate (quarterly, annualized) ───────────────────────
try:
    df = fetch_fred("A191RL1Q225SBEA", "4/5")
    latest, prev = df.iloc[-1], df.iloc[-2]
    result["indicators"]["gdp_growth_rate"] = {
        "name": "Real GDP Growth Rate",
        "value": round(float(latest["value"]), 1),
        "unit": "% annualized",
        "period": str(latest["date"].date()),
        "previous_period": str(prev["date"].date()),
        "previous_value": round(float(prev["value"]), 1),
        "frequency": "quarterly",
        "series_id": "A191RL1Q225SBEA",
        "note": "Percent change from preceding quarter, SAAR",
    }
except Exception as e:
    result["indicators"]["gdp_growth_rate"] = {"error": str(e)}

# ── 5. Consumer Confidence (Michigan Consumer Sentiment Index) ────────────
try:
    df = fetch_fred("UMCSENT", "5/5")
    latest, prev = df.iloc[-1], df.iloc[-2]
    result["indicators"]["consumer_confidence"] = {
        "name": "University of Michigan Consumer Sentiment",
        "value": round(float(latest["value"]), 1),
        "unit": "index (1966 Q1 = 100)",
        "period": str(latest["date"].date()),
        "previous_period": str(prev["date"].date()),
        "previous_value": round(float(prev["value"]), 1),
        "change": round(float(latest["value"]) - float(prev["value"]), 1),
        "frequency": "monthly",
        "series_id": "UMCSENT",
        "note": "Higher = more optimistic consumers; historical avg ~85",
    }
except Exception as e:
    result["indicators"]["consumer_confidence"] = {"error": str(e)}

# ── Write JSON ─────────────────────────────────────────────────────────────
with open(output_file, "w") as fh:
    json.dump(result, fh, indent=2)

# ── Pretty-print summary ───────────────────────────────────────────────────
W = 60
print(f"\n{'='*W}")
print(f"  US Economic Indicators  ({result['data_date']})")
print(f"{'='*W}")

indicators = result["indicators"]

def fmt_row(label, val_str, period):
    print(f"  {label:<36}  {val_str:>12}  ({period})")

# Fed Funds Rate
d = indicators.get("federal_funds_rate", {})
if "error" not in d:
    chg = f"({d['change']:+.2f} pp)" if d['change'] != 0 else "(unchanged)"
    fmt_row(d["name"], f"{d['value']:.2f}%  {chg}", d["period"])
else:
    print(f"  Federal Funds Rate          ERROR: {d['error']}")

# CPI
d = indicators.get("cpi_inflation", {})
if "error" not in d:
    fmt_row(d["name"][:36], f"{d['yoy_pct']:+.2f}% YoY  {d['mom_pct']:+.2f}% MoM", d["period"])
else:
    print(f"  CPI Inflation               ERROR: {d['error']}")

# Unemployment
d = indicators.get("unemployment_rate", {})
if "error" not in d:
    chg = f"({d['change']:+.1f} pp)" if d['change'] != 0 else "(unchanged)"
    fmt_row(d["name"], f"{d['value']:.1f}%  {chg}", d["period"])
else:
    print(f"  Unemployment Rate           ERROR: {d['error']}")

# GDP
d = indicators.get("gdp_growth_rate", {})
if "error" not in d:
    fmt_row(d["name"], f"{d['value']:+.1f}% ann.", d["period"])
else:
    print(f"  GDP Growth Rate             ERROR: {d['error']}")

# Consumer Confidence
d = indicators.get("consumer_confidence", {})
if "error" not in d:
    chg = f"({d['change']:+.1f})" if d['change'] != 0 else "(unchanged)"
    fmt_row(d["name"][:36], f"{d['value']:.1f}  {chg}", d["period"])
else:
    print(f"  Consumer Confidence         ERROR: {d['error']}")

print(f"{'='*W}")
print(f"\nData saved to: {output_file}")
PYEOF

echo ""
echo "Done. Output written to: $OUTPUT_FILE"
