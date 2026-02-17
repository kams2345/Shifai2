# Politique de Confidentialité — ShifAI

*Dernière mise à jour : 12 février 2026*

## 1. Qui sommes-nous ?

ShifAI est une application de suivi de santé menstruelle développée par ShifAI SAS, société de droit français. Nous sommes le responsable de traitement de vos données personnelles au sens du RGPD.

## 2. Notre engagement

**Votre vie privée est notre priorité absolue.** ShifAI est conçue sur une architecture « zero-knowledge » : nous ne pouvons jamais voir, lire ou analyser vos données de santé.

## 3. Données collectées

### 3.1 Données de santé (traitées localement)
- Dates de cycle, flux, symptômes, humeur, énergie, sommeil, stress
- Ces données sont **chiffrées avec AES-256-GCM** sur votre appareil
- Elles ne quittent votre appareil que sous forme chiffrée (synchronisation)
- Nous **ne pouvons pas les déchiffrer** — seul votre appareil possède la clé

### 3.2 Données de compte
- Adresse email (authentification uniquement)
- Aucun nom, prénom, numéro de téléphone ou adresse requis

### 3.3 Analytiques (opt-in)
- Événements d'utilisation anonymes via Plausible (hébergé EU)
- **Zéro cookies, zéro trackers, zéro PII**
- Activable/désactivable dans Réglages → Vie Privée
- Données utilisées uniquement pour améliorer l'application

## 4. Base légale

| Traitement | Base légale (RGPD) |
|-----------|-------------------|
| Données de santé | Consentement explicite (Art. 9.2.a) |
| Compte | Exécution du contrat (Art. 6.1.b) |
| Analytiques | Consentement (Art. 6.1.a) |
| Notifications | Intérêt légitime (Art. 6.1.f) |

## 5. Hébergement et sécurité

- **Serveurs** : Supabase, région EU (eu-west-1) exclusivement
- **Chiffrement au repos** : AES-256-GCM + SQLCipher
- **Chiffrement en transit** : TLS 1.3 + Certificate Pinning
- **Gestion des clés** : Keychain (iOS) / Keystore (Android)
- **Architecture** : Zero-knowledge — le serveur ne stocke que des blobs chiffrés
- **Pas de transfert** hors UE/EEE

## 6. Partage de données

Nous **ne vendons, ne louons et ne partageons aucune donnée** avec des tiers.

Exceptions :
- **Export médical** : vous choisissez de partager un PDF avec votre médecin
- **Sous-traitants** : Supabase (hébergement EU), Plausible (analytics EU)

## 7. Vos droits (RGPD)

| Droit | Comment l'exercer |
|-------|------------------|
| Accès (Art. 15) | Réglages → Données → Exporter CSV |
| Portabilité (Art. 20) | Export CSV ou PDF médical |
| Rectification (Art. 16) | Modification directe dans l'app |
| Suppression (Art. 17) | Réglages → Supprimer mon compte |
| Opposition (Art. 21) | Désactiver les analytiques dans Réglages |
| Limitation (Art. 18) | Contacter privacy@shifai.app |

La suppression de compte est **irréversible** et entraîne la destruction complète de toutes vos données dans un délai de 24 heures.

## 8. Conservation des données

- **Données de santé** : conservées tant que le compte est actif
- **Après suppression** : destruction complète sous 24h + log de conformité (30 jours)
- **Exports partagés** : TTL de 7 jours par défaut, suppression automatique

## 9. Mineurs

ShifAI est destinée aux personnes de **16 ans et plus**. L'utilisation par des mineurs de moins de 16 ans nécessite le consentement parental.

## 10. Modifications

Toute modification substantielle sera notifiée dans l'application 30 jours avant son entrée en vigueur.

## 11. Contact

- **DPO** : privacy@shifai.app
- **Autorité de contrôle** : CNIL (www.cnil.fr)

---

*ShifAI SAS — Siège social : Paris, France*
*SIRET : [à compléter]*
