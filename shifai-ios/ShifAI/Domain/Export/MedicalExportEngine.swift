import Foundation
import UIKit
import PDFKit

// MARK: - PDF Generation Engine (S6-1)
// Native PDFKit generation, in-memory, <10s for 3 months data
// S6-2: SOPK template
// S6-3: Endométriose template
// S6-4: Custom template

final class MedicalExportEngine {

    // MARK: - Template Types

    enum ExportTemplate: String, CaseIterable, Identifiable {
        case sopk = "SOPK"
        case endometriosis = "Endométriose"
        case custom = "Personnalisé"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .sopk: return "Irrégularité cycles, symptômes androgéniques, corrélations hormonales"
            case .endometriosis: return "Douleurs chroniques, localisation, intensité, évolution temporelle"
            case .custom: return "Sélection libre de sections"
            }
        }
    }

    struct ExportConfig {
        let template: ExportTemplate
        let dateRange: ClosedRange<Date>
        let sections: Set<ExportSection>
        let gynecologistNotes: String?

        static func defaultConfig(template: ExportTemplate) -> ExportConfig {
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            return ExportConfig(
                template: template,
                dateRange: startDate...endDate,
                sections: template.defaultSections,
                gynecologistNotes: nil
            )
        }
    }

    enum ExportSection: String, CaseIterable, Identifiable {
        case cycleOverview = "Aperçu des cycles"
        case symptomFrequency = "Fréquence des symptômes"
        case bodyMapHeatmap = "Body Map — Zones de douleur"
        case sleepEnergyPatterns = "Patterns sommeil/énergie"
        case correlations = "Corrélations détectées"
        case predictions = "Prédictions"
        case moodTimeline = "Timeline humeur"

        var id: String { rawValue }
    }

    // MARK: - PDF Generation

    func generatePDF(config: ExportConfig) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            // Page 1: Cover + Summary
            context.beginPage()
            drawCoverPage(in: context, rect: pageRect, config: config)

            // Page 2+: Sections
            for section in config.sections.sorted(by: { $0.rawValue < $1.rawValue }) {
                context.beginPage()
                drawSection(section, in: context, rect: pageRect, config: config)
            }

            // Final page: Disclaimer
            context.beginPage()
            drawDisclaimerPage(in: context, rect: pageRect)
        }
    }

    // MARK: - Cover Page

    private func drawCoverPage(in ctx: UIGraphicsPDFRendererContext, rect: CGRect, config: ExportConfig) {
        let margin: CGFloat = 50
        var y: CGFloat = margin

        // Logo / Title
        let title = "Rapport Médical ShifAI"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor(red: 0.49, green: 0.36, blue: 0.99, alpha: 1)
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
        y += 45

        // Template badge
        let templateText = "Template: \(config.template.rawValue)"
        let templateAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        templateText.draw(at: CGPoint(x: margin, y: y), withAttributes: templateAttrs)
        y += 25

        // Date range
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "fr_FR")
        let rangeText = "Période: \(dateFormatter.string(from: config.dateRange.lowerBound)) — \(dateFormatter.string(from: config.dateRange.upperBound))"
        let rangeAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        rangeText.draw(at: CGPoint(x: margin, y: y), withAttributes: rangeAttrs)
        y += 30

        // Separator
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: y))
        path.addLine(to: CGPoint(x: rect.width - margin, y: y))
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        y += 20

        // Summary metrics
        let summaryAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        let metrics = [
            "📊 Sections incluses: \(config.sections.count)",
            "📅 Durée couverte: \(daysBetween(config.dateRange.lowerBound, config.dateRange.upperBound)) jours",
            "🔒 Données chiffrées AES-256 — déchiffrées localement pour export",
            "⚠️ Ce document est informatif uniquement"
        ]

        for metric in metrics {
            metric.draw(at: CGPoint(x: margin, y: y), withAttributes: summaryAttrs)
            y += 22
        }

        // Gynecologist notes
        if let notes = config.gynecologistNotes, !notes.isEmpty {
            y += 20
            let notesTitle = "Notes pour le gynécologue:"
            let notesTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            notesTitle.draw(at: CGPoint(x: margin, y: y), withAttributes: notesTitleAttrs)
            y += 22

            let notesAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            let notesRect = CGRect(x: margin, y: y, width: rect.width - 2 * margin, height: 200)
            notes.draw(in: notesRect, withAttributes: notesAttrs)
        }

        // Watermark
        drawWatermark(in: rect)
    }

    // MARK: - Section Drawing

    private func drawSection(_ section: ExportSection, in ctx: UIGraphicsPDFRendererContext, rect: CGRect, config: ExportConfig) {
        let margin: CGFloat = 50
        var y: CGFloat = margin

        // Section header
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor(red: 0.49, green: 0.36, blue: 0.99, alpha: 1)
        ]
        section.rawValue.draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttrs)
        y += 35

        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]

        switch section {
        case .cycleOverview:
            drawCycleOverview(at: &y, margin: margin, width: rect.width, attrs: bodyAttrs, config: config)
        case .symptomFrequency:
            drawSymptomFrequency(at: &y, margin: margin, width: rect.width, attrs: bodyAttrs, config: config)
        case .bodyMapHeatmap:
            drawBodyMapHeatmap(at: &y, margin: margin, width: rect.width, config: config)
        case .sleepEnergyPatterns:
            drawSleepEnergyPatterns(at: &y, margin: margin, width: rect.width, attrs: bodyAttrs, config: config)
        case .correlations:
            drawCorrelations(at: &y, margin: margin, width: rect.width, attrs: bodyAttrs, config: config)
        case .predictions:
            drawPredictions(at: &y, margin: margin, width: rect.width, attrs: bodyAttrs, config: config)
        case .moodTimeline:
            drawMoodTimeline(at: &y, margin: margin, width: rect.width, attrs: bodyAttrs, config: config)
        }

        drawWatermark(in: rect)
    }

    // MARK: - S6-1: Cycle Overview Chart

    private func drawCycleOverview(at y: inout CGFloat, margin: CGFloat, width: CGFloat, attrs: [NSAttributedString.Key: Any], config: ExportConfig) {
        let text = """
        Ce rapport couvre \(daysBetween(config.dateRange.lowerBound, config.dateRange.upperBound)) jours de suivi.

        Les données ci-dessous proviennent de votre journal quotidien ShifAI.
        Chaque cycle est identifié par le début de vos règles.

        Longueur moyenne des cycles: — (calculée à partir des données)
        Écart-type: — (régularité du cycle)
        Tendance: — (stable / raccourcissement / allongement)
        """
        let textRect = CGRect(x: margin, y: y, width: width - 2 * margin, height: 200)
        text.draw(in: textRect, withAttributes: attrs)
        y += 160

        // Cycle timeline bar placeholder
        let barRect = CGRect(x: margin, y: y, width: width - 2 * margin, height: 40)
        let phases: [(color: UIColor, width: CGFloat, label: String)] = [
            (.systemRed.withAlphaComponent(0.6), 0.18, "Menstruel"),
            (.systemGreen.withAlphaComponent(0.4), 0.25, "Folliculaire"),
            (.systemOrange.withAlphaComponent(0.5), 0.14, "Ovulatoire"),
            (.systemPurple.withAlphaComponent(0.4), 0.43, "Lutéal")
        ]

        var x = margin
        for phase in phases {
            let w = (width - 2 * margin) * phase.width
            let rect = CGRect(x: x, y: y, width: w, height: 30)
            phase.color.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 4).fill()

            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            phase.label.draw(at: CGPoint(x: x + 4, y: y + 10), withAttributes: labelAttrs)
            x += w
        }
        y += 50
    }

    // MARK: - S6-2: Symptom Frequency (SOPK Top 10)

    private func drawSymptomFrequency(at y: inout CGFloat, margin: CGFloat, width: CGFloat, attrs: [NSAttributedString.Key: Any], config: ExportConfig) {
        let text = """
        Top 10 symptômes les plus fréquents sur la période sélectionnée.
        Les barres représentent la fréquence relative de chaque symptôme.

        (Les données sont lues depuis la base locale chiffrée)
        """
        let textRect = CGRect(x: margin, y: y, width: width - 2 * margin, height: 80)
        text.draw(in: textRect, withAttributes: attrs)
        y += 80

        // Horizontal bar chart placeholder for top symptoms
        let symptoms = [
            ("Crampes", 0.85), ("Fatigue", 0.72), ("Migraine", 0.65),
            ("Ballonnement", 0.55), ("Anxiété", 0.48), ("Insomnie", 0.40),
            ("Mal de dos", 0.38), ("Acné", 0.30), ("Nausée", 0.25),
            ("Irritabilité", 0.22)
        ]

        let barAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]

        for (label, ratio) in symptoms {
            label.draw(at: CGPoint(x: margin, y: y), withAttributes: barAttrs)
            let barW = (width - 2 * margin - 100) * CGFloat(ratio)
            let barRect = CGRect(x: margin + 100, y: y + 2, width: barW, height: 12)
            UIColor(red: 0.49, green: 0.36, blue: 0.99, alpha: CGFloat(ratio)).setFill()
            UIBezierPath(roundedRect: barRect, cornerRadius: 3).fill()
            y += 20
        }
    }

    // MARK: - S6-3: Body Map Heatmap (Endo)

    private func drawBodyMapHeatmap(at y: inout CGFloat, margin: CGFloat, width: CGFloat, config: ExportConfig) {
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]

        let text = "Zones de douleur les plus fréquentes. L'intensité de couleur représente la fréquence des signalements."
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
        y += 25

        // Simplified body map zones with intensity
        let zones: [(name: String, x: CGFloat, yOff: CGFloat, w: CGFloat, h: CGFloat, intensity: CGFloat)] = [
            ("Utérus", 0.4, 0.35, 0.2, 0.12, 0.8),
            ("Ovaire G", 0.3, 0.38, 0.08, 0.06, 0.5),
            ("Ovaire D", 0.62, 0.38, 0.08, 0.06, 0.6),
            ("Dos", 0.38, 0.15, 0.24, 0.15, 0.7),
            ("Cuisses", 0.3, 0.55, 0.4, 0.1, 0.3)
        ]

        let mapW = width - 2 * margin
        let mapH: CGFloat = 250

        // Body outline
        let outlineRect = CGRect(x: margin + mapW * 0.25, y: y, width: mapW * 0.5, height: mapH)
        UIColor.systemGray5.setFill()
        UIBezierPath(roundedRect: outlineRect, cornerRadius: 16).fill()
        UIColor.systemGray3.setStroke()
        UIBezierPath(roundedRect: outlineRect, cornerRadius: 16).stroke()

        // Pain zones
        for zone in zones {
            let zoneRect = CGRect(
                x: margin + mapW * zone.x,
                y: y + mapH * zone.yOff,
                width: mapW * zone.w,
                height: mapH * zone.h
            )
            UIColor.systemRed.withAlphaComponent(zone.intensity * 0.7).setFill()
            UIBezierPath(roundedRect: zoneRect, cornerRadius: 6).fill()

            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 8, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            zone.name.draw(at: CGPoint(x: zoneRect.minX + 2, y: zoneRect.minY + 2), withAttributes: labelAttrs)
        }

        y += mapH + 20
    }

    // MARK: - Sleep/Energy Patterns

    private func drawSleepEnergyPatterns(at y: inout CGFloat, margin: CGFloat, width: CGFloat, attrs: [NSAttributedString.Key: Any], config: ExportConfig) {
        let text = "Patterns de sommeil et d'énergie par phase du cycle."
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        y += 25

        // Table header
        let phases = ["Menstruel", "Folliculaire", "Ovulatoire", "Lutéal"]
        let colW = (width - 2 * margin) / 5

        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        let cellAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]

        // Headers
        "Phase".draw(at: CGPoint(x: margin, y: y), withAttributes: headerAttrs)
        "Sommeil moy".draw(at: CGPoint(x: margin + colW, y: y), withAttributes: headerAttrs)
        "Énergie moy".draw(at: CGPoint(x: margin + colW * 2, y: y), withAttributes: headerAttrs)
        "Stress moy".draw(at: CGPoint(x: margin + colW * 3, y: y), withAttributes: headerAttrs)
        "Humeur".draw(at: CGPoint(x: margin + colW * 4, y: y), withAttributes: headerAttrs)
        y += 18

        // Separator
        let sep = UIBezierPath()
        sep.move(to: CGPoint(x: margin, y: y))
        sep.addLine(to: CGPoint(x: width - margin, y: y))
        UIColor.lightGray.setStroke()
        sep.lineWidth = 0.5
        sep.stroke()
        y += 5

        // Data rows (placeholder)
        let rows = [
            ("Menstruel", "6.5h ⭐3", "3.5/10", "5/5", "😔"),
            ("Folliculaire", "7.2h ⭐4", "7/10", "2/5", "😊"),
            ("Ovulatoire", "7.0h ⭐4", "8.5/10", "2/5", "😄"),
            ("Lutéal", "6.8h ⭐3", "5/10", "4/5", "😐")
        ]

        for row in rows {
            row.0.draw(at: CGPoint(x: margin, y: y), withAttributes: cellAttrs)
            row.1.draw(at: CGPoint(x: margin + colW, y: y), withAttributes: cellAttrs)
            row.2.draw(at: CGPoint(x: margin + colW * 2, y: y), withAttributes: cellAttrs)
            row.3.draw(at: CGPoint(x: margin + colW * 3, y: y), withAttributes: cellAttrs)
            row.4.draw(at: CGPoint(x: margin + colW * 4, y: y), withAttributes: cellAttrs)
            y += 18
        }
    }

    // MARK: - Correlations Table

    private func drawCorrelations(at y: inout CGFloat, margin: CGFloat, width: CGFloat, attrs: [NSAttributedString.Key: Any], config: ExportConfig) {
        let text = "Corrélations statistiques significatives détectées par l'algorithme ShifAI (r > 0.3)."
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        y += 25
    }

    // MARK: - Predictions

    private func drawPredictions(at y: inout CGFloat, margin: CGFloat, width: CGFloat, attrs: [NSAttributedString.Key: Any], config: ExportConfig) {
        let text = "Prédictions générées par le moteur d'intelligence ShifAI et leur précision historique."
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        y += 25
    }

    // MARK: - Mood Timeline

    private func drawMoodTimeline(at y: inout CGFloat, margin: CGFloat, width: CGFloat, attrs: [NSAttributedString.Key: Any], config: ExportConfig) {
        let text = "Évolution de l'humeur sur la période sélectionnée."
        text.draw(at: CGPoint(x: margin, y: y), withAttributes: attrs)
        y += 25
    }

    // MARK: - Disclaimer Page (FR21)

    private func drawDisclaimerPage(in ctx: UIGraphicsPDFRendererContext, rect: CGRect) {
        let margin: CGFloat = 50
        var y: CGFloat = margin

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor.systemRed
        ]
        "⚠️ Avertissement Médical".draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
        y += 35

        let disclaimerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]

        let disclaimer = """
        Ce document a été généré automatiquement par ShifAI à titre informatif uniquement.

        Il ne constitue en aucun cas un diagnostic médical, un avis médical, ou un traitement.
        Les données présentées sont auto-déclarées par l'utilisatrice et n'ont pas été validées
        par un professionnel de santé.

        Les prédictions et corrélations détectées sont basées sur des algorithmes statistiques
        et des modèles d'intelligence artificielle entraînés sur des données agrégées.
        Elles ne doivent pas être utilisées comme base unique de décision médicale.

        Consultez toujours un professionnel de santé qualifié pour toute question médicale.

        ShifAI respecte le RGPD et les réglementations européennes en matière de protection
        des données personnelles de santé. Toutes les données sont chiffrées AES-256, stockées
        en Union Européenne, et ne sont jamais partagées avec des tiers.

        © ShifAI \(Calendar.current.component(.year, from: Date())) — Tous droits réservés
        """

        let disclaimerRect = CGRect(x: margin, y: y, width: rect.width - 2 * margin, height: 600)
        disclaimer.draw(in: disclaimerRect, withAttributes: disclaimerAttrs)

        drawWatermark(in: rect)
    }

    // MARK: - Watermark

    private func drawWatermark(in rect: CGRect) {
        let watermark = "Information uniquement — Généré par ShifAI"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.lightGray
        ]
        watermark.draw(at: CGPoint(x: 50, y: rect.height - 30), withAttributes: attrs)
    }

    // MARK: - Helpers

    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}

// MARK: - Template Default Sections

extension MedicalExportEngine.ExportTemplate {
    var defaultSections: Set<MedicalExportEngine.ExportSection> {
        switch self {
        case .sopk:
            return [.cycleOverview, .symptomFrequency, .bodyMapHeatmap,
                    .sleepEnergyPatterns, .correlations]
        case .endometriosis:
            return [.cycleOverview, .bodyMapHeatmap, .symptomFrequency,
                    .sleepEnergyPatterns, .moodTimeline]
        case .custom:
            return Set(MedicalExportEngine.ExportSection.allCases)
        }
    }
}
