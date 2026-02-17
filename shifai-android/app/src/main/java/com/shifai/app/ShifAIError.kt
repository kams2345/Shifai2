package com.shifai.app

/**
 * Unified error types for the ShifAI app.
 * Used across all layers (network, database, domain).
 */
sealed class ShifAIError(
    val code: String,
    override val message: String,
    val recoverySuggestion: String
) : Exception(message) {

    // ─── Network ───
    class NetworkUnavailable : ShifAIError(
        "NET_UNAVAILABLE", "Pas de connexion internet",
        "Vérifie ta connexion et réessaie."
    )
    class ServerError(statusCode: Int) : ShifAIError(
        "NET_SERVER", "Erreur serveur ($statusCode)",
        "Réessaie dans quelques instants."
    )
    class Unauthorized : ShifAIError(
        "NET_UNAUTHORIZED", "Session expirée",
        "Reconnecte-toi à ton compte."
    )
    class Timeout : ShifAIError(
        "NET_TIMEOUT", "Délai dépassé",
        "Réessaie dans quelques instants."
    )

    // ─── Database ───
    class DatabaseCorrupted : ShifAIError(
        "DB_CORRUPTED", "Base de données corrompue",
        "Contacte le support."
    )
    class MigrationFailed(version: Int) : ShifAIError(
        "DB_MIGRATION", "Échec de migration v$version",
        "Contacte le support."
    )
    class RecordNotFound(table: String, id: String) : ShifAIError(
        "DB_NOT_FOUND", "Enregistrement $id non trouvé dans $table",
        "Réessaie ou contacte le support."
    )

    // ─── Domain ───
    class InsufficientData(required: Int, actual: Int) : ShifAIError(
        "DOM_INSUFFICIENT", "Données insuffisantes ($actual/$required requis)",
        "Continue à logger tes données."
    )
    class InvalidInput(field: String, reason: String) : ShifAIError(
        "DOM_INVALID", "Entrée invalide: $field — $reason",
        "Vérifie tes données et réessaie."
    )
    class MLModelUnavailable : ShifAIError(
        "DOM_ML", "Modèle ML non disponible",
        "Le mode règles sera utilisé."
    )
    class EncryptionFailed : ShifAIError(
        "DOM_ENCRYPT", "Échec du chiffrement",
        "Contacte le support."
    )

    // ─── Sync ───
    class SyncConflict : ShifAIError(
        "SYNC_CONFLICT", "Conflit de synchronisation",
        "Choisis quelle version garder."
    )
    class SyncTimeout : ShifAIError(
        "SYNC_TIMEOUT", "Synchronisation expirée",
        "Réessaie dans quelques instants."
    )

    // ─── Export ───
    class ExportTooLarge(sizeMB: Int, maxMB: Int) : ShifAIError(
        "EXPORT_SIZE", "Export trop volumineux (${sizeMB}MB, max ${maxMB}MB)",
        "Réduis la période sélectionnée."
    )
    class PDFGenerationFailed : ShifAIError(
        "EXPORT_PDF", "Échec génération PDF",
        "Réessaie ou contacte le support."
    )

    // ─── Auth ───
    class BiometricNotAvailable : ShifAIError(
        "AUTH_BIO_NA", "Biométrie non disponible",
        "Active Face ID dans les réglages."
    )
    class BiometricFailed : ShifAIError(
        "AUTH_BIO_FAIL", "Authentification biométrique échouée",
        "Réessaie."
    )
    class SessionExpired : ShifAIError(
        "AUTH_EXPIRED", "Session expirée",
        "Reconnecte-toi à ton compte."
    )
}
