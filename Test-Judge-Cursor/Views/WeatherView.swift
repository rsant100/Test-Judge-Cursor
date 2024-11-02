import SwiftUI

struct WeatherView: View {
    let show: Show
    @State private var forecast: WeatherForecast?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if let forecast = forecast {
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Weather Forecast")
                            .font(.headline)
                        Text(forecast.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if let url = forecast.weather.first?.iconURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    VStack(alignment: .trailing) {
                        Text("\(Int(forecast.main.temp))°F")
                            .font(.title2)
                        Text(forecast.weather.first?.description.capitalized ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack {
                    WeatherDetailView(title: "High", value: "\(Int(forecast.main.temp_max))°")
                    Divider()
                    WeatherDetailView(title: "Low", value: "\(Int(forecast.main.temp_min))°")
                    Divider()
                    WeatherDetailView(title: "Humidity", value: "\(forecast.main.humidity)%")
                }
                .padding(.top, 8)
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .task {
            await fetchWeather()
        }
    }
    
    private func fetchWeather() async {
        do {
            forecast = try await WeatherService.shared.fetchWeatherForecast(for: show)
        } catch {
            errorMessage = "Unable to load weather forecast"
        }
    }
} 