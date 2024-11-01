import SwiftUI
import SwiftData
import VisionKit

struct HomeView: View {
    @State private var showingAddShow = false
    @State private var showingScannerSheet = false
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Show.date) private var shows: [Show]
    
    var upcomingShows: [Show] {
        shows.filter { $0.date > Date() }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    HStack(spacing: 20) {
                        QuickActionButton(
                            title: "Add Show",
                            systemImage: "plus.circle.fill",
                            color: .blue
                        ) {
                            showingAddShow = true
                        }
                        
                        QuickActionButton(
                            title: "Scan Contract",
                            systemImage: "doc.viewfinder",
                            color: .green
                        ) {
                            showingScannerSheet = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Upcoming Shows
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upcoming Shows")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        if upcomingShows.isEmpty {
                            Text("No upcoming shows")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(upcomingShows.prefix(5)) { show in
                                        UpcomingShowCard(show: show)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Statistics")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            StatisticCard(
                                title: "Total Shows",
                                value: "\(upcomingShows.count)",
                                systemImage: "calendar",
                                color: .blue
                            )
                            
                            StatisticCard(
                                title: "This Month",
                                value: "\(showsThisMonth())",
                                systemImage: "clock",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Judge Assistant")
        }
        .sheet(isPresented: $showingAddShow) {
            AddShowView()
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
    
    private func showsThisMonth() -> Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return upcomingShows.filter { show in
            let showMonth = calendar.component(.month, from: show.date)
            let showYear = calendar.component(.year, from: show.date)
            return showMonth == currentMonth && showYear == currentYear
        }.count
    }
    
    private func handleScan(_ scan: ScanResult) {
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

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                Text(title)
                    .font(.caption)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

struct UpcomingShowCard: View {
    let show: Show
    
    var body: some View {
        NavigationLink(destination: ShowDetailView(show: show)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(show.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(show.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                
                Text("\(show.location), \(show.state)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Ring \(show.ringNumber)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding()
            .frame(width: 200)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    HomeView()
}
