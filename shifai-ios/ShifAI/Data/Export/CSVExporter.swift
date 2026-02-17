import Foundation

/// CSV Exporter — exports user data for GDPR portability (Art. 20).
/// Generates CSV files for cycle entries and symptom logs.
final class CSVExporter {

    enum ExportError: Error {
        case noData
        case writeError(String)
    }

    // MARK: - Cycle Entries

    static func exportCycleEntries(_ entries: [CycleEntry]) throws -> URL {
        guard !entries.isEmpty else { throw ExportError.noData }

        let header = "date,cycle_day,phase,flow_intensity,mood_score,energy_score,sleep_hours,stress_level,notes\n"
        let rows = entries.map { e in
            let dateStr = ISO8601DateFormatter().string(from: e.date)
            let notes = e.notes.replacingOccurrences(of: ",", with: ";")
                              .replacingOccurrences(of: "\n", with: " ")
            return "\(dateStr),\(e.cycleDay),\(e.phase.rawValue),\(e.flowIntensity),\(e.moodScore),\(e.energyScore),\(e.sleepHours),\(e.stressLevel),\"\(notes)\""
        }.joined(separator: "\n")

        let csv = header + rows
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("shifai_cycle_entries_\(dateStamp()).csv")

        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Symptom Logs

    static func exportSymptomLogs(_ symptoms: [SymptomLog]) throws -> URL {
        guard !symptoms.isEmpty else { throw ExportError.noData }

        let header = "cycle_entry_id,category,symptom_type,intensity,body_zone\n"
        let rows = symptoms.map { s in
            "\(s.cycleEntryId),\(s.category),\(s.symptomType),\(s.intensity),\(s.bodyZone ?? "")"
        }.joined(separator: "\n")

        let csv = header + rows
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("shifai_symptoms_\(dateStamp()).csv")

        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Full Export (ZIP-like bundle)

    static func exportAll(entries: [CycleEntry], symptoms: [SymptomLog]) throws -> [URL] {
        var urls: [URL] = []
        if !entries.isEmpty { urls.append(try exportCycleEntries(entries)) }
        if !symptoms.isEmpty { urls.append(try exportSymptomLogs(symptoms)) }
        if urls.isEmpty { throw ExportError.noData }
        return urls
    }

    // MARK: - Helpers

    private static func dateStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
