# GOOG Hedging Strategy v2.0 - Final Consensus Proposal

**Date:** March 1, 2026  
**Position:** ~11,200 shares @ $311/share = $3,483,200  
**Status:** Ready for Review & Approval  
**Contributors:** Yoda + Coding Agent (Gemini CLI)

---

## 📋 Executive Summary

This document presents a **modified hybrid hedging strategy** for Liping's concentrated GOOG position (~$3.5M). After detailed analysis and consensus discussion, we recommend a **three-tier approach** that balances downside protection, income generation, and upside participation.

### Key Recommendation

| Tier | Shares | % | Strategy | Purpose |
|------|--------|---|----------|---------|
| **Core** | 7,840 | 70% | 4-Month Collar + Put Spread | Primary downside protection |
| **Income** | 2,240 | 20% | Monthly Covered Calls | Ongoing income (1-2%/month) |
| **Dry Powder** | 1,120 | 10% | Unhedged | Upside participation |

### Why This Structure?

- ✅ **70% protected** against catastrophic decline
- ✅ **37% cost reduction** via put spread vs. straight put
- ✅ **30% upside participation** if GOOG breaks out
- ✅ **$30-50k income potential** over 4 months from covered calls
- ✅ **Flexible** - can adjust after June 2026 based on catalysts

### Expected Outcomes

| Scenario | Portfolio Value | Notes |
|----------|-----------------|-------|
| **Crash ($250)** | ~$2.9M | 70% protected at $285, 30% participates in decline |
| **Floor ($285)** | ~$3.1M | Core position floor achieved |
| **Current ($311)** | ~$3.48M | Status quo |
| **Cap ($355)** | ~$3.85M | Core capped, 30% continues higher |
| **Moon ($400)** | ~$4.2M+ | 30% uncapped participation |

---

## 🎯 Detailed Trade Specifications

### Tier 1: Core Protected Position (70%)

**Shares:** 7,840 (79 contracts)

**Structure:** 4-Month Collar with Put Spread

```
Expiration: June 19, 2026 (4 months)

BUY   79x GOOG $285 Put  @ ~$8.00  → -$63,200
SELL  79x GOOG $260 Put  @ ~$3.00  → +$23,700  [Put Spread]
SELL  79x GOOG $355 Call @ ~$5.50  → +$43,450

NET COST: ~$3,950 debit (nearly zero-cost!)
```

**Protection Profile:**
- **Full protection:** $285 and above
- **Partial protection:** $260-$285 (put spread zone)
- **No protection:** Below $260 (catastrophic only)

**Upside Profile:**
- **Capped at:** $355 on 70% of position
- **Participation:** 100% up to $355

### Tier 2: Income Generation (20%)

**Shares:** 2,240 (22-23 contracts/month)

**Structure:** Monthly Covered Calls

```
Sell monthly calls, 30-45 days out
Strike: $350-360 (12-16% OTM)
Target premium: 1-2% of position value per month
```

**Expected Income:**
- **Monthly:** $7,000 - $14,000
- **4-month total:** $28,000 - $56,000
- **Annualized yield:** ~12-24%

**Rolling Strategy:**
- If called away: Let shares go, redeploy capital
- If expires worthless: Sell next month's call
- Adjust strike based on market conditions

### Tier 3: Dry Powder (10%)

**Shares:** 1,120

**Structure:** Unhedged long position

**Purpose:**
- Psychological comfort (not everything is capped)
- Full upside participation on breakout
- Can be hedged later if volatility spikes

**Monitoring:**
- Set alerts at key levels
- Consider protective puts if VIX spikes >25
- Reassess at quarterly review

---

## 📊 Risk Scenarios & Payoff Analysis

### Scenario Analysis Table

| GOOG Price @ Jun 2026 | Tier 1 (70%) | Tier 2 (20%) | Tier 3 (10%) | Total Portfolio | Income Earned | **Total Value** |
|----------------------|--------------|--------------|--------------|-----------------|---------------|-----------------|
| **$200** (crash) | $2.23M | $627k | $224k | $3.08M | +$40k | **$3.12M** |
| **$250** (bear) | $2.62M | $700k | $280k | $3.60M | +$40k | **$3.64M** |
| **$260** (put floor) | $2.73M | $728k | $314k | $3.77M | +$40k | **$3.81M** |
| **$285** (collar floor) | $2.99M | $795k | $350k | $4.14M | +$40k | **$4.18M** |
| **$311** (current) | $3.26M | $868k | $389k | $4.52M | +$40k | **$4.56M** |
| **$355** (cap) | $3.73M | $994k | $445k | $5.17M | +$40k | **$5.21M** |
| **$400** (bull) | $3.73M | $1.12M | $502k | $5.35M | +$40k | **$5.39M** |
| **$450** (moon) | $3.73M | $1.26M | $560k | $5.55M | +$40k | **$5.59M** |

### Comparison: No Hedge vs. Proposed Strategy

| Metric | No Hedge | Proposed Strategy | Difference |
|--------|----------|-------------------|------------|
| **Max Downside ($200)** | $2.24M | $3.12M | +$880k protected |
| **Current Value** | $3.48M | $3.48M | Neutral |
| **Upside Cap** | None | Partial (70% capped) | Trade-off |
| **Income (4mo)** | $0 | ~$40k | +$40k |
| **Peace of Mind** | Low | High | Priceless |

---

## ✅ Execution Checklist

### Phase 1: Core Collar (Day 1)

- [ ] **Verify options approval** with broker (Level 3+ for spreads)
- [ ] **Confirm margin requirements** (collars typically margin-exempt)
- [ ] **Place spread order** (all legs simultaneously):
  - Buy 79x $285 Put (Jun 2026)
  - Sell 79x $260 Put (Jun 2026)
  - Sell 79x $355 Call (Jun 2026)
- [ ] **Confirm fill price** and net debit < $5,000
- [ ] **Document trade** for tax records (spread treatment)

### Phase 2: Covered Calls (Week 1-2)

- [ ] **Sell Month 1 calls** (22-23 contracts, $350-360 strike)
- [ ] **Set calendar reminder** for 7 days before expiry
- [ ] **Establish rolling protocol** (when to roll up/out)
- [ ] **Track income** for tax reporting

### Phase 3: Monitoring Setup (Ongoing)

- [ ] **Set price alerts:** $260, $285, $355, $380
- [ ] **Calendar reminders:**
  - 30 days before Jun 2026 expiry
  - Monthly covered call roll dates
  - Quarterly strategy review
- [ ] **Earnings dates:** Mark April, July 2026 earnings
- [ ] **Catalyst tracking:** AdTech trial updates, DOJ ruling news

---

## 📅 Monitoring Plan & Trigger Levels

### Price Level Triggers

| Price Level | Action | Tier Affected |
|-------------|--------|---------------|
| **$260** | ⚠️ Put spread floor breached - assess damage | Tier 1 |
| **$285** | 📊 Approaching collar floor - monitor closely | Tier 1 |
| **$295** | 📈 Consider rolling put spread down for credit | Tier 1 |
| **$350** | 📊 Approaching call cap - prepare for assignment | Tier 1 |
| **$355** | ⚠️ At call cap - decide: let assign or roll up | Tier 1 |
| **$380+** | 🚀 Roll calls up to $400+ for credit | Tier 1 |

### Time-Based Triggers

| Timing | Action |
|--------|--------|
| **30 days to expiry** | Assess: close, roll, or let expire |
| **21 days to expiry** | ⚠️ Gamma risk increases - decide soon |
| **7 days to expiry** | Final decision: roll or close |
| **Earnings week** | Consider closing calls pre-earnings |

### Volatility Triggers

| VIX Level | Action |
|-----------|--------|
| **<15** | Normal operations |
| **15-20** | Monitor, no action |
| **20-25** | Consider hedging Tier 3 (dry powder) |
| **>25** | Execute protective puts on Tier 3 |

---

## 💰 Tax Considerations

### Qualified Covered Call (QCC) Treatment

**Requirements Met:**
- ✅ Call is OTM ($355 vs. $311 current)
- ✅ >30 days to expiration
- ✅ Listed on qualified exchange

**Benefits:**
- Holding period NOT suspended
- LTCG treatment preserved (if held >1 year)
- Premium = short-term capital gain

### Put Spread Treatment

**Tax Classification:** Likely treated as a "spread" position
- Net cost basis adjustment on shares
- Losses deferred until position closed
- Consult CPA for specific treatment

### Estimated Tax Impact

| Component | Tax Treatment | Notes |
|-----------|---------------|-------|
| **Collar premium** | Net debit (no immediate tax) | Basis adjustment |
| **Covered call premium** | Short-term capital gain | Reported annually |
| **If shares called away** | LTCG (if held >1 year) | On appreciation |
| **Put spread expiry** | No tax if expires worthless | Basis unchanged |

**⚠️ Recommendation:** Consult tax advisor before execution to confirm treatment and document strategy.

---

## ⚠️ Risk Warnings & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Early Assignment** | Low-Medium | Medium | Monitor delta; roll before deep ITM |
| **Pin Risk** | Low | High | Close positions before expiry if near strike |
| **Liquidity** | Low | Medium | GOOG options very liquid; use limit orders |
| **Tax Complexity** | Medium | Low | Document everything; consult CPA |
| **Opportunity Cost** | Medium | Medium | 30% uncapped + income offsets cap |
| **Regulatory Shock** | Low-Medium | High | 70% protected; 30% participates |
| **Execution Slippage** | Low | Low | Use spread orders; avoid legging in |

---

## 📞 Approval & Next Steps

### For Liping's Review

**Questions to Consider:**

1. **Does 70% protection feel sufficient?** Or would you prefer 80-90%?

2. **Are you comfortable with the $355 cap** on 70% of the position?

3. **Does the put spread risk** (protection gap below $260) feel acceptable?

4. **Timeline:** Ready to execute, or want to wait for specific catalyst?

### If Approved:

1. **Contact broker** this week to verify options approval
2. **Execute Tier 1 collar** (core position) within 1-2 weeks
3. **Begin Tier 2 covered calls** starting next month
4. **Set up monitoring alerts** and calendar reminders
5. **Schedule quarterly review** (June 2026 before expiry)

### If Modifications Needed:

- Adjust tier percentages (e.g., 80/15/5 or 60/25/15)
- Modify strike prices (higher/lower cap, different floor)
- Change expiration timeline (3 months vs. 4 months)
- Consider alternative structures (collars on 100%, no spread)

---

## 📝 Revision History

| Date | Version | Change | Author |
|------|---------|--------|--------|
| 2026-02-28 | v1.0 | Initial 6-month collar proposal | Coding Agent (Gemini) |
| 2026-03-01 | v2.0 | Final consensus: Hybrid 70/20/10 with put spread | Yoda + Coding Agent |

---

## 📚 Appendix: Original Research Reference

**Source Document:** `investment-briefs/goog-hedging-strategy-2026-02-28.md`

**Key Research Findings:**
- 52-week range: $142.66 - $350.15
- Current distance from ATH: -11%
- Key risks: DOJ ruling, AdTech trial, AI capex
- Option liquidity: Excellent (112 contracts executable)

---

**⚠️ Disclaimer:** This is research and analysis, not financial advice. Consult your financial advisor, tax professional, and broker before implementing any hedging strategy. Past performance does not guarantee future results. Options involve risk and are not suitable for all investors.

---

*Generated: March 1, 2026*  
*Status: Ready for Liping's Review & Approval*  
*File: investment-briefs/goog-hedging-strategy-v2-final.md*
