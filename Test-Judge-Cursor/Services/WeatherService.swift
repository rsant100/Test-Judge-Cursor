import Foundation
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "f62deadf4c9b7976229e00ed49c6753e" // Replace with your OpenWeather API key
    private let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
    
    private init() {}
    
    func fetchWeatherForecast(for show: Show) async throws -> WeatherForecast {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString("\(show.location), \(show.state)")
        
        guard let location = placemarks.first?.location?.coordinate else {
            throw WeatherError.locationNotFound
        }
        
        let urlString = "\(baseURL)?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=imperial"
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let forecast = try JSONDecoder().decode(WeatherResponse.self, from: data)
        
        return forecast.findForecast(for: show.date)
    }
}

enum WeatherError: Error {
    case locationNotFound
    case invalidURL
    case noForecastAvailable
}

struct WeatherResponse: Codable {
    let list: [WeatherForecast]
    
    func findForecast(for date: Date) -> WeatherForecast {
        let targetDate = Calendar.current.startOfDay(for: date)
        return list.first { forecast in
            Calendar.current.isDate(forecast.date, inSameDayAs: targetDate)
        } ?? list[0]
    }
}

struct WeatherForecast: Codable, Identifiable {
    var id: UUID {
        UUID()
    }
    let main: WeatherMain
    let weather: [WeatherDescription]
    let dt: TimeInterval
    
    var date: Date {
        Date(timeIntervalSince1970: dt)
    }
}

struct WeatherMain: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
}

struct WeatherDescription: Codable {
    let main: String
    let description: String
    let icon: String
    
    var iconURL: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
} 
