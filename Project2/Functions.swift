//
//  Functions.swift
//  Project2
//
//  Created by Алла Верхоглядова on 04.04.2023.
//

import Foundation
import MapKit
import UIKit

let codeToSymbolColor: [Int: (symbol: String, colors: [UIColor])] = [
    1000: ("sun.max", [.systemOrange, .systemYellow]), // Sunny
    1003: ("cloud.sun.fill", [.systemCyan, .systemOrange]), // Partly cloudy
    1006: ("cloud.fill", [.systemCyan, .systemOrange]), // Cloudy
    1009: ("cloud.fill", [.systemCyan, .systemOrange]), // Overcast
    1030: ("cloud.fog.fill", [.systemCyan, .systemBlue]), // Mist
    1063: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Patchy rain possible
    1066: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Patchy snow possible
    1069: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Patchy sleet possible
    1072: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Patchy freezing drizzle possible
    1087: ("cloud.bolt.fill", [.systemCyan, .systemYellow]), // Thundery outbreaks possible
    1114: ("wind.snow", [.systemCyan, .systemBlue]), // Blowing snow
    1117: ("wind.snow", [.systemCyan, .systemBlue]), // Blizzard
    1135: ("cloud.fog.fill", [.systemCyan, .systemBlue]), // Fog
    1147: ("cloud.fog.fill", [.systemCyan, .systemBlue]), // Freezing fog
    1150: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Patchy light drizzle
    1153: ("cloud.drizzle.fill", [.systemCyan, .systemBlue]), // Light drizzle
    1168: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Freezing drizzle
    1171: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Heavy freezing drizzle
    1180: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Patchy light rain
    1183: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Light rain
    1186: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Moderate rain at times
    1189: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Moderate rain
    1192: ("cloud.heavyrain.fill", [.systemCyan, .systemBlue]), // Heavy rain at times
    1195: ("cloud.heavyrain.fill", [.systemCyan, .systemBlue]), // Heavy rain
    1198: ("cloud.sleet", [.systemCyan, .systemBlue]), // Light freezing rain
    1201: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Moderate or heavy freezing rain
    1204: ("cloud.sleet", [.systemCyan, .systemBlue]), // Light sleet
    1207: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Moderate or heavy sleet
    1210: ("cloud.snow", [.systemCyan, .systemBlue]), // Patchy light snow
    1213: ("cloud.snow", [.systemCyan, .systemBlue]), // Light snow
    1216: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Patchy moderate snow
    1219: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Moderate snow
    1222: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Patchy heavy snow
    1225: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Heavy snow
    1237: ("aqi.low", [.systemCyan, .systemBlue]), // Ice pellets
    1240: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Light rain shower
    1243: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Moderate or heavy rain shower
    1246: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Torrential rain shower
    1249: ("cloud.sleet", [.systemCyan, .systemBlue]), // Light sleet showers
    1252: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Moderate or heavy sleet showers
    1255: ("cloud.snow", [.systemCyan, .systemBlue]), // Light snow showers
    1258: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Moderate or heavy snow showers
    1261: ("aqi.low", [.systemCyan, .systemBlue]), // Light showers of ice pellets
    1264: ("aqi.medium", [.systemCyan, .systemBlue]), // Moderate or heavy showers of ice pellets
    1273: ("cloud.bolt.rain", [.systemCyan, .systemBlue]), // Patchy light rain with thunder
    1276: ("cloud.bolt.rain.fill", [.systemCyan, .systemBlue]), // Moderate or heavy rain with thunder
    1279: ("cloud.bolt.", [.systemCyan, .systemBlue]), // Patchy light snow with thunder
    1282: ("cloud.bolt.fill", [.systemCyan, .systemBlue]) // Moderate or heavy snow with thunder
]

func getURL(query: String, latitude: Double, longitude: Double, days: Int) -> URL? {
    let baseURL = "https://api.weatherapi.com/v1/"
    let currentEndpoint = "forecast.json"
    let apiKey = "025077f00dee46fca8e94317230404"
    let aqi = "aqi=no"
    let alerts = "alerts=no"

    var url: String

    if query != "" {
        url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(String(describing: query))&days=\(days)&\(aqi)&\(alerts)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    } else {
        url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(latitude),\(longitude)&days=\(days)&\(aqi)&\(alerts)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    print(url)
    return URL(string: url)
}

func parseJSON(data: Data) -> WeatherResponse? {
    // Decode the data
    let decoder = JSONDecoder()
    var weather: WeatherResponse?

    do {
        weather = try decoder.decode(WeatherResponse.self, from: data)
    } catch {
        print("Error decoding: \(error.localizedDescription)")
    }
    return weather
}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var tempDescription: String?
    var glyphText: String?
    var code: Int

    init(coordinate: CLLocationCoordinate2D, title: String, tempDescription: String? = nil, glyphText: String?, code: Int) {
        self.coordinate = coordinate
        self.title = title
        self.tempDescription = tempDescription
        self.glyphText = glyphText
        self.code = code

        super.init()
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
    let forecast: Forecast
}

struct Location: Decodable {
    let name: String
    let lat: Double
    let lon: Double
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
    let feelslike_c: Float
}

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let date_epoch: Int
    let day: Day
}

struct Day: Decodable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

struct LocationList {
    let name: String
    let temperature: String
    let icon: UIImage?
}

struct DayByDayForecast {
    let dayWeek: String
    let temperature: String
    let icon: UIImage?
}
