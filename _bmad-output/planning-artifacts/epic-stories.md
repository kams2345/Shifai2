---
stepsCompleted: ['epics-definition', 'stories-breakdown', 'sprint-mapping']
inputDocuments: 
  - 'planning-artifacts/prd-shifai.md'
  - 'planning-artifacts/architecture.md'
workflowType: 'epic-stories'
project_name: 'ShifAI'
date: '2026-02-10'
author: 'Mimir'

# Sprint Strategy
sprintDuration: 2 weeks
totalSprints: 13 (Spike Week 0 + M1-M6)
teamSize: '2.5 devs + PM + UX + ML'
budgetOption: 'B (recommended): €283K-€379K'

# Priority Legend
# P0 = Launch Blocker (must ship for beta)
# P1 = High Priority (should ship for beta)
# P2 = Nice to Have (can defer to M7+)
---

# ShifAI — Epics & User Stories

_Backlog complet dérivé du PRD (FR1-FR48, NFRs) et de l'Architecture Decision Document. Organisé en 10 Epics, 70+ stories, mappés sur le timeline M0-M6._

---

## 📋 Epic Overview

| # | Epic | Sprint | Priority | Stories |
|---|------|--------|----------|---------|
| E0 | Spike Week 0 — Technical Validation | S0 | P0 | 3 |
| E1 | Foundation & Security | S1-S2 | P0 | 10 |
| E2 | Core Tracking | S2-S4 | P0 | 9 |
| E3 | Onboarding & Quick Wins | S3-S5 | P0 | 8 |
| E4 | Intelligence Engine | S4-S7 | P0 | 8 |
| E5 | Widgets | S5-S7 | P1 | 6 |
| E6 | Medical Export | S6-S8 | P0 | 7 |
| E7 | Sync Engine | S6-S9 | P1 | 7 |
| E8 | Smart Notifications | S7-S9 | P1 | 6 |
| E9 | Settings, Privacy & Compliance | S3-S10 | P0 | 8 |
| E10 | Beta Polish & Launch | S10-S13 | P0 | 8 |

---

## E0 — Spike Week 0 : Technical Validation

**Objectif :** Valider les 3 risques techniques critiques avant d'engager le développement.

> [!CAUTION]
> Chaque spike a un critère **Go/No-Go**. Si un spike échoue, on pivote l'architecture avant de coder.

---

### S0-1 · Spike: Custom Encryption PoC
**Priority:** P0 — Launch Blocker  
**Sprint:** S0  
**FR/NFR:** NFR-S1, NFR-S3  
**Acceptance Criteria:**
- [ ] SQLCipher intégré dans un projet Swift minimal, DB chiffré AES-256 fonctionne
- [ ] Key derivation PBKDF2 (100K iterations) depuis biometric/PIN vérifié
- [ ] Sync PoC: sérialisation JSON → chiffrement AES-256-GCM → upload blob → download → déchiffrement → données identiques
- [ ] Overhead performance mesuré: <10% vs SQLite non chiffré
- **Go/No-Go:** Chiffrement round-trip fonctionne sans perte de données, overhead acceptable

---

### S0-2 · Spike: iOS Widget Blur Mechanism
**Priority:** P0 — Launch Blocker  
**Sprint:** S0  
**FR/NFR:** FR36-FR39  
**Acceptance Criteria:**
- [ ] Prototype WidgetKit avec Small + Medium widget affichant données mock
- [ ] Mécanisme blur/redaction activé quand device verrouillé (Lock Screen widget = minimal)
- [ ] Shared App Group data store fonctionne entre app et widget extension
- [ ] Performance: widget refresh <5s, timeline 50 entries max
- **Go/No-Go:** Blur techniquement faisable, performance acceptable

---

### S0-3 · Spike: ML Model Size/Accuracy Trade-off
**Priority:** P0 — Launch Blocker  
**Sprint:** S0  
**FR/NFR:** FR8-FR15  
**Acceptance Criteria:**
- [ ] Dataset synthétique généré (1000 cycles irréguliers simulés SOPK/Endo)
- [ ] Modèle entraîné (gradient boosted trees ou LSTM léger)
- [ ] Taille modèle: <10MB (.mlmodel / .tflite)
- [ ] Accuracy mesurée: ≥60% prédiction dates ±2 jours sur cycles irréguliers
- [ ] Inference time mesurée: <150ms sur iPhone 12
- **Go/No-Go:** Modèle <10MB atteint 60%+ accuracy

---

## E1 — Foundation & Security

**Objectif :** Poser les fondations techniques : projet, chiffrement, auth, base de données locale sécurisée.

**Dépendances :** E0 (Spikes validés Go)

---

### S1-1 · iOS Project Setup
**Priority:** P0  
**Sprint:** S1  
**Acceptance Criteria:**
- [ ] Projet Xcode créé (Swift 5.9+, iOS 16.0+ target)
- [ ] Architecture Clean Architecture (Presentation/Domain/Data layers) structurée
- [ ] SwiftLint configuré avec règles projet
- [ ] CI pipeline GitHub Actions: lint + build + test
- [ ] Fastlane configuré (TestFlight deployment)
- [ ] `.gitignore`, `README.md`, structure conforme à `architecture.md`

---

### S1-2 · Android Project Setup
**Priority:** P0  
**Sprint:** S1  
**Acceptance Criteria:**
- [ ] Projet Android Studio créé (Kotlin 2.0+, SDK 26-34, Jetpack Compose)
- [ ] Architecture Clean Architecture structurée (miroir iOS)
- [ ] ktlint configuré
- [ ] CI pipeline GitHub Actions: lint + build + test
- [ ] Fastlane configuré (Play Console Internal Track)

---

### S1-3 · Supabase EU Backend Setup
**Priority:** P0  
**Sprint:** S1  
**Acceptance Criteria:**
- [ ] Projet Supabase créé en **région EU** exclusivement
- [ ] Tables `encrypted_user_data` et `sync_metadata` migrées
- [ ] Supabase Auth configuré (email/password + Apple Sign In)
- [ ] Storage bucket privé créé (exports PDF)
- [ ] Row Level Security (RLS) activé sur toutes les tables
- [ ] Variables d'environnement documentées

---

### S1-4 · Encryption Layer — iOS
**Priority:** P0  
**Sprint:** S1-S2  
**FR/NFR:** NFR-S1, NFR-S3  
**Acceptance Criteria:**
- [ ] `EncryptionManager` implémenté (AES-256-GCM encrypt/decrypt)
- [ ] `KeyDerivation` implémenté (PBKDF2, 100K iterations, random salt)
- [ ] Master Key stocké dans iOS Keychain (Secure Enclave backed, `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`)
- [ ] DB Key, Sync Key, Export Key dérivés du Master Key
- [ ] Tests unitaires: encrypt → decrypt round-trip, key rotation
- [ ] Aucune clé en clair dans les logs ou la mémoire

---

### S1-5 · Encryption Layer — Android
**Priority:** P0  
**Sprint:** S1-S2  
**FR/NFR:** NFR-S1, NFR-S3  
**Acceptance Criteria:**
- [ ] `EncryptionManager` implémenté (AES-256-GCM via javax.crypto)
- [ ] `KeyDerivation` implémenté (PBKDF2)
- [ ] Master Key stocké dans AndroidKeyStore (TEE hardware-backed)
- [ ] Tests unitaires identiques à iOS

---

### S1-6 · SQLCipher Local Database — iOS
**Priority:** P0  
**Sprint:** S2  
**FR/NFR:** FR22, NFR-S1  
**Acceptance Criteria:**
- [ ] GRDB.swift + SQLCipher intégré
- [ ] Schéma 6 tables créé (`user_profile`, `cycle_entries`, `symptom_logs`, `insights`, `predictions`, `sync_log`)
- [ ] Migrations versionnées fonctionnelles
- [ ] Repositories implémentés (CycleRepository, SymptomRepository)
- [ ] DB key = dérivé du Master Key
- [ ] Tests: CRUD complet, migration up/down

---

### S1-7 · SQLCipher Local Database — Android
**Priority:** P0  
**Sprint:** S2  
**FR/NFR:** FR22, NFR-S1  
**Acceptance Criteria:**
- [ ] Room + SQLCipher for Android intégré
- [ ] Schéma identique à iOS (6 tables)
- [ ] DAOs, Entities, Migrations
- [ ] Tests identiques à iOS

---

### S1-8 · Biometric Authentication — iOS
**Priority:** P0  
**Sprint:** S2  
**FR/NFR:** FR42-FR43, NFR-S5, NFR-S6  
**Acceptance Criteria:**
- [ ] Face ID / Touch ID via LocalAuthentication framework
- [ ] Fallback PIN 4-6 digits si biométrie indisponible
- [ ] Auto-lock après 5 min inactivité (configurable 1-15 min)
- [ ] Rate limiting: 5 échecs / 15 min
- [ ] Suggestion contextuelle d'activation J3-J5 (pas forcé à l'onboarding)

---

### S1-9 · Biometric Authentication — Android
**Priority:** P0  
**Sprint:** S2  
**FR/NFR:** FR42-FR43, NFR-S5, NFR-S6  
**Acceptance Criteria:**
- [ ] BiometricPrompt implémenté (fingerprint, face unlock)
- [ ] Fallback PIN identique à iOS
- [ ] Mêmes règles auto-lock et rate limiting

---

### S1-10 · Certificate Pinning & Network Security
**Priority:** P0  
**Sprint:** S2  
**FR/NFR:** NFR-S2  
**Acceptance Criteria:**
- [ ] TLS 1.3 enforced sur toutes les connexions
- [ ] Certificate pinning vers Supabase EU (pin du certificat intermédiaire CA)
- [ ] Backup pin configuré (secondary hash)
- [ ] Si les 2 pins échouent → connexion bloquée (fail-close)
- [ ] iOS: `URLSession` delegate + `Info.plist` ATS
- [ ] Android: `network_security_config.xml` + OkHttp `CertificatePinner`

---

## E2 — Core Tracking

**Objectif :** Toutes les fonctionnalités de saisie quotidienne : cycles, symptômes, Body Map, mood/énergie/sommeil/stress.

**Dépendances :** E1 (DB + encryption fonctionnels)

---

### S2-1 · Cycle Tracking
**Priority:** P0  
**Sprint:** S2-S3  
**FR:** FR1, FR6, FR7  
**Acceptance Criteria:**
- [ ] Log début/fin de règles avec intensité flux (1-5)
- [ ] Calcul automatique cycle_day et détection phase (menstrual/follicular/ovulatory/luteal)
- [ ] Détection longueur de cycle et régularité
- [ ] Vue historique 3 ans (données locales chiffrées)
- [ ] Édition et suppression d'entrées passées
- [ ] Persistence chiffrée SQLCipher

---

### S2-2 · Symptom Logging
**Priority:** P0  
**Sprint:** S3  
**FR:** FR2  
**Acceptance Criteria:**
- [ ] Bibliothèque 30+ symptômes SOPK/Endo (headache, bloating, cravings, acne, breast tenderness, nausea, constipation, diarrhea, hot flashes, etc.)
- [ ] Catégorisation symptômes (physique, digestif, émotionnel, douleur)
- [ ] Ajout notes texte libre par symptôme
- [ ] Sélection rapide (favoris/fréquents)
- [ ] UI: grid picker, max 3 taps pour logger

---

### S2-3 · Body Map Pain Interactions
**Priority:** P0  
**Sprint:** S3-S4  
**FR:** FR3, FR4  
**Acceptance Criteria:**
- [ ] Canvas interactif Body Map (vue de face simplifée)
- [ ] 5 zones anatomiques tappables: utérus, ovaire gauche, ovaire droit, bas du dos, cuisses
- [ ] Sélection type de douleur par zone: cramping, burning, pressure, other
- [ ] Intensité par zone (1-10 slider)
- [ ] Notes optionnelles par zone
- [ ] iOS: UIKit canvas wrappé en SwiftUI
- [ ] Android: Custom Canvas View wrappé en Compose
- [ ] Visualisation heatmap des zones douloureuses

---

### S2-4 · Mood Tracking
**Priority:** P0  
**Sprint:** S3  
**FR:** FR5  
**Acceptance Criteria:**
- [ ] Emoji picker pour humeur (5-7 états: 😄😊😐😔😢😤😰)
- [ ] Notes optionnelles
- [ ] Historique mood timeline
- [ ] Max 2 taps pour logger

---

### S2-5 · Energy Level Tracking
**Priority:** P0  
**Sprint:** S3  
**FR:** FR5  
**Acceptance Criteria:**
- [ ] Slider 1-10 avec labels visuels (⚡ bas → 🔥 max)
- [ ] Historique graphique énergie
- [ ] Quick-log depuis widget (tap)

---

### S2-6 · Sleep Quality Tracking
**Priority:** P0  
**Sprint:** S3  
**FR:** FR5  
**Acceptance Criteria:**
- [ ] Saisie heures de sommeil (durée)
- [ ] Qualité sommeil (1-5)
- [ ] Historique graphique sommeil
- [ ] Benchmark vs moyenne recommandée

---

### S2-7 · Stress Level Tracking
**Priority:** P0  
**Sprint:** S3  
**FR:** FR5  
**Acceptance Criteria:**
- [ ] Slider 1-5 avec labels
- [ ] Historique graphique stress
- [ ] Corrélation visuelle stress-cycle

---

### S2-8 · Dashboard Principal
**Priority:** P0  
**Sprint:** S4  
**Acceptance Criteria:**
- [ ] Vue cycle jour actuel + phase actuelle (card "Météo Intérieure")
- [ ] Résumé quick-log du jour (mood, energy, sleep, stress, symptoms)
- [ ] Accès rapide logging (boutons bas écran)
- [ ] Affichage dernière prédiction/insight
- [ ] Navigation vers Insights, Tracking détaillé, Export, Settings
- [ ] Pull-to-refresh

---

### S2-9 · Tracking Calendar View
**Priority:** P1  
**Sprint:** S4  
**Acceptance Criteria:**
- [ ] Vue calendrier mensuel avec dots colorés (flux, symptômes, mood)
- [ ] Tap jour → détail du jour (tous les logs)
- [ ] Scroll entre mois
- [ ] Légende couleurs

---

## E3 — Onboarding & Quick Wins

**Objectif :** Expérience premier lancement → Quick Win J3 → rétention valley bridge J4-J13.

**Dépendances :** E2 (tracking fonctionnel)

---

### S3-1 · Onboarding Screen 1: Accueil Empathique
**Priority:** P0  
**Sprint:** S3  
**Acceptance Criteria:**
- [ ] Écran bienvenue: design neutre (PAS rose, PAS fleurs)
- [ ] Message: "Ton corps a un rythme unique. ShifAI apprend le tien."
- [ ] Question: "Décris ton cycle en 3 mots" (input libre, stocké profil)
- [ ] Statistique validation: "40% des femmes ont des cycles irréguliers. Tu n'es pas seule."

---

### S3-2 · Onboarding Screen 2: Disclaimer Légal
**Priority:** P0  
**Sprint:** S3  
**FR:** FR47  
**Acceptance Criteria:**
- [ ] Disclaimer clair: "ShifAI = outil d'information, PAS un dispositif médical"
- [ ] "Consulte toujours ton médecin pour diagnostic et traitement"
- [ ] Checkbox acceptation obligatoire
- [ ] Lien vers Privacy Policy et ToS

---

### S3-3 · Onboarding Screen 3: Privacy Promise
**Priority:** P0  
**Sprint:** S3  
**FR:** FR45  
**Acceptance Criteria:**
- [ ] Message: "Tes données restent sur TON téléphone. Cloud sync optionnel. Serveur ne peut PAS lire tes données."
- [ ] Badges visuels: 🔒 Chiffré, 🇪🇺 Serveurs EU, 0️⃣ Zéro trackers
- [ ] Lien "En savoir plus" → détail architecture privacy

---

### S3-4 · Onboarding Screen 4: Setup Profil
**Priority:** P0  
**Sprint:** S3  
**Acceptance Criteria:**
- [ ] Questions essentielles: âge approximatif, durée cycle estimé, conditions connues (SOPK/Endo/Aucune/Je ne sais pas)
- [ ] Sélection symptômes à tracker (pré-sélection basée sur condition)
- [ ] Pas de pression: "Tu peux modifier à tout moment"
- [ ] Sauvegarde dans `user_profile`

---

### S3-5 · Onboarding Screen 5: Première Action — Body Map
**Priority:** P0  
**Sprint:** S4  
**Acceptance Criteria:**
- [ ] Invitation à marquer douleurs actuelles sur Body Map
- [ ] Feedback immédiat: "Merci ! Je vais observer ce pattern."
- [ ] Transition vers Dashboard

---

### S3-6 · Quick Win J1 — Benchmark Instantané
**Priority:** P0  
**Sprint:** S4-S5  
**FR:** FR14  
**Acceptance Criteria:**
- [ ] Insight généré après premier log: benchmark sommeil vs moyenne femmes même âge
- [ ] Insight éducatif: "Voici comment fonctionne un cycle menstruel en 4 phases"
- [ ] Card visuelle dans Dashboard
- [ ] Analytics event: `quick_win_viewed` + `time_on_screen`

---

### S3-7 · Quick Win J3 — Mini-Pattern
**Priority:** P0  
**Sprint:** S5  
**FR:** FR14  
**Acceptance Criteria:**
- [ ] Insight après 3 jours de données: "Ton énergie suit un pattern similaire → ton corps a une logique"
- [ ] Comparaison baseline vs jours suivants
- [ ] Encouragement progressif: "Continue encore quelques jours pour des insights encore plus précis !"
- [ ] Suggestion actionable

---

### S3-8 · Educational Drip J4-J13
**Priority:** P0  
**Sprint:** S5  
**FR:** FR15  
**Acceptance Criteria:**
- [ ] 10 tips éducatifs SOPK/Endo livrés 1/jour (J4-J13)
- [ ] Contenu: phases du cycle, impact stress, sommeil, nutrition, exercice
- [ ] Auto-stop J14 (transition vers ML insights)
- [ ] Localisé FR
- [ ] Card format dans Dashboard + notification optionnelle
- [ ] Source: `tips_fr.json` dans Resources

---

## E4 — Intelligence Engine

**Objectif :** Moteur d'intelligence hybride Rules→ML, prédictions, insights personnalisés, explainable AI.

**Dépendances :** E2 (données tracking disponibles), E0-S3 (ML model validé)

---

### S4-1 · Rule Engine — Pattern Detection
**Priority:** P0  
**Sprint:** S4-S5  
**FR:** FR8-FR10  
**Acceptance Criteria:**
- [ ] Détection longueur de cycle (moyenne, écart-type, tendance)
- [ ] Détection corrélations simples: stress↔douleur, sommeil↔énergie, cycle_phase↔mood
- [ ] Algorithme prédiction date prochaines règles (moyenne pondérée 3 derniers cycles)
- [ ] Détection fenêtre d'ovulation estimée (milieu de cycle ± marge)
- [ ] Accuracy target: 60%+ pour cycles irréguliers
- [ ] Output: `Insight` + `Prediction` objects avec `reasoning` texte

---

### S4-2 · Explainable AI Module
**Priority:** P0  
**Sprint:** S5  
**FR:** FR11, FR13  
**Acceptance Criteria:**
- [ ] Chaque insight/prédiction inclut un champ `reasoning` humain-lisible
- [ ] Format: "Énergie haute prévue car: Sommeil stable (7.5h moy) + J12 cycle + stress bas (2/5)"
- [ ] Niveaux de confiance affichés: "Fiabilité: 65%"
- [ ] Transparence onboarding: "ShifAI apprend ton rythme. Plus tu logges, plus c'est précis."

---

### S4-3 · ML Engine Integration — iOS (Core ML)
**Priority:** P0  
**Sprint:** S6-S7  
**FR:** FR8-FR12  
**Acceptance Criteria:**
- [ ] `MLEngine.swift` charge modèle `shifai_cycle_v1.mlmodel`
- [ ] Inference on-device: <150ms (M6 target)
- [ ] Input features: 14+ jours de données (cycle, symptoms, sleep, energy, stress, mood)
- [ ] Output: predictions (period start, ovulation, energy pattern)
- [ ] Transition automatique: Rules→ML quand 14+ jours data disponible
- [ ] Tests: inference avec données mock, accuracy benchmarks

---

### S4-4 · ML Engine Integration — Android (TFLite)
**Priority:** P0  
**Sprint:** S6-S7  
**Acceptance Criteria:**
- [ ] `MLEngine.kt` charge modèle `shifai_cycle_v1.tflite`
- [ ] Parité fonctionnelle avec iOS MLEngine
- [ ] Inference on-device: <150ms

---

### S4-5 · Prediction Feedback Loop
**Priority:** P0  
**Sprint:** S7  
**FR:** FR12  
**Acceptance Criteria:**
- [ ] Quand une prédiction se réalise → prompt "Cette prédiction était-elle exacte ?"
- [ ] Options: 👍 Précis / 👎 Pas précis / ➖ Skip
- [ ] Feedback stocké dans `predictions.user_feedback`
- [ ] ML model fine-tune local basé sur feedback (Phase 2 M7+, stockage data feedback dès maintenant)
- [ ] Analytics: `prediction_feedback_submitted`

---

### S4-6 · Insights UI — Insights Tab
**Priority:** P0  
**Sprint:** S5-S6  
**Acceptance Criteria:**
- [ ] Liste d'insights triés par date (plus récents en haut)
- [ ] Cards visuelles: Quick Win (vert), Pattern (bleu), Prediction (violet), Recommendation (orange)
- [ ] Tap card → détail avec reasoning complet
- [ ] Badge "Nouveau" sur insights non lus
- [ ] Pull-to-refresh (regénère insights si nouvelles données)

---

### S4-7 · Predictions UI — Cycle Predictions
**Priority:** P0  
**Sprint:** S6  
**FR:** FR8-FR9  
**Acceptance Criteria:**
- [ ] Card prédiction prochaines règles: date range + confiance %
- [ ] Card prédiction ovulation: date range + confiance %
- [ ] Timeline visuelle: cycle actuel avec marqueurs prédictions
- [ ] Historique prédictions vs réalité (accuracy tracking visible)

---

### S4-8 · Recommendations UI
**Priority:** P1  
**Sprint:** S7  
**FR:** FR11  
**Acceptance Criteria:**
- [ ] Cards actionables: "Énergie basse prévue demain → Prévois journée douce"
- [ ] Boutons action: "[Oui, ajusté] [Pas cette fois]"
- [ ] Tracking action: `recommendation_followed` analytics event
- [ ] Phase-based advice (folliculaire, lutéale, menstruelle)

---

## E5 — Widgets

**Objectif :** "Météo Intérieure" — engagement passif quotidien via widgets home screen et lock screen.

**Dépendances :** E2 (tracking data), E4 (insights/predictions)

---

### S5-1 · iOS Small Widget
**Priority:** P1  
**Sprint:** S5-S6  
**FR:** FR36  
**Acceptance Criteria:**
- [ ] Affiche: cycle day, phase actuelle (icône), mood quick-log button
- [ ] Refresh depuis shared App Group SQLCipher DB
- [ ] 3 états: "Pas assez de données", "Cycle irrégulier détecté", "Pattern détecté"
- [ ] Design cohérent avec app

---

### S5-2 · iOS Medium Widget
**Priority:** P1  
**Sprint:** S6  
**FR:** FR37  
**Acceptance Criteria:**
- [ ] Affiche: cycle day, phase, next prediction preview, Quick Win insight
- [ ] DeepLink vers Insights tab au tap

---

### S5-3 · iOS Large Widget (Today View)
**Priority:** P1  
**Sprint:** S6  
**FR:** FR38  
**Acceptance Criteria:**
- [ ] Cycle visualization mini-chart
- [ ] Résumé symptômes du jour
- [ ] 5 raccourcis quick-log (mood, energy, sleep, stress, pain)

---

### S5-4 · iOS Lock Screen Widget
**Priority:** P2  
**Sprint:** S7  
**FR:** FR39  
**Acceptance Criteria:**
- [ ] Minimal: cycle day + phase icon uniquement
- [ ] **Aucune donnée sensible** (privacy-first sur lock screen)
- [ ] iOS 16+ only (Accessory Circular/Rectangular)

---

### S5-5 · Android Home Screen Widget
**Priority:** P1  
**Sprint:** S6-S7  
**FR:** FR40  
**Acceptance Criteria:**
- [ ] Glance API widget
- [ ] Affiche: cycle day, phase, Material You dynamic colors
- [ ] On-demand update (visible only, zero background drain)
- [ ] Data via ContentProvider depuis encrypted local DB

---

### S5-6 · Widget Data Provider (Shared)
**Priority:** P1  
**Sprint:** S5  
**FR:** FR41  
**Acceptance Criteria:**
- [ ] iOS: App Group shared container, read-only SQLCipher access
- [ ] Android: ContentProvider avec encryption-aware reads
- [ ] Data update automatique quand user log dans l'app
- [ ] **Aucune connexion réseau** dans le widget (local data only)

---

## E6 — Medical Export

**Objectif :** Export PDF médical structuré — différenciateur clé B2B2C, boucle virale gynécologue.

**Dépendances :** E2 (tracking data)

---

### S6-1 · PDF Generation Engine
**Priority:** P0  
**Sprint:** S6-S7  
**FR:** FR16-FR17  
**Acceptance Criteria:**
- [ ] iOS: PDFKit natif, génération in-memory
- [ ] Android: `android.graphics.pdf.PdfDocument`
- [ ] Performance: <10s pour 3 mois data, <30s pour 3 ans
- [ ] Components PDF: cycle timeline chart, symptom frequency heatmap, Body Map pain heatmap, correlations table
- [ ] Watermark: "Information uniquement — Généré par ShifAI"
- [ ] Disclaimer footer (FR21)

---

### S6-2 · Template SOPK
**Priority:** P0  
**Sprint:** S7  
**FR:** FR16  
**Acceptance Criteria:**
- [ ] Template optimisé pour SOPK: irrégularité cycles, symptômes androgéniques, correlations hormonales
- [ ] Sections: cycle overview, symptom frequency top 10, Body Map heatmap, sleep/energy patterns
- [ ] Format A4, professionnel, clair pour gynéco

---

### S6-3 · Template Endométriose
**Priority:** P0  
**Sprint:** S7  
**FR:** FR17  
**Acceptance Criteria:**
- [ ] Template optimisé pour Endo: douleurs chroniques, localisation, intensité patterns
- [ ] Body Map heatmap détaillé avec évolution temporelle
- [ ] Sections adaptées aux besoins diagnostic endo

---

### S6-4 · Template Custom
**Priority:** P1  
**Sprint:** S8  
**Acceptance Criteria:**
- [ ] Sélection libre de sections à inclure
- [ ] Range de dates personnalisable
- [ ] Ajout notes libre pour questions gynéco (FR20)

---

### S6-5 · Export Preview
**Priority:** P0  
**Sprint:** S7  
**Acceptance Criteria:**
- [ ] Preview PDF in-app avant partage
- [ ] Scroll, zoom, page turn
- [ ] Bouton "Modifier" → retour sélection

---

### S6-6 · Share Flow
**Priority:** P0  
**Sprint:** S8  
**FR:** FR18-FR19  
**Acceptance Criteria:**
- [ ] Email PDF en pièce jointe (share sheet natif)
- [ ] Print (AirPrint iOS, standard Android)
- [ ] Shareable link (upload encrypted PDF → Supabase Storage → URL 7 jours)
- [ ] Analytics: `export_generated`, `export_shared`

---

### S6-7 · Shareable Link Backend
**Priority:** P1  
**Sprint:** S8  
**FR:** FR19  
**Acceptance Criteria:**
- [ ] Edge Function `generate-share-link`: upload PDF → return URL
- [ ] URL format: `https://shifai.app/export/{uuid}`
- [ ] TTL 7 jours, auto-delete via cron Edge Function
- [ ] Pas de données personnelles dans l'URL

---

## E7 — Sync Engine

**Objectif :** Synchronisation chiffrée cloud optionnelle — zero-knowledge, offline-first.

**Dépendances :** E1 (encryption), E2 (data to sync)

---

### S7-1 · Sync Engine Architecture — iOS
**Priority:** P1  
**Sprint:** S6-S7  
**FR:** FR23-FR26  
**Acceptance Criteria:**
- [ ] `SyncEngine.swift` implémenté
- [ ] Sérialisation: local DB → JSON → AES-256-GCM encrypt → blob
- [ ] Push blob vers Supabase `encrypted_user_data`
- [ ] Pull blob (si version serveur plus récente)
- [ ] Decrypt → merge avec données locales
- [ ] Checksum SHA-256 pour intégrité

---

### S7-2 · Sync Engine Architecture — Android
**Priority:** P1  
**Sprint:** S7-S8  
**Acceptance Criteria:**
- [ ] `SyncEngine.kt` — parité fonctionnelle iOS
- [ ] Mêmes protocoles encrypt/decrypt/push/pull

---

### S7-3 · Sync API (Edge Function)
**Priority:** P1  
**Sprint:** S6  
**Acceptance Criteria:**
- [ ] Edge Function `sync-data`: POST (push blob) / GET (pull blob + metadata)
- [ ] Auth: Supabase JWT obligatoire
- [ ] Rate limit: 100 req/min par user
- [ ] Max blob size: 10MB
- [ ] Versioning: `blob_version` incremental

---

### S7-4 · Background Sync
**Priority:** P1  
**Sprint:** S8  
**FR:** FR23  
**Acceptance Criteria:**
- [ ] iOS: `BGAppRefreshTask` + `BGProcessingTask` (interval 6-12h)
- [ ] Android: `WorkManager` periodic (interval 6-12h, WiFi constraint)
- [ ] Battery budget: <5% day (NFR-P6)
- [ ] Non-blocking UI (background thread, pas de freeze)

---

### S7-5 · Manual Sync Trigger
**Priority:** P1  
**Sprint:** S7  
**FR:** FR24  
**Acceptance Criteria:**
- [ ] Bouton "Synchroniser maintenant" dans Settings
- [ ] Progress indicator pendant sync
- [ ] Feedback: "Dernière sync: il y a X minutes" (FR26)

---

### S7-6 · Conflict Resolution UI
**Priority:** P1  
**Sprint:** S8-S9  
**FR:** FR25  
**Acceptance Criteria:**
- [ ] Notification quand conflit détecté
- [ ] Écran conflit: comparaison côte à côte (device vs server)
- [ ] 3 choix: garder device, garder serveur, fusionner manuellement
- [ ] Default: last-write-wins (si user ne répond pas sous 24h)

---

### S7-7 · Sync Opt-in & Settings
**Priority:** P1  
**Sprint:** S7  
**Acceptance Criteria:**
- [ ] Cloud sync désactivé par défaut (opt-in dans Settings)
- [ ] Explication claire: "Tes données sont chiffrées. Le serveur ne peut pas les lire."
- [ ] Toggle ON/OFF
- [ ] Status sync visible (dernière sync, prochaine sync programmée)

---

## E8 — Smart Notifications

**Objectif :** Max 1/jour, intelligentes, anti-spam, 50%+ action rate.

**Dépendances :** E4 (intelligence engine pour contenu)

---

### S8-1 · Notification Framework
**Priority:** P1  
**Sprint:** S7  
**FR:** FR29-FR35  
**Acceptance Criteria:**
- [ ] iOS: UNUserNotificationCenter + local notifications
- [ ] Android: NotificationCompat + channels
- [ ] Scheduling engine: max 1 notification/jour enforced
- [ ] Timing contextuel configurable (matin pour énergie, soir pour repos)
- [ ] Permission request at optimal moment (pas à l'onboarding)

---

### S8-2 · Cycle Prediction Notifications
**Priority:** P1  
**Sprint:** S8  
**FR:** FR29-FR30  
**Acceptance Criteria:**
- [ ] 3 jours avant règles prévues: "Règles prévues dans ~3 jours (J{date range}). Prépare-toi ☁️"
- [ ] 3 jours avant ovulation prévue (si assez de données)
- [ ] Deeplink vers Predictions dans l'app

---

### S8-3 · Quick Win & Educational Notifications
**Priority:** P1  
**Sprint:** S8  
**FR:** FR31-FR32  
**Acceptance Criteria:**
- [ ] Quick Win: adaptive (1x/week M1-3, 1x/2 weeks après)
- [ ] Educational Drip: daily J4-J13, auto-stop J14
- [ ] Rich notification avec preview du contenu

---

### S8-4 · Actionable Recommendation Notifications
**Priority:** P1  
**Sprint:** S9  
**Acceptance Criteria:**
- [ ] Format: "☁️ Énergie moyenne prévue demain — Prévois journée douce ?"
- [ ] Actions inline: [Oui, ajusté] [Pas cette fois]
- [ ] Tracking: clicks → `recommendation_followed` event

---

### S8-5 · Smart Anti-Spam Rules
**Priority:** P1  
**Sprint:** S9  
**Acceptance Criteria:**
- [ ] Si user ignore 3x même type → auto-stop cette catégorie
- [ ] Respect Do Not Disturb / Focus modes
- [ ] Aucune notification pendant la nuit (22h-8h default)

---

### S8-6 · Notification Settings UI
**Priority:** P1  
**Sprint:** S8  
**FR:** FR33-FR34  
**Acceptance Criteria:**
- [ ] Toggle ON/OFF par catégorie: Prédictions, Quick Wins, Éducatif, Rappels, Recommandations
- [ ] Customisation heure préférée par catégorie
- [ ] Opt-in daily check-in reminder (OFF par défaut)

---

## E9 — Settings, Privacy & Compliance

**Objectif :** Conformité GDPR totale, expérience Privacy-First, legal compliance App Store/Play Store.

**Dépendances :** E1 (auth, encryption)

---

### S9-1 · Settings Screen Principal
**Priority:** P0  
**Sprint:** S3  
**Acceptance Criteria:**
- [ ] Sections: Profil, Notifications, Privacy & Sécurité, Données, À propos
- [ ] Navigation claire, design Settings iOS natif / Material Android

---

### S9-2 · Privacy Settings
**Priority:** P0  
**Sprint:** S4  
**FR:** FR46  
**Acceptance Criteria:**
- [ ] Toggle biometric lock ON/OFF
- [ ] Configurer auto-lock timeout (1-15 min)
- [ ] Voir Privacy Policy (in-app WebView ou markdown)
- [ ] Voir Terms of Service
- [ ] Badges: 🔒 Chiffrement actif, 🇪🇺 Serveurs EU, ✅ Zéro trackers

---

### S9-3 · Data Export (CSV)
**Priority:** P0  
**Sprint:** S5  
**FR:** FR27  
**Acceptance Criteria:**
- [ ] Export TOUTES les données utilisateur en CSV (GDPR Art. 20 portabilité)
- [ ] Format: 1 CSV par table (cycles, symptoms, insights, predictions)
- [ ] Share sheet natif pour sauvegarder/envoyer
- [ ] Données en clair dans le CSV (déchiffrées avant export)

---

### S9-4 · Account Deletion
**Priority:** P0  
**Sprint:** S5  
**FR:** FR28  
**Acceptance Criteria:**
- [ ] Bouton "Supprimer mon compte et toutes mes données"
- [ ] Double confirmation ("Es-tu sûre ? Cette action est irréversible")
- [ ] Suppression locale: wipe SQLCipher DB + Keychain/Keystore
- [ ] Suppression serveur: delete `encrypted_user_data` + auth user (dans les 30 jours, NFR-C6)
- [ ] Confirmation email: "Tes données ont été supprimées"

---

### S9-5 · Privacy Policy & ToS
**Priority:** P0  
**Sprint:** S3  
**FR:** FR46  
**Acceptance Criteria:**
- [ ] Privacy Policy conforme GDPR (consentement, droits, processors, DPO)
- [ ] Terms of Service conformes App Store 5.1.1 / Google Play policies
- [ ] Rédigé en français (MVP), anglais (Phase 2)
- [ ] Accessible depuis Settings + onboarding

---

### S9-6 · DPIA Documentation
**Priority:** P0  
**Sprint:** S10  
**Acceptance Criteria:**
- [ ] Data Protection Impact Assessment complété (2-4 semaines)
- [ ] Processors listés: Supabase, Plausible, hébergement email
- [ ] DPAs signés avec tous les processors
- [ ] Incident Response Plan documenté (72h notification CNIL)
- [ ] Approuvé par conseil juridique

---

### S9-7 · Analytics Setup (Privacy-Compliant)
**Priority:** P0  
**Sprint:** S2  
**Acceptance Criteria:**
- [ ] Plausible Analytics intégré (EU, cookie-free, €9/mois)
- [ ] Events clés trackés: onboarding completion, quick_win_viewed, export_generated, prediction_feedback
- [ ] **Zéro PII** dans les events analytics
- [ ] Opt-out possible dans Settings
- [ ] Sentry EU pour crash reporting (PII scrubbing activé)

---

### S9-8 · Report Bug Feature
**Priority:** P1  
**Sprint:** S9  
**FR:** NFR-M5  
**Acceptance Criteria:**
- [ ] Settings → "Signaler un bug"
- [ ] Capture: device info, app version, OS version, logs récents
- [ ] **PII scrubbing** avant envoi (aucune donnée santé dans le rapport)
- [ ] User consent obligatoire avant envoi
- [ ] Envoi via email/formulaire minimal

---

## E10 — Beta Polish & Launch

**Objectif :** Performance, accessibilité, QA, DPIA, beta launch 300-500 users.

**Dépendances :** E1-E9 (toutes features MVP)

---

### S10-1 · Performance Optimization
**Priority:** P0  
**Sprint:** S10-S11  
**FR:** NFR-P1 à NFR-P7  
**Acceptance Criteria:**
- [ ] Cold start: <4s (WiFi), <4s (4G)
- [ ] Warm start: <1s
- [ ] Screen transitions: <300ms
- [ ] ML inference: <150ms
- [ ] Sync: <2s (encrypted data upload)
- [ ] Battery: <5% day (background sync)
- [ ] Profiling Instruments (iOS) + Android Profiler: identifier bottlenecks

---

### S10-2 · Accessibility — iOS
**Priority:** P0  
**Sprint:** S11  
**FR:** NFR-A1 à NFR-A6  
**Acceptance Criteria:**
- [ ] Dynamic Type support (100%-200% text scaling)
- [ ] VoiceOver compatible: onboarding, logging, insights, export (4 flows critiques)
- [ ] Color contrast WCAG 2.1 Level AA (4.5:1 normal, 3:1 large)
- [ ] Touch targets minimum 44×44 points
- [ ] Reduce Motion respecté (animations désactivées)
- [ ] Form labels + error messages accessibles

---

### S10-3 · Accessibility — Android
**Priority:** P0  
**Sprint:** S11  
**Acceptance Criteria:**
- [ ] TalkBack compatible (mêmes 4 flows)
- [ ] Touch targets minimum 48×48dp
- [ ] Contrast ratio WCAG AA
- [ ] Font scaling support

---

### S10-4 · Localization FR
**Priority:** P0  
**Sprint:** S10  
**FR:** NFR-L1, NFR-L3, NFR-L4  
**Acceptance Criteria:**
- [ ] Tous les strings UI en français (Localizable.strings / strings.xml)
- [ ] Date format DD/MM/YYYY (locale française)
- [ ] Timezone UTC serveur, local client
- [ ] Contenu éducatif `tips_fr.json` complet (10 tips)
- [ ] Templates export PDF en français

---

### S10-5 · QA & Integration Testing
**Priority:** P0  
**Sprint:** S11-S12  
**Acceptance Criteria:**
- [ ] Tests unitaires: >80% coverage sur Domain layer
- [ ] Tests intégration: encryption round-trip, sync flow, export generation
- [ ] Tests UI: onboarding flow, tracking flow, export flow (3 flows critiques)
- [ ] Tests regression: chaque bug fixé = test ajouté
- [ ] Crash-free rate target: 99.9%+

---

### S10-6 · Security Audit Preparation
**Priority:** P0  
**Sprint:** S12  
**Acceptance Criteria:**
- [ ] Third-party security audit planifié (€10K-25K budget)
- [ ] Dependency scanning CI/CD fonctionnel (zero known vulnerabilities)
- [ ] Certificate pinning validé
- [ ] Encryption implementation peer-reviewed
- [ ] Product liability insurance souscrite (€2M-5M)

---

### S10-7 · App Store & Play Store Preparation
**Priority:** P0  
**Sprint:** S12  
**Acceptance Criteria:**
- [ ] App Store Connect: app créée, metadata, screenshots, privacy labels
- [ ] Play Console: app créée, store listing, data safety section
- [ ] Age rating: 12+ (reproductive health content)
- [ ] Review guidelines compliance check (5.1.1 health data)
- [ ] Beta distribution: TestFlight (iOS) + Internal Track (Android)

---

### S10-8 · Beta Launch
**Priority:** P0  
**Sprint:** S13  
**Acceptance Criteria:**
- [ ] 300-500 beta users recrutés (forums SOPK/Endo, EndoFrance, Sopk.fr)
- [ ] Feedback channels configurés (in-app bug report, email, formulaire NPS)
- [ ] Analytics dashboards opérationnels (Daily, Weekly cadence)
- [ ] Leading indicators monitoring actif (D1 retention, Quick Win delivery, crash rate)
- [ ] Go/No-Go M6 decision framework activé

---

## Appendice : Sprint Planning Overview

```
S0  (Week 0)     │ Spike Week: Encryption PoC, Widget Blur, ML Model
S1  (M1 W1-2)    │ E1: Project setup iOS/Android/Supabase, Encryption layers
S2  (M1 W3-4)    │ E1: DB, Biometric auth, Cert pinning | E2: Cycle tracking
S3  (M2 W1-2)    │ E2: Symptoms, Body Map starts | E3: Onboarding | E9: Settings base
S4  (M2 W3-4)    │ E2: Body Map, Dashboard | E3: First action, Quick Win J1 | E4: Rule Engine start
S5  (M3 W1-2)    │ E3: Quick Win J3, Ed Drip | E4: Explainable AI, Insights UI | E5: Widget provider
S6  (M3 W3-4)    │ E4: ML Engine, Predictions UI | E5: iOS Widgets | E6: PDF Engine | E7: Sync API
S7  (M4 W1-2)    │ E4: Feedback loop, Reco | E5: Android Widget | E6: Templates | E7: Sync Engine
S8  (M4 W3-4)    │ E6: Share flow | E7: Background sync, Conflicts | E8: Notif framework
S9  (M5 W1-2)    │ E7: Conflict UI | E8: Smart notifs, Anti-spam | E9: Bug report
S10 (M5 W3-4)    │ E9: DPIA | E10: Performance opt, Localization FR
S11 (M6 W1-2)    │ E10: Accessibility iOS/Android, QA testing
S12 (M6 W3-4)    │ E10: Security audit prep, App Store prep
S13 (M6 W5)      │ E10: Beta launch 🚀
```

---

## Appendice : FR → Story Traceability

| FR | Story | Epic |
|----|-------|------|
| FR1 (Cycle dates + flow) | S2-1 | E2 |
| FR2 (30+ symptoms) | S2-2 | E2 |
| FR3-FR4 (Body Map) | S2-3 | E2 |
| FR5 (Mood, energy, sleep, stress) | S2-4 to S2-7 | E2 |
| FR6 (3-year history) | S2-1 | E2 |
| FR7 (Edit/delete entries) | S2-1 | E2 |
| FR8-FR9 (Predictions) | S4-1, S4-3, S4-7 | E4 |
| FR10 (Correlations) | S4-1 | E4 |
| FR11 (Phase-based advice) | S4-2, S4-8 | E4 |
| FR12 (Feedback loop) | S4-5 | E4 |
| FR13 (ML transparency) | S4-2 | E4 |
| FR14 (Quick Wins J1-J3) | S3-6, S3-7 | E3 |
| FR15 (Educational Drip) | S3-8 | E3 |
| FR16-FR17 (PDF templates) | S6-1 to S6-3 | E6 |
| FR18 (Email export) | S6-6 | E6 |
| FR19 (Shareable link) | S6-6, S6-7 | E6 |
| FR20 (Notes doctor) | S6-4 | E6 |
| FR21 (Disclaimer export) | S6-1 | E6 |
| FR22 (Local encryption) | S1-6, S1-7 | E1 |
| FR23-FR26 (Sync) | S7-1 to S7-7 | E7 |
| FR27 (CSV export) | S9-3 | E9 |
| FR28 (Account deletion) | S9-4 | E9 |
| FR29-FR35 (Notifications) | S8-1 to S8-6 | E8 |
| FR36-FR41 (Widgets) | S5-1 to S5-6 | E5 |
| FR42-FR48 (Privacy/Security) | S1-8 to S1-10, S9-1 to S9-5 | E1, E9 |

---

_Document créé: 2026-02-10_  
_Source: PRD ShifAI (FR1-FR48, NFRs), Architecture Decision Document_
_Total: 10 Epics, 80 Stories, 13 Sprints (Spike Week 0 + M1-M6)_
