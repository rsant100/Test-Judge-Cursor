import SwiftUI
import VisionKit
import SwiftData

struct ContractsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contract.scanDate, order: .reverse) private var contracts: [Contract]
    @State private var showingScannerSheet = false
    @State private var showingAddContractSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contracts) { contract in
                    NavigationLink(destination: ContractDetailView(contract: contract)) {
                        ContractRowView(contract: contract)
                    }
                }
                .onDelete(perform: deleteContracts)
            }
            .navigationTitle("Contracts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if DataScannerViewController.isSupported {
                            Button(action: { showingScannerSheet = true }) {
                                Label("Scan Document", systemImage: "doc.viewfinder")
                            }
                        }
                        Button(action: { showingAddContractSheet = true }) {
                            Label("Import PDF", systemImage: "doc.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingScannerSheet) {
                DocumentScannerView { result in
                    switch result {
                    case .success(let scan):
                        handleScan(scan)
                    case .failure(let error):
                        print("Scanning failed: \(error.localizedDescription)")
                    }
                    showingScannerSheet = false
                }
            }
        }
    }
    
    private func deleteContracts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(contracts[index])
        }
    }
    
    private func handleScan(_ scan: ScanResult) {
        // Handle the scanned document
        guard let pdfData = scan.pdfData else { return }
        
        let newContract = Contract(showName: "New Contract", documentData: pdfData)
        modelContext.insert(newContract)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving contract: \(error.localizedDescription)")
        }
    }
}

struct ContractRowView: View {
    let contract: Contract
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(contract.showName)
                .font(.headline)
            Text(contract.scanDate.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    ContractsView()
}
