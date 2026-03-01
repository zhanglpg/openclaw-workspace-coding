# GOOG Hedging Strategy - $3.5M Concentrated Position

**Date:** February 28, 2026  
**Last Updated:** March 1, 2026 (Finalized)  
**Position:** ~11,200 shares @ $311/share = $3,483,200  
**Research Source:** Gemini CLI Analysis + OpenClaw Agent Review  
**Status:** ✅ FINALIZED - Ready for Execution

---

## 📊 Current Position Summary

| Metric | Value |
|--------|-------|
| **Shares** | ~11,200 |
| **Current Price** | $311.43 |
| **Position Value** | $3,483,200 |
| **52-Week Range** | $142.66 - $350.15 |
| **Distance from ATH** | -11% |
| **Option Contracts Needed** | 112 (100 shares/contract) |

---

## ⚠️ Key Risks Identified

1. **Regulatory Remedy Risk** - 2026 DOJ Search ruling implementation
2. **AdTech Trial** - Potential DoubleClick divestiture (Q1/Q2 2026)
3. **CapEx Pressure** - $180B AI infrastructure spend
4. **Concentration Risk** - Single-stock = portfolio volatility

---

## 🛡️ RECOMMENDED STRATEGY: Hybrid 50/25/25 (FINALIZED)

After collaborative review, the **Hybrid 50/25/25 approach** was selected as the optimal strategy, balancing downside protection with upside participation.

### Why Hybrid Over Full Collar?

| Factor | Full Collar | Hybrid 50/25/25 | Winner |
|--------|-------------|-----------------|--------|
| **Downside Protection** | 100% protected @ $280 | 50% protected @ $290 | Full Collar |
| **Upside Participation** | Capped @ $360 | 25% unlimited + 75% to $350 | **Hybrid** |
| **Income/Credit** | ~$2,240 | ~$18,480 | **Hybrid** |
| **Regulatory Risk** | Fully hedged | 50% hedged | Full Collar |
| **Flexibility** | Single position | 3 independent tiers | **Hybrid** |

### Primary Trade Structure

**Expiration:** August 21, 2026 (~6 months)

| Tier | Shares | Strategy | Strikes | Net Credit |
|------|--------|----------|---------|------------|
| **Tier 1** | 5,600 (50%) | Zero-Cost Collar | $290 Put / $350 Call | +$1,120 |
| **Tier 2** | 2,800 (25%) | Covered Call | $360 Call | +$17,360 |
| **Tier 3** | 2,800 (25%) | Unhedged | — | $0 |
| **TOTAL** | 11,200 | **Hybrid** | — | **+$18,480** |

### Detailed Trade Orders

```
Tier 1 (50% - Protection):
BUY  56x $290 Put  @ ~$5.50  → -$30,800
SELL 56x $350 Call @ ~$5.70  → +$31,920
Net: +$1,120 credit

Tier 2 (25% - Income):
SELL 28x $360 Call @ ~$6.20  → +$17,360

Tier 3 (25% - Upside):
NO ACTION - Pure upside exposure
```

### Payoff at Expiration

| GOOG Price | Portfolio Value | Notes |
|------------|-----------------|-------|
| $250 (crash) | $3,080,000 + credit | 50% protected @ $290 |
| $290 (floor) | $3,248,000 + credit | Tier 1 floor hit |
| $311 (current) | $3,483,200 + $18,480 | Baseline + credit |
| $350 (ATH) | $3,868,200 + credit | Tier 1 capped, Tier 2/3 participate |
| $400 (moon) | $4,116,000 + credit | 75% capped, 25% unlimited |

### Why This Trade?

| Benefit | Details |
|---------|---------|
| **Best of Both Worlds** | Protection on 50%, upside on 25% |
| **Strong Credit** | $18,480 cash credit (~0.53% of position) |
| **Regulatory Hedge** | 50% protected against binary DOJ/AdTech events |
| **AI Momentum Capture** | 25% unhedged participates in breakout above $350 |
| **Tax Efficient** | QCC rules, holding period preserved |
| **Flexibility** | Each tier can be adjusted independently |

---

## 📋 Alternative Strategies (For Reference)

### Strategy Comparison

| Strategy | Cost | Downside Protection | Upside Cap | Best For |
|----------|------|---------------------|------------|----------|
| **Hybrid 50/25/25** | $0 (credit) | ⭐⭐⭐ (50% @ $290) | ⭐⭐⭐⭐ (75% capped) | **SELECTED - Balanced** |
| **6-Month Collar** | $0 (credit) | ⭐⭐⭐⭐⭐ ($280 floor) | ⭐⭐ ($360 cap) | Conservative approach |
| **Protective Put** | 4-6% of position | ⭐⭐⭐⭐⭐ (strike floor) | ⭐⭐⭐⭐⭐ (unlimited) | Very bullish outlook |
| **Covered Call** | $0 (income) | ⭐⭐ (premium only) | ⭐⭐ (strike cap) | Income generation |

---

## 🎯 Price Levels to Monitor

| Level | Action |
|-------|--------|
| **$360** | Tier 2 call strike - monitor for assignment |
| **$350** | Tier 1 call strike - assess momentum, consider rolling up |
| **$311** | Current price - no action needed |
| **$290** | Tier 1 put floor - approaching protection zone |
| **$280** | Original full collar floor - reference only |

---

## 📅 Monitoring & Adjustment Rules

### Tier 1 (50% Collar: $290/$350)

| Trigger | Action |
|---------|--------|
| **GOOG hits $350** | Assess momentum. If strong, roll call to $370-380 (Jan 2027) for credit |
| **GOOG drops to $290** | Hold - this is the protection floor |
| **GOOG drops to $270** | Consider rolling put down to $250, pocket profit |
| **21 days to expiry** | Close or roll entire tier (avoid gamma risk) |

### Tier 2 (25% Covered Call: $360)

| Trigger | Action |
|---------|--------|
| **GOOG hits $360** | Monitor for assignment risk |
| **GOOG > $370** | Consider rolling up to $380-400 for additional credit |
| **21 days to expiry** | Close or roll if OTM |

### Tier 3 (25% Unhedged)

| Trigger | Action |
|---------|--------|
| **GOOG > $350** | Consider adding protective puts if momentum stalls |
| **GOOG < $290** | Evaluate adding hedge if thesis broken |

### General Rules

| Trigger | Action |
|---------|--------|
| **Earnings before expiry** | Consider closing short calls pre-earnings (volatility risk) |
| **DOJ/AdTech news** | Reassess all tiers; may add protection to Tier 3 |

---

## ✅ Execution Checklist

- [ ] Contact broker (confirm options approval: 56 puts + 84 calls = 140 contracts total)
- [ ] Verify margin requirements (collars typically margin-exempt)
- [ ] Place Tier 1 as spread order (leg in simultaneously to avoid slippage)
- [ ] Place Tier 2 as single-leg covered call
- [ ] Confirm QCC tax treatment (document for tax filing)
- [ ] Set price alerts at $270, $290, $350, $360, $370 levels
- [ ] Calendar reminder for 21 days before expiration (June 2026)
- [ ] Document baseline: 11,200 shares @ $311 = $3,483,200

---

## ⚠️ Risk Warnings

| Risk | Mitigation |
|------|------------|
| **Early Assignment** | Monitor delta; roll before ITM |
| **Pin Risk** | Close positions before expiry if near strike |
| **Liquidity** | GOOG options liquid, but 112 contracts = large order |
| **Tax Complexity** | Consult CPA for straddle/QCC rules |
| **Opportunity Cost** | Capped upside if GOOG moons to $400+ |

---

## 📞 Next Steps

1. **Share with financial advisor** - Review before execution
2. **Get option chain quotes** - Confirm current premiums with broker
3. **Execute as spread orders** - Not legs separately (avoid slippage)
4. **Set up monitoring alerts** - Track key price levels
5. **Schedule quarterly review** - Reassess hedge effectiveness

---

## 📚 Research Notes

### Tax Considerations

**Qualified Covered Call (QCC) Rules:**
- Call must be OTM with >30 days to expiration
- Holding period NOT suspended
- LTCG treatment preserved
- Premium = short-term capital gain

**Straddle Rules (Protective Puts only):**
- Losses on put deferred until stock sold
- May reset holding period if not already LTCG
- Consult tax advisor before implementing

### Option Greeks to Monitor

| Greek | What It Tells You | Target Range |
|-------|-------------------|--------------|
| **Delta** | Probability ITM at expiry | Calls: <0.30, Puts: >-0.30 |
| **Theta** | Time decay per day | Positive for call seller |
| **Vega** | Sensitivity to volatility | Neutral for collar |
| **Gamma** | Rate of delta change | Monitor near expiry |

---

## 📝 Revision History

| Date | Change | Author |
|------|--------|--------|
| 2026-02-28 | Initial strategy document (Full Collar) | Gemini CLI + OpenClaw |
| 2026-03-01 | **FINALIZED**: Changed to Hybrid 50/25/25 strategy after agent review | OpenClaw Agents (Consensus) |

---

## 🤝 Consensus Notes

**Discussion Participants:**
- <@1477480344218370309> (Coding Agent - Strategy Generator)
- <@1477451834426659029> (Review Agent - Second Opinion)

**Decision Rationale:**
The Hybrid 50/25/25 approach was selected over the Full Collar because:
1. **Higher credit**: $18,480 vs $2,240 (8x more income)
2. **Upside participation**: 25% of position has unlimited upside
3. **Adequate protection**: 50% hedged against binary regulatory events
4. **Flexibility**: Each tier can be managed independently

**Risk Acknowledged:**
- 50% of position remains unhedged below $290
- More complex to manage than single collar
- Requires active monitoring of 3 tiers

---

**⚠️ Disclaimer:** This is research, not financial advice. Consult your financial advisor and tax professional before implementing hedging strategies, especially with a position of this size.

---

*Generated: February 28, 2026 at 11:22 PM PST*  
*Finalized: March 1, 2026 at 3:15 AM PST*  
*Source: Gemini CLI Analysis + OpenClaw Agent Consensus*  
*File: investment-briefs/goog-hedging-strategy-2026-02-28.md*
