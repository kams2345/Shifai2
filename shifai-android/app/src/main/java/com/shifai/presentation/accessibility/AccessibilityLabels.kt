package com.shifai.presentation.accessibility

/**
 * Accessibility Labels — TalkBack content descriptions in French.
 * Centralized for consistent accessibility across all screens.
 * Mirrors iOS AccessibilityLabels.swift.
 */
object AccessibilityLabels {

    // ─── Dashboard ───

    object Dashboard {
        const val CYCLE_DAY = "Jour du cycle"
        const val PHASE_INDICATOR = "Phase du cycle actuelle"
        const val NEXT_PREDICTION = "Prochaine prédiction"
        const val MOOD_SCORE = "Score d'humeur"
        const val ENERGY_PROGRESS = "Niveau d'énergie"
    }

    // ─── Tracking ───

    object Tracking {
        const val FLOW_SLIDER = "Intensité du flux"
        const val FLOW_HINT = "Ajustez entre 0 et 4"
        const val MOOD_SLIDER = "Humeur"
        const val MOOD_HINT = "Ajustez entre 1 et 10"
        const val SLEEP_SLIDER = "Heures de sommeil"
        const val SLEEP_HINT = "Ajustez entre 0 et 24 heures"
        const val SAVE_BUTTON = "Enregistrer les données du jour"
        const val BODY_MAP = "Carte corporelle interactive"
        const val BODY_MAP_HINT = "Appuyez pour sélectionner une zone de symptôme"
    }

    // ─── Insights ───

    object Insights {
        const val INSIGHT_CARD = "Carte d'analyse"
        const val FILTER_MENU = "Filtrer les analyses"
        const val FEEDBACK_POSITIVE = "Marquer comme utile"
        const val FEEDBACK_NEGATIVE = "Marquer comme pas utile"
        const val UNREAD_BADGE = "Analyses non lues"
    }

    // ─── Settings ───

    object Settings {
        const val SYNC_TOGGLE = "Synchronisation automatique"
        const val BIOMETRIC_TOGGLE = "Verrouillage biométrique"
        const val EXPORT_BUTTON = "Exporter mes données"
        const val DELETE_ACCOUNT = "Supprimer mon compte"
        const val DELETE_HINT = "Action irréversible. Toutes vos données seront supprimées."
    }

    // ─── Common ───

    object Common {
        const val LOADING = "Chargement en cours"
        const val ERROR = "Une erreur est survenue"
        const val RETRY = "Réessayer"
        const val BACK = "Retour"
        const val CLOSE = "Fermer"
    }
}
