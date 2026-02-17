import Foundation

/// Unified error types for the ShifAI app.
/// Used across all layers (network, database, domain).
enum ShifAIError: Error, LocalizedError, Equatable {

    // ─── Network ───
    case networkUnavailable
    case serverError(statusCode: Int)
    case unauthorized
    case conflict
    case timeout

    // ─── Database ───
    case databaseCorrupted
    case migrationFailed(version: Int)
    case recordNotFound(table: String, id: String)

    // ─── Domain ───
    case insufficientData(required: Int, actual: Int)
    case invalidInput(field: String, reason: String)
    case mlModelUnavailable
    case encryptionFailed

    // ─── Sync ───
    case syncConflict(localDate: Date, remoteDate: Date)
    case syncTimeout
    case mergeFailure

    // ─── Export ───
    case exportTooLarge(sizeMB: Int, maxMB: Int)
    case templateNotFound(name: String)
    case pdfGenerationFailed

    // ─── Auth ───
    case biometricNotAvailable
    case biometricFailed
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "Pas de connexion internet"
        case .serverError(let code): return "Erreur serveur (\(code))"
        case .unauthorized: return "Session expirée"
        case .conflict: return "Conflit de données"
        case .timeout: return "Délai dépassé"
        case .databaseCorrupted: return "Base de données corrompue"
        case .migrationFailed(let v): return "Échec de migration v\(v)"
        case .recordNotFound(let t, let id): return "Enregistrement \(id) non trouvé dans \(t)"
        case .insufficientData(let req, let act): return "Données insuffisantes (\(act)/\(req) requis)"
        case .invalidInput(let f, let r): return "Entrée invalide: \(f) — \(r)"
        case .mlModelUnavailable: return "Modèle ML non disponible"
        case .encryptionFailed: return "Échec du chiffrement"
        case .syncConflict: return "Conflit de synchronisation"
        case .syncTimeout: return "Synchronisation expirée"
        case .mergeFailure: return "Échec de fusion"
        case .exportTooLarge(let s, let m): return "Export trop volumineux (\(s)MB, max \(m)MB)"
        case .templateNotFound(let n): return "Template '\(n)' non trouvé"
        case .pdfGenerationFailed: return "Échec génération PDF"
        case .biometricNotAvailable: return "Biométrie non disponible"
        case .biometricFailed: return "Authentification biométrique échouée"
        case .sessionExpired: return "Session expirée"
        }
    }

    /// User-facing recovery suggestion
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable: return "Vérifie ta connexion et réessaie."
        case .unauthorized, .sessionExpired: return "Reconnecte-toi à ton compte."
        case .timeout, .syncTimeout: return "Réessaie dans quelques instants."
        case .databaseCorrupted: return "Contacte le support."
        case .insufficientData: return "Continue à logger tes données."
        case .biometricNotAvailable: return "Active Face ID dans les réglages."
        default: return "Réessaie ou contacte le support."
        }
    }
}
