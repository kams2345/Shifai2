import Foundation
import SwiftUI

/// Export ViewModel — medical PDF generation for healthcare providers.
/// Templates: SOPK, Endométriose, Personnalisé.
/// Mirrors Android ExportViewModel.kt.
@MainActor
final class ExportViewModel: ObservableObject {

    enum Template: String, CaseIterable, Identifiable {
        case sopk = "SOPK"
        case endometriosis = "Endométriose"
        case custom = "Personnalisé"

        var id: String { rawValue }

        var sections: [String] {
            switch self {
            case .sopk: return ["Cycles", "Symptômes hormones", "Poids & humeur", "Graphiques"]
            case .endometriosis: return ["Douleurs", "Localisation", "Impact quotidien", "Traitements"]
            case .custom: return ["Cycles", "Symptômes", "Prédictions", "Notes"]
            }
        }
    }

    enum DateRange: Int, CaseIterable, Identifiable {
        case threeMonths = 3
        case sixMonths = 6
        case twelveMonths = 12

        var id: Int { rawValue }
        var label: String { "\(rawValue) mois" }
    }

    @Published var selectedTemplate: Template = .sopk
    @Published var selectedRange: DateRange = .threeMonths
    @Published var isGenerating = false
    @Published var pdfData: Data?
    @Published var error: ShifAIError?

    let disclaimer = "Ce document est informatif uniquement. Il ne constitue pas un avis médical."

    func generatePDF() async {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            // TODO: fetch data from repository, render PDF
            try await Task.sleep(nanoseconds: 500_000_000)
            pdfData = Data() // placeholder
        } catch {
            self.error = .exportGenerationFailed
        }
    }

    var canShare: Bool { pdfData != nil }

    func reset() {
        pdfData = nil
        error = nil
    }
}
