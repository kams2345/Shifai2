# Politique de Confidentialite - ShifAI

**Derniere mise a jour :** 17 fevrier 2026  
**Version :** 1.0

## 1. Responsable du traitement

ShifAI  
Contact : privacy@shifai.app

## 2. Donnees collectees

### 2.1 Donnees de sante (Article 9 RGPD)

| Donnee | Finalite | Base legale |
|--------|----------|-------------|
| Dates de cycle | Suivi et predictions | Consentement explicite |
| Intensite du flux | Analyse de tendances | Consentement explicite |
| Symptomes (29 types) | Detection de patterns | Consentement explicite |
| Humeur, energie, sommeil, stress | Correlations | Consentement explicite |
| Zones corporelles | Suivi symptomatique | Consentement explicite |

### 2.2 Donnees techniques

| Donnee | Finalite | Base legale |
|--------|----------|-------------|
| Identifiant anonyme | Synchronisation | Interet legitime |
| Metriques de performance | Amelioration de l'app | Interet legitime |
| Evenements d'usage (anonymes) | Statistiques | Consentement |

### 2.3 Donnees NON collectees

- **Aucun** nom, prenom, email (sauf creation de compte volontaire)
- **Aucun** numero de telephone
- **Aucun** contact, photo, localisation
- **Aucun** identifiant publicitaire

## 3. Chiffrement et securite

- **Au repos** : AES-256-GCM via SQLCipher (cle generee sur l'appareil)
- **En transit** : TLS 1.3 avec certificate pinning
- **Zero-knowledge** : les donnees sont chiffrees avant envoi au serveur
- **Cle de chiffrement** : stockee dans Keychain (iOS) / Keystore (Android), jamais transmise
- Le serveur **ne peut pas** lire vos donnees

## 4. Hebergement

- **Serveurs** : Union Europeenne uniquement (aws-eu-central-1)
- **Fournisseur** : Supabase (conforme RGPD, DPA signe)

## 5. Partage de donnees

ShifAI **ne partage jamais** vos donnees avec des tiers.

Exceptions :
- **Export medical** : vous pouvez generer un rapport PDF et le partager vous-meme avec votre medecin via un lien temporaire (72h)
- **HealthKit / Health Connect** : synchronisation optionnelle, activee par vous uniquement

## 6. Duree de conservation

| Donnee | Duree |
|--------|-------|
| Donnees de cycle | Jusqu'a suppression du compte |
| Liens de partage | 72 heures (suppression automatique) |
| Metriques de performance | 30 jours |
| Logs d'erreurs anonymes | 30 jours |

## 7. Vos droits (RGPD)

Vous avez le droit de :

- **Acceder** a vos donnees (export CSV/PDF dans l'app)
- **Rectifier** vos donnees (modification directe dans l'app)
- **Supprimer** vos donnees (suppression du compte = suppression totale)
- **Porter** vos donnees (export CSV)
- **Retirer** votre consentement a tout moment
- **Deposer une plainte** aupres de la CNIL

### Exercer vos droits

- **Dans l'app** : Parametres → Mes donnees
- **Par email** : privacy@shifai.app
- **Suppression du compte** : Parametres → Supprimer mon compte (irreversible)

Delai de reponse : 30 jours maximum.

## 8. Cookies et trackers

- **Aucun cookie**
- **Aucun tracker tiers** (pas de Facebook, Google Analytics, etc.)
- Analytique via **Plausible** uniquement (anonyme, sans cookies, conforme RGPD)

## 9. Mineurs

ShifAI est destine aux personnes de **16 ans et plus**. Aucune donnee de mineur de moins de 16 ans n'est collectee sciemment.

## 10. Modifications

Toute modification de cette politique sera notifiee dans l'application. La version actuelle est toujours disponible dans Parametres → Politique de confidentialite.

## 11. Contact

Pour toute question relative a la protection de vos donnees :  
**privacy@shifai.app**
