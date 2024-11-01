import SwiftUI
import PDFKit

struct ContractDetailView: View {
    @Bindable var contract: Contract
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            Section("Contract Information") {
                LabeledContent("Show Name", value: contract.showName)
                LabeledContent("Scan Date", value: contract.scanDate.formatted())
            }
            
            if let documentData = contract.documentData {
                Section("Document") {
                    PDFKitView(data: documentData)
                        .frame(height: 500)
                }
            }
            
            Section("Notes") {
                TextEditor(text: Binding(
                    get: { contract.notes ?? "" },
                    set: { contract.notes = $0 }
                ))
                .frame(minHeight: 100)
            }
        }
        .navigationTitle("Contract Details")
        .toolbar {
            Button("Edit") {
                showingEditSheet = true
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFKit.PDFView, context: Context) {
        // No update needed
    }
} 