import SwiftUI
import SwiftData
import VisionKit

struct HomeView: View {
    @State private var showingAddShow = false
    @State private var showingScannerSheet = false
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Show.date) private var shows: [Show]
    @State private var currentWeather: WeatherForecast?
    @State private var weatherLocation: String = ""
    
    var upcomingShows: [Show] {
        let today = Calendar.current.startOfDay(for: Date())
        return shows.filter { show in
            let showDate = Calendar.current.startOfDay(for: show.date)
            return showDate >= today
        }
        .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Weather Card
                    if let weather = currentWeather {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Current Weather")
                                        .font(.headline)
                                    Text(weatherLocation)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if let url = weather.weather.first?.iconURL {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                
                                VStack(alignment: .trailing) {
                                    Text("\(Int(weather.main.temp))°F")
                                        .font(.title2)
                                    Text(weather.weather.first?.description.capitalized ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            HStack {
                                WeatherDetailView(title: "High", value: "\(Int(weather.main.temp_max))°")
                                Divider()
                                WeatherDetailView(title: "Low", value: "\(Int(weather.main.temp_min))°")
                                Divider()
                                WeatherDetailView(title: "Humidity", value: "\(weather.main.humidity)%")
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    
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
                                    ForEach(upcomingShows) { show in
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
            .task {
                await fetchCurrentWeather()
            }
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
    
    private func fetchCurrentWeather() async {
        if let nextShow = upcomingShows.first {
            do {
                currentWeather = try await WeatherService.shared.fetchWeatherForecast(for: nextShow)
                weatherLocation = "\(nextShow.location), \(nextShow.state)"
            } catch {
                print("Error fetching weather: \(error.localizedDescription)")
            }
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
