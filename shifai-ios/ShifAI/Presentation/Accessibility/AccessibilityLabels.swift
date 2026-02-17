import SwiftUI

/// Accessibility Helpers — VoiceOver labels and hints in French.
/// Centralized to ensure consistent accessibility across all views.
enum AccessibilityLabels {

    // MARK: - Dashboard

    enum Dashboard {
        static let cycleDay = "Jour du cycle"
        static let phaseIndicator = "Phase du cycle actuelle"
        static let nextPrediction = "Prochaine prédiction"
        static let moodScore = "Score d'humeur"
        static let energyProgress = "Niveau d'énergie"
    }

    // MARK: - Tracking

    enum Tracking {
        static let flowSlider = "Intensité du flux"
        static let flowHint = "Ajustez entre 0 et 4"
        static let moodSlider = "Humeur"
        static let moodHint = "Ajustez entre 1 et 10"
        static let sleepSlider = "Heures de sommeil"
        static let sleepHint = "Ajustez entre 0 et 24 heures"
        static let saveButton = "Enregistrer les données du jour"
        static let bodyMap = "Carte corporelle interactive"
        static let bodyMapHint = "Appuyez pour sélectionner une zone de symptôme"
    }

    // MARK: - Insights

    enum Insights {
        static let insightCard = "Carte d'analyse"
        static let filterMenu = "Filtrer les analyses"
        static let feedbackPositive = "Marquer comme utile"
        static let feedbackNegative = "Marquer comme pas utile"
        static let unreadBadge = "Analyses non lues"
    }

    // MARK: - Settings

    enum Settings {
        static let syncToggle = "Synchronisation automatique"
        static let biometricToggle = "Verrouillage biométrique"
        static let exportButton = "Exporter mes données"
        static let deleteAccount = "Supprimer mon compte"
        static let deleteHint = "Action irréversible. Toutes vos données seront supprimées."
    }

    // MARK: - Common

    enum Common {
        static let loading = "Chargement en cours"
        static let error = "Une erreur est survenue"
        static let retry = "Réessayer"
        static let back = "Retour"
        static let close = "Fermer"
    }
}
