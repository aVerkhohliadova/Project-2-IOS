//
//  AddLocationViewController.swift
//  Project2
//
//  Created by Алла Верхоглядова on 04.04.2023.
//

import CoreLocation
import UIKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var weatherConditionImage: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var temperatureMetricssegmentControl: UISegmentedControl!
    @IBOutlet var weatherConditionLabel: UILabel!
    
    var isMetric = true
    private var weather: Weather?
    private var location: CLLocationCoordinate2D?
    weak var delegate: AddLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        print("Save button Tapped!")
        guard let coordinate = location else { return }
        
        print(coordinate)
        delegate?.didAddLocation(coordinate: coordinate)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func temperatureMetricsValueChanged(_ sender: UISegmentedControl) {
        isMetric = sender.selectedSegmentIndex == 0
        updateTemperatureLabel()
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text, latitude: 0.0, longtitude: 0.0)
    }
    
    func updateTemperatureLabel() {
        guard let weather = weather else { return }
        let temperature = isMetric ? weather.tempCelsium : weather.tempFarenheit
        let unit = isMetric ? "ºC" : "ºF"
        temperatureLabel.text = "\(temperature) \(unit)"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: textField.text, latitude: 0.0, longtitude: 0.0)
        return true
    }
    
    private func displaySampleImageForDemo(code: Int) {
        guard let _ = codeToSymbolColor[code] else {
            print("Invalid code: \(code)")
            return
        }
        
        let config = UIImage.SymbolConfiguration(paletteColors: codeToSymbolColor[code]?.colors ?? [.systemCyan, .systemBlue])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: codeToSymbolColor[code]?.symbol ?? "")
    }
    
    private func loadWeather(search: String?, latitude: Double, longtitude: Double) {
        // Step 1: Getting URL:
        guard let url = getURL(query: search ?? "", latitude: latitude, longitude: longtitude, days: 1) else {
            print("Could not get URL")
            return
        }
        
        // Step 2: Create URLSession
        let session = URLSession.shared
        
        // Step 3: Create task for the session
        let dataTask = session.dataTask(with: url) { [self] data, _, error in
            print("Network call comlete")
            
            guard error == nil else {
                print("Recieved error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = parseJSON(data: data) {
                DispatchQueue.main.async { [self] in
                    locationLabel.text = weatherResponse.location.name
                    weather = weatherResponse.current
                    updateTemperatureLabel()
                    weatherConditionLabel.text = weatherResponse.current.condition.text
                    displaySampleImageForDemo(code: weatherResponse.current.condition.code)
                    
                    location = CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon)
                }
            }
        }
        // Step 4: Start the task
        dataTask.resume()
    }
}

protocol AddLocationDelegate: AnyObject {
    func didAddLocation(coordinate: CLLocationCoordinate2D)
}
