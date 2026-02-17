# Data Protection Impact Assessment (DPIA)
## ShifAI — Évaluation d'impact sur la protection des données

**Date**: 12 février 2026
**Version**: 1.0
**Responsable**: Équipe ShifAI

---

## 1. Description du traitement

| Élément | Détail |
|---------|--------|
| **Nom** | ShifAI — Suivi de cycle menstruel intelligent |
| **Nature** | Collecte, stockage et analyse de données de santé |
| **Portée** | Utilisatrices dans l'UE (France principalement) |
| **Contexte** | Application mobile (iOS/Android) avec backend cloud |
| **Finalité** | Suivi personnel de cycle et bien-être, prédictions via IA |

## 2. Catégories de données

| Catégorie | Données | Sensibilité | Base légale |
|-----------|---------|-------------|-------------|
| **Cycle** | Jour, phase, flux, durée | Santé (Art. 9) | Consentement explicite |
| **Symptômes** | 29 types, intensité, zone corporelle | Santé | Consentement explicite |
| **Bien-être** | Humeur, énergie, sommeil, stress | Santé | Consentement explicite |
| **Prédictions** | Dates prédites, confiance | Dérivée | Intérêt légitime |
| **Technique** | UUID appareil, version app | Non sensible | Intérêt légitime |
| **Compte** | Email (optionnel pour sync) | Personnelle | Contrat |

> [!CAUTION]
> Les données de cycle et symptômes sont des **données de santé** au sens de l'Art. 9 du RGPD. Le consentement explicite est requis.

## 3. Architecture de sécurité

### 3.1 Chiffrement
- **Au repos** : SQLCipher (AES-256-CBC) sur l'appareil
- **En transit** : TLS 1.3 avec certificate pinning
- **Sync cloud** : AES-256-GCM (chiffrement côté client)
- **Clés** : Keychain (iOS) / Keystore (Android)

### 3.2 Architecture Zero-Knowledge
Le serveur **ne peut pas lire** les données utilisateur :
- Les données sont chiffrées avant envoi
- La clé de chiffrement ne quitte jamais l'appareil
- Le serveur stocke des blobs chiffrés opaques
- Les Edge Functions n'accèdent qu'aux métadonnées (timestamps, user_id)

### 3.3 Contrôle d'accès
- Authentification biométrique (Face ID / empreinte)
- Row Level Security (RLS) sur PostgreSQL
- JWT avec expiration courte (1h)
- Pas de compte admin ayant accès aux données

## 4. Évaluation des risques

| Risque | Probabilité | Impact | Mesures |
|--------|-------------|--------|---------|
| Fuite de données serveur | Faible | Faible | Zero-knowledge, données illisibles |
| Vol de téléphone | Moyenne | Moyen | Biométrie + SQLCipher |
| Interception réseau | Faible | Faible | TLS 1.3 + cert pinning |
| Accès non autorisé | Faible | Moyen | RLS + JWT |
| Perte de données | Faible | Moyen | Sync cloud chiffrée |
| Profilage par un tiers | Nulle | N/A | Pas de SDK tiers, pas de trackers |
| Usage abusif des prédictions | Faible | Moyen | Disclaimer médical, pas de diagnostic |

## 5. Droits des personnes

| Droit | Méthode |
|-------|---------|
| **Accès** (Art. 15) | Export CSV/PDF dans l'app |
| **Rectification** (Art. 16) | Édition directe dans l'app |
| **Effacement** (Art. 17) | Bouton "Supprimer mon compte" → Edge Function cascade |
| **Portabilité** (Art. 20) | Export CSV format standard |
| **Opposition** (Art. 21) | Désactivation analytics + sync |
| **Limitation** (Art. 18) | Désactivation sync cloud |

## 6. Sous-traitants

| Sous-traitant | Service | Localisation | Conformité |
|---------------|---------|-------------|------------|
| Supabase | Backend (DB, Auth, Storage) | UE (aws-eu-central-1) | RGPD, SOC2 |
| Plausible | Analytics anonymes | UE | RGPD, pas de cookies |
| Apple | Distribution iOS | Global | DPA signé |
| Google | Distribution Android | Global | DPA signé |

> [!IMPORTANT]
> Aucun sous-traitant n'a accès aux données de santé en clair grâce à l'architecture zero-knowledge.

## 7. Conclusion

Le risque résiduel est **faible** grâce à :
- L'architecture zero-knowledge
- Le chiffrement AES-256 à chaque couche
- L'absence totale de trackers tiers
- L'hébergement exclusif en UE
- Les mécanismes d'exercice des droits intégrés à l'app

**Recommandation** : Procéder au lancement beta. Prévoir un audit de sécurité tiers avant la release publique.

---

*Document conforme aux exigences de l'Art. 35 du RGPD.*
