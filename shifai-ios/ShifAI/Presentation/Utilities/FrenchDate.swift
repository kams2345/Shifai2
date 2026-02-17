import Foundation

/// French Date Formatters — centralized date formatting for the app.
/// All formats use French locale.
enum FrenchDate {

    private static let frenchLocale = Locale(identifier: "fr-FR")

    // MARK: - Formatters

    /// "14 février 2026"
    static let full: DateFormatter = {
        let f = DateFormatter()
        f.locale = frenchLocale
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()

    /// "14 fév. 2026"
    static let medium: DateFormatter = {
        let f = DateFormatter()
        f.locale = frenchLocale
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    /// "14/02/2026"
    static let short: DateFormatter = {
        let f = DateFormatter()
        f.locale = frenchLocale
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    /// "Lundi 14 février"
    static let dayAndMonth: DateFormatter = {
        let f = DateFormatter()
        f.locale = frenchLocale
        f.dateFormat = "EEEE d MMMM"
        return f
    }()

    /// "Fév. 2026"
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.locale = frenchLocale
        f.dateFormat = "MMM yyyy"
        return f
    }()

    /// "14:30"
    static let time: DateFormatter = {
        let f = DateFormatter()
        f.locale = frenchLocale
        f.dateFormat = "HH:mm"
        return f
    }()

    // MARK: - Convenience

    static func relative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = frenchLocale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    static func cycleDay(_ day: Int, phase: String) -> String {
        "Jour \(day) — \(phase)"
    }

    static func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days == 0 { return "Aujourd'hui" }
        if days == 1 { return "Demain" }
        return "Dans \(days) jours"
    }
}
