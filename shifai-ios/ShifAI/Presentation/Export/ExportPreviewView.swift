import SwiftUI
import PDFKit

// MARK: - Export Preview View (S6-5)
// In-app PDF preview with scroll, zoom, template selection, and share

struct ExportPreviewView: View {
    @StateObject private var viewModel = ExportPreviewViewModel()
    @State private var showShareSheet = false
    @State private var showTemplateSelector = false

    var body: some View {
        NavigationView {
            ZStack {
                ShifAIColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Template selector
                    templateSelector

                    // Date range
                    dateRangeSelector

                    // PDF Preview
                    if let pdfData = viewModel.pdfData {
                        PDFPreviewRepresentable(data: pdfData)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                    } else {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(Color(hex: "A78BFA"))
                            Text("Génération du rapport…")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // Action buttons
                    actionButtons
                }
            }
            .navigationTitle("Export Médical")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "A78BFA"))
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = viewModel.pdfData {
                    ShareSheet(activityItems: [data])
                }
            }
            .onAppear { viewModel.generatePDF() }
        }
    }

    // MARK: - Template Selector

    private var templateSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MedicalExportEngine.ExportTemplate.allCases) { template in
                    Button {
                        viewModel.selectedTemplate = template
                        viewModel.generatePDF()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(viewModel.selectedTemplate == template ? .white : .white.opacity(0.5))
                            Text(template.description)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.3))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedTemplate == template ?
                                      Color(hex: "7C5CFC").opacity(0.3) :
                                      Color.white.opacity(0.04))
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Date Range Selector

    private var dateRangeSelector: some View {
        HStack {
            Text("Période:")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))

            ForEach([(3, "3 mois"), (6, "6 mois"), (12, "1 an")], id: \.0) { months, label in
                Button {
                    viewModel.setMonths(months)
                    viewModel.generatePDF()
                } label: {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.selectedMonths == months ? .white : .white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(viewModel.selectedMonths == months ?
                                           Color(hex: "7C5CFC").opacity(0.3) :
                                           Color.white.opacity(0.04))
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Modify button
            Button {
                showTemplateSelector = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Modifier")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                )
            }

            // Share button
            Button {
                showShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Partager")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "7C5CFC"), Color(hex: "EC4899")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding(16)
    }
}

// MARK: - PDF Preview (UIViewRepresentable)

struct PDFPreviewRepresentable: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .clear
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ViewModel

final class ExportPreviewViewModel: ObservableObject {
    @Published var selectedTemplate: MedicalExportEngine.ExportTemplate = .sopk
    @Published var selectedMonths: Int = 3
    @Published var pdfData: Data? = nil
    @Published var gynecologistNotes: String = ""

    private let engine = MedicalExportEngine()

    func setMonths(_ months: Int) {
        selectedMonths = months
    }

    func generatePDF() {
        pdfData = nil

        // Async generation
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .month, value: -self.selectedMonths, to: endDate)!

            let config = MedicalExportEngine.ExportConfig(
                template: self.selectedTemplate,
                dateRange: startDate...endDate,
                sections: self.selectedTemplate.defaultSections,
                gynecologistNotes: self.gynecologistNotes.isEmpty ? nil : self.gynecologistNotes
            )

            let data = self.engine.generatePDF(config: config)

            DispatchQueue.main.async {
                self.pdfData = data
            }
        }
    }
}
