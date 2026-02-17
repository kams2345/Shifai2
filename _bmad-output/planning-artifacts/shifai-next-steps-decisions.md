# ShifAI - Next Steps & Strategic Decisions

**Date:** 2026-01-29  
**Status:** Post-Brief Produit, Pre-PRD  
**Agent Panel Review Score:** 8.6/10 (Mary: 9/10, John: 8.5/10, Sally: 9.5/10, Winston: 7.5/10)

---

## ✅ Strategic Decisions Taken (Post-Agent Review)

### 1. ML Accuracy Strategy: **Hybrid Approach** ✅

**Decision:** Approche progressive Rule-based → ML

**Phase 1 (Beta M1-3):**
- Predictions basées sur **règles heuristiques** (patterns classiques)
- Target accuracy: 60%+ (realistic, 20% better que Flo)
- Transparence: "ShifAI apprend TON rythme" (pas "70% garantie J1")

**Phase 2 (Launch M4-12):**
- ML progressif quand data suffisante (14+ jours historique)
- Target accuracy: 70%+ pour users avec historique
- Hybrid model: Rule-based pour nouveaux users, ML pour établis

**Rationale (Winston):**
- Mitige risque technique ML cycles irréguliers
- Cold start problem résolu (règles fonctionnent J1)
- ML s'améliore avec temps (data accumulation)

**PRD Action:** Spec rule-based algo Phase 1 + ML roadmap Phase 2

---

### 2. Growth Targets: **Conservateur + Scale Contingent** ✅

**Decision:** Brief garde targets conservateurs, préparer scale narrative investors

**Internal Execution Plan (Brief actuel):**
- M1-3 Beta: 300-500 users, PMF validation
- M4-6: 6K-10K users, controlled growth
- M7-12: 10K-20K users, quality focus
- Priorité: Retention 18%+, NPS 50+, CAC:LTV 3:1+

**Investor Pitch (Contingent Scale):**
- **IF** PMF validated M6 (`Retention ≥20% AND NPS ≥55`)
- **THEN** accelerate M7-12: 30K-50K users avec capital raised
- **TAM**: 28-35M femmes cycles irréguliers (Flo user base)
- **Narrative**: "Phase 1 quality, Phase 2 scale si métriques explosent"

**Rationale (Mary):**
- 10K-20K = exécutable, safe
- Investors veulent hockey stick → montrer potentiel scale

**Next Step:** Créer slide deck "Scale Scenario" pour fundraising

---

### 3. Actionable Recommendations: **Smart Push Notifications** ✅

**Decision:** Notifications push intelligentes (pas spam)

**UX Spec PRD:**

**Smart Notification Examples:**
```
☁️ "Énergie moyenne prévue demain - Prévois journée douce?"
   [Oui, ajusté] [Pas cette fois]

💤 "Ton sommeil <7h amplifie fatigue cette phase"
   [Programmer rappel 22h] [Ignorer]

🏃 "Phase haute énergie - Bon moment projets exigeants!"
   [Planifier tâche] [OK]
```

**Intelligence Rules (Pas Spam):**
- Max 1 notification/jour
- Timing contextu el: Matin (énergie prévue), Soir (sommeil/repos)
- User control: Toggle categoriés (prédictions, bien-être, rappels)
- Machine learning: Si user ignore 3x même type → stop cette catégorie

**Trackable for KPI "50% follow":**
- Click notification → Action taken (tap "Oui ajusté", "Planifier", etc.)
- Metric: `(Actions taken) / (Notifications sent)` ≥ 50%

**Rationale:**
- Garde engagement sans friction lourde
- Prouve recommendations actionnables (Core KPI)
- Différent de Flo/Clue (génériques, spam)

**PRD Action:** Notification taxonomy, timing rules, ML tuning algorithm

---

### 4. Medical Export Go-To-Market: **Bottom-Up Viral Phase 1** ✅

**Decision:** Approche virale utilisatrice-driven, pas partnerships formels early

**Phase 1 Strategy (M1-6):**

**Export Flow:**
1. Sarah génère PDF export (2 mois historique)
2. Sarah présente à gynéco rdv SOPK
3. Gynéco: "Excellent! Continuez ce tracking"
4. Gynéco recommande ShifAI à 2-3 autres patientes SOPK
5. **Viral loop** organiquement

**Format Phase 1:**
- Simple PDF bien designé (Sally input)
- Charts: Cycles timeline, symptômes heatmap, corrélations
- Footer: "Généré par ShifAI - App santé cycles féminins"
- **Pas** integration EHR (trop complexe early)

**Target:**
- 7%+ utilisatrices génèrent export M3 Beta
- 50%+ exports partagés avec docteur
- 3-5 gynécos "champions" identifiés organiquement

**Phase 2 Strategy (M7-12+):**
- Formal partnerships avec gynécos champions
- Associations endo/SOPK (EndoFrance, etc.)
- HL7 FHIR structured data (optional)

**Rationale (John):**
- Minimise overhead Phase 1 (pas sales team)
- Teste value prop réel (doctors trouvent-ils utile?)
- Permet iteration format export based feedback

**PRD Action:** PDF export design spec, viral mechanics, doctor feedback surveys

---

### 5. Core KPIs Roadmap Priority: **Séquentiel M1-12** ✅

**Decision:** Prioriser 5 Core KPIs séquentiellement (pas parallèle)

**M1-3 (Beta - Onboarding):**
- 🎯 **Priority #1:** Time to Quick Win ≤3j
- 🎯 **Priority #2:** Retention D30 ≥18%
- Goal: Valider onboarding + engagement foundation

**M4-6 (Launch - Differentiation):**
- 🎯 **Priority #3:** Time to Personalized Insight ≤14j
- 🎯 **Priority #4:** Medical Export 7%+ generated
- Goal: Unlock unique value (ML insights + medical)

**M7-12 (Scale - Excellence):**
- 🎯 **Priority #5:** Prediction Accuracy 70%+ (ML launch)
- 🎯 **Supporting:** Recommendations Followed 50%+
- Goal: Competitive moat solidified

**Rationale (John):**
- 5 KPIs parallèle = impossible optimize all
- Sequential = team focus clair chaque phase
- Each phase builds on previous (Quick Wins → Personalized → Accuracy)

**PRD Action:** Roadmap feature priorities aligned with KPI sequence

---

## 🚀 Immediate Next Steps (Pre-PRD)

### 1. Finalize Brief Produit ✅
- [x] Incorporate agent feedback decisions
- [x] Update frontmatter stepsCompleted: [1, 2, 3, 4]
- [x] Ready for stakeholder review

### 2. Create PRD (Product Requirements Document)
- [ ] Features Spec détaillé:
  - Rule-based prediction algo Phase 1
  - Smart notifications taxonomy
  - Body Map douleur interactions
  - Medical export PDF design
- [ ] UX/UI Spec:
  - Widget "Météo Intérieure" mockups
  - Onboarding flow (Quick Win J1-J3)
  - Recommendations notification templates
- [ ] Success Metrics tracking implementation:
  - Analytics events mapping
  - Dashboards definition (daily/weekly/monthly)

### 3. Create Tech Spec / Architecture Document
- [ ] Stack selection (React Native vs Flutter vs Native)
- [ ] Privacy architecture (E2E encryption, local storage)
- [ ] ML roadmap:
  - Phase 1: Rule-based heuristics
  - Phase 2: ML model selection (LSTM? Transformer?)
  - Training data strategy (synthetic? partnerships?)
- [ ] Scalability plan (10K → 100K users)
- [ ] Backend architecture (Firebase? Custom API?)

### 4. Optional: Investor Pitch Deck
- [ ] Scale scenario narrative (10K-20K → 30K-50K contingent)
- [ ] Market sizing (€432.8M EU, 28-35M TAM cycles irréguliers)
- [ ] Competitive differentiation moats
- [ ] Team (if applicable)
- [ ] Financial projections (Phase 1 conservative, Phase 2 scale)

---

## 📋 Open Questions for PRD Phase

### Product:
- [ ] Freemium paywall: Quand exactement? (J14? J30? Feature-based?)
- [ ] Premium features précis: Quels insights gratuit vs premium?
- [ ] Community / Forums in-app? (20% engagement KPI mentioned)

### Technical:
- [ ] ML training data: Où sourcer? Combien nécessaire? Privacy compliance?
- [ ] On-device ML vs Cloud? (Privacy trade-offs)
- [ ] Offline-first? (Sarah zones sans réseau)

### Business:
- [ ] Pricing tiers: Seulement €49/an? ou options mensuel/trimestriel?
- [ ] Partenariats associations endo/SOPK: Timing Phase 1 vs Phase 2?
- [ ] B2B2C cliniques: Explore M12+ ou focus B2C only early?

---

## 🎯 Success Criteria Recap

**Beta PMF Validation (M3):**
```
✅ D30 Retention ≥60%
✅ NPS ≥50
✅ Medical Export ≥7% generated
✅ Quick Win delivered ≤3j pour 90%+ users
✅ Rule-based accuracy ≥55-60%
→ GO Launch France
```

**Launch Success (M12):**
```
✅ 10K-20K Total Users
✅ D30 Retention ≥18%
✅ Time to Personalized ≤14j
✅ Medical Export 10%+
✅ NPS ≥50
✅ Premium Conversion 7-10%
✅ Prediction Accuracy ≥70% (ML users)
→ VALIDATED Scale Phase 2 (or fundraise)
```

---

## 💡 Key Learnings from Agent Review

**Mary (Analyst):**
> "Ce Brief est investment-grade. Metrics framework best-in-class."

**Action:** Use metrics rigor dans investor comms.

**John (PM):**
> "Brief dit QUOI, PRD devra clarifier COMMENT."

**Action:** PRD hyper-détaillé features, pas assumptions.

**Sally (UX):**
> "Personas = vision empathique. Design pour Sarah/Lina, pas 'user 18-35'."

**Action:** Every UX decision référence persona quotes.

**Winston (Architect):**
> "IA personnalisée = faisable MAIS manage expectations marketing vs tech reality."

**Action:** Marketing copy = realistic ("apprend ton rythme" vs "précis J1").

---

**Document Created:** 2026-01-29  
**Status:** Decisions locked, ready for PRD phase  
**Next Milestone:** PRD Draft → Team Review → Dev Kick-off

---
