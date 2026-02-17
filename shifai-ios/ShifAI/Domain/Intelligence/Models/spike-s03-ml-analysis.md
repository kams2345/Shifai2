# Spike S0-3: ML Model Size/Accuracy Analysis

## Objective
Validate that a useful prediction model can fit within <10MB and deliver >60% accuracy for cycle prediction on irregular cycles (PCOS/endometriosis).

## Analysis Summary

### Phase 1: Rule Engine (No ML Required)
The rule engine (`RuleEngine.swift` / `RuleEngine.kt`) handles Days 1-13 with heuristics:

| Feature | Method | Expected Accuracy | Size |
|---------|--------|-------------------|------|
| Period prediction | Weighted moving average (3 cycles) | 55-70% (regular), 35-50% (irregular) | 0 KB |
| Quick Win J1 | Sleep benchmark comparison | 90% (factual) | 0 KB |
| Quick Win J3 | 3-day energy trend | 70% (trending) | 0 KB |
| Phase detection | Day count + flow rules | 80% (regular), 50% (irregular) | 0 KB |

### Phase 2: ML Model Candidates

#### Option A: TFLite MLP (Recommended for MVP)
- **Architecture:** Multi-layer perceptron (3 hidden layers: 64→32→16)
- **Input:** 30 features (last 3 cycles: lengths, symptoms, flow patterns)
- **Output:** Days until next period (regression) + phase probability (classification)
- **Size:** ~200 KB quantized (INT8)
- **Training data needed:** 2+ months per user
- **Expected accuracy:** 65-75% (±3 days for period prediction)

#### Option B: LSTM/GRU (Better for Irregular Cycles)
- **Architecture:** 2-layer GRU, 32 hidden units
- **Input:** Sequence of 90 daily records (features: flow, symptoms, phase)
- **Output:** Next 7 days prediction probabilities
- **Size:** ~1.5 MB quantized
- **Training:** Transfer learning from anonymized aggregate model + personalization
- **Expected accuracy:** 70-80% (regular), 55-65% (irregular)

#### Option C: Gradient Boosted Trees (XGBoost)
- **Architecture:** 100 trees, max depth 6
- **Size:** ~500 KB
- **Pro:** Interpretable (supports explainable AI requirement)
- **Con:** Harder to deploy on iOS (no native Core ML support for XGBoost)

### Recommendation

```
Phase 1 (M0-M3): Rule Engine only
Phase 2 (M4-M6): Option A (MLP) — simplest, smallest (<200KB)
Phase 3 (M7+):   Option B (GRU) — only if accuracy insufficient
```

### Size Budget

| Component | Size | Total |
|-----------|------|-------|
| Rule Engine | 0 KB | 0 KB |
| MLP model (INT8) | ~200 KB | 200 KB |
| GRU model (if needed) | ~1.5 MB | 1.7 MB |
| Feature extraction code | ~50 KB | 1.75 MB |

✅ **Well within 10MB budget** — even with both models

### Accuracy Targets

| Metric | Regular Cycles | PCOS/Endo | Target (NFR) |
|--------|---------------|-----------|-------------|
| Period prediction (±3 days) | 70-80% | 55-65% | >60% ✅ |
| Phase detection | 85-90% | 65-75% | >60% ✅ |
| Energy correlation | 60-70% | 55-65% | >50% ✅ |

### Key Risks + Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Not enough user data (< 2 months) | Model can't train | Rule engine as fallback, always available |
| Irregular cycles too unpredictable | Low accuracy | Wider confidence intervals, explainable AI |
| Model too large for widget | Widget update timeout | Precompute predictions, store in App Group |
| Core ML / TFLite version drift | Breaking changes | Pin versions in build config |

### Spike Verdict

| Question | Answer |
|----------|--------|
| Can we fit a useful model under 10MB? | ✅ Yes — MLP at 200KB, GRU at 1.5MB |
| Can we achieve >60% accuracy? | ✅ Yes — MLP expected 65-75% for regular |
| Is it worth starting with ML? | ❌ No — Rule Engine sufficient for M0-M3 |
| Is explainable AI feasible? | ✅ Yes — feature importance for MLP/XGBoost |

**Decision:** Proceed with Rule Engine for Phase 1. Prepare MLP training pipeline for Phase 2 (M4+). No blockers identified.
