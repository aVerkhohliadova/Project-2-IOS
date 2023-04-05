//
//  DetailsViewController.swift
//  Project2
//
//  Created by Алла Верхоглядова on 03.04.2023.
//

import UIKit

class DetailsViewController: UIViewController {
    var labelMessage: String?
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var HighTemperatureLabel: UILabel!
    @IBOutlet var LowTemperatureLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    private var items: [DayByDayForecast] = []
    var dayWeek: [String] = []
    var temperature: [String] = []
    var iconCode: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let message = labelMessage {
            cityLabel.text = message
        }
//        loadForecastItems()
        
        loadCurrentInfo(days: 1)
        loadCurrentInfo(days: 7)
        
        tableView.dataSource = self
    }
    
    @IBAction func cancelDetailsScreen(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func loadForecastItems() {
        for i in 0 ..< dayWeek.count {
            items.append(DayByDayForecast(dayWeek: dayWeek[i],
                                          temperature: temperature[i],
                                          icon: UIImage(systemName: codeToSymbolColor[iconCode[i]]?.symbol ?? "")))
            tableView.reloadData()
        }
    }
    
    func loadCurrentInfo(days: Int) {
        let location = cityLabel.text?.components(separatedBy: ", ")
        
        guard let url = getURL(query: "", latitude: Double(location?[0] ?? "0.0") ?? 0.0, longitude: Double(location?[1] ?? "0.0") ?? 0.0, days: days) else {
            print("Could not get URL")
            return
        }
        
        // Step 2: Create URLSession
        let session = URLSession.shared
        
        // Step 3: Create task for the session
        let dataTask = session.dataTask(with: url) { [self] data, _, error in
            print("Network call complete")
            
            guard error == nil else {
                print("Received error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = parseJSON(data: data) {
                if days == 1 {
                    fillLabelsOnTheScreen(weatherResponse: weatherResponse)
                } else {
                    fillForecastList(weatherResponse: weatherResponse)
                }
            }
        }
        // Step 4: Start the task
        dataTask.resume()
    }
    
    func fillLabelsOnTheScreen(weatherResponse: WeatherResponse) {
        DispatchQueue.main.async { [self] in
            cityLabel.text = weatherResponse.location.name
            temperatureLabel.text = "\(weatherResponse.current.temp_c)ºC"
            weatherConditionLabel.text = weatherResponse.current.condition.text
            HighTemperatureLabel.text = "\(weatherResponse.forecast.forecastday[0].day.maxtemp_c)ºC"
            LowTemperatureLabel.text = "\(weatherResponse.forecast.forecastday[0].day.mintemp_c)ºC"
        }
    }
    
    func fillForecastList(weatherResponse: WeatherResponse) {
        DispatchQueue.main.async { [self] in
            for forecastDay in weatherResponse.forecast.forecastday {
                dayWeek.append(dateToWeekday(forecastDate: forecastDay.date))
                temperature.append("\(forecastDay.day.maxtemp_c)ºC")
                iconCode.append(forecastDay.day.condition.code)
            }
            loadForecastItems()
        }
    }
    
    func dateToWeekday(forecastDate: String) -> String {
        let dateString = forecastDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)!
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        switch dayOfWeek {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return ""
        }
    }
}

extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = item.dayWeek
        content.secondaryText = item.temperature
        content.image = item.icon
        
        cell.contentConfiguration = content
        
        return cell
    }
}
