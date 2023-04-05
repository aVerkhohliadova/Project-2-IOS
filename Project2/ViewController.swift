//
//  ViewController.swift
//  Project2
//
//  Created by Алла Верхоглядова on 02.04.2023.
//

import Foundation
import MapKit
import UIKit

// class ViewController: UIViewController, CLLocationManagerDelegate, AddLocationDelegate {
class ViewController: UIViewController, CLLocationManagerDelegate, AddLocationDelegate {
    // lan 42.983612
    // lon -81.249725
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    private var items: [LocationList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func didAddLocation(coordinate: CLLocationCoordinate2D) {
        print("didAddLocation")
        setupMap(location: coordinate)
        loadCurrentWeather(search: "", location: coordinate)
        tableView.reloadData()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("User has granted permission to use location services")
            locationManager.startUpdatingLocation()
        case .denied:
            print("User has denied permission to use location services")
        default:
            print("The user has not yet made a choice regarding location services")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager, didUpdateLocations")
        guard let location = locations.last else {
            return
        }
        currentLocation = location.coordinate
        setupMap(location: currentLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        
        // loading current Weather and annotation
        loadCurrentWeather(search: nil, location: location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error::: \(error.localizedDescription)")
    }

    private func setupMap(location: CLLocationCoordinate2D) {
        print("setupMap: \(location)")
        // set delegate
        mapView.delegate = self
        
        let radiusInMeters: CLLocationDistance = 10000
        let region = MKCoordinateRegion(center: location, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)

        mapView.setRegion(region, animated: true)
        
        // camera boundry
        let cameraBoundry = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundry, animated: true)
        
        // control zooming
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 500000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    @IBAction func addLocationTapped(_ sender: UIBarButtonItem) {
        let addLocationViewController = storyboard?.instantiateViewController(withIdentifier: "goToAddLocation") as! AddLocationViewController
        addLocationViewController.delegate = self
        present(addLocationViewController, animated: true, completion: nil)
    }
    
    func loadCurrentWeather(search: String?, location: CLLocationCoordinate2D) {
        // Step 1: Getting URL
        guard let url = getURL(query: search ?? "", latitude: location.latitude, longitude: location.longitude, days: 1) else {
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
                fillAnnotationWithSearch(weatherResponse: weatherResponse)
                fillListOfLocations(weatherResponse: weatherResponse)
            }
        }
        
        // Step 4: Start the task
        dataTask.resume()
    }
    
    func fillAnnotationWithSearch(weatherResponse: WeatherResponse) {
        let annotation = MyAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon),
            title: weatherResponse.current.condition.text, // current weather condition
            tempDescription: "Temperature: \(weatherResponse.current.tempCelsium)ºC \nFeels like: \(weatherResponse.current.feelsLikeCelsium)ºC",
            glyphText: "\(weatherResponse.current.tempCelsium)ºC",
            code: weatherResponse.current.condition.code
        )
        mapView.addAnnotation(annotation)
    }
    
    func fillAnnotationWithLocation(weatherResponse: WeatherResponse) {
        let annotation = MyAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon),
            title: weatherResponse.current.condition.text, // current weather condition
            tempDescription: "Temperature: \(weatherResponse.current.tempCelsium)ºC \nFeels like: \(weatherResponse.current.feelsLikeCelsium)ºC",
            glyphText: "\(weatherResponse.current.tempCelsium)ºC",
            code: weatherResponse.current.condition.code
        )
        mapView.addAnnotation(annotation)
    }
    
    private func fillListOfLocations(weatherResponse: WeatherResponse) {
        DispatchQueue.main.async { [self] in
            items.append(LocationList(name: weatherResponse.location.name,
                                      temperature: "\(weatherResponse.current.tempCelsium)C (H: \(weatherResponse.forecast.forecastday[0].day.maxTempCelsium) L: \(weatherResponse.forecast.forecastday[0].day.minTempCelsium))",
                                      icon: UIImage(systemName: codeToSymbolColor[weatherResponse.current.condition.code]?.symbol ?? "")))
            tableView.reloadData()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
        var view: MKMarkerAnnotationView
        
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
            
        // set the position of the callout
        view.calloutOffset = CGPoint(x: 0, y: 10)
            
        // add a button to right side of callout
        let button = UIButton(type: .detailDisclosure)
        button.tag = 100
        view.rightCalloutAccessoryView = button
            
        print("else annotation: \(annotation)")
            
        if let myAnnotation = annotation as? MyAnnotation {
            view.glyphText = myAnnotation.glyphText
            print(view.glyphText!.replacingOccurrences(of: "ºC", with: ""))
            if let glyphText = myAnnotation.glyphText?.replacingOccurrences(of: "ºC", with: ""), let temperature = Float(glyphText) {
                switch temperature {
                case 35...:
                    view.markerTintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                    view.tintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                case 25..<35:
                    view.markerTintColor = UIColor.orange
                    view.tintColor = UIColor.orange
                case 17..<25:
                    view.markerTintColor = UIColor.yellow
                    view.tintColor = UIColor.yellow
                case 12..<17:
                    view.markerTintColor = UIColor.blue.withAlphaComponent(0.5) // light blue
                    view.tintColor = UIColor.blue.withAlphaComponent(0.5) // light blue
                case 0..<12:
                    view.markerTintColor = UIColor.blue
                    view.tintColor = UIColor.blue
                default:
                    view.markerTintColor = UIColor.purple
                    view.tintColor = UIColor.purple
                }
                print("\n\tMarkerColor:\(String(describing: view.markerTintColor))")
            }
            let label = UILabel()
            label.numberOfLines = 0
            label.text = myAnnotation.tempDescription
            label.font = UIFont.systemFont(ofSize: 12)
            view.detailCalloutAccessoryView = label
                
            // add an image to left side of callout
            guard let _ = codeToSymbolColor[myAnnotation.code] else {
                print("Invalid code: \(myAnnotation.code)")
                return nil
            }
                
            let image = UIImage(systemName: codeToSymbolColor[myAnnotation.code]?.symbol ?? "")
            view.leftCalloutAccessoryView = UIImageView(image: image)
//            }
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "goToDetails", sender: view)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            if let viewController = segue.destination as? DetailsViewController, let annotationView = sender as? MKAnnotationView, let annotation = annotationView.annotation as? MyAnnotation {
                viewController.labelMessage = "\(annotation.coordinate.latitude), \(annotation.coordinate.longitude)"
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = item.temperature
        content.image = item.icon
        
        cell.contentConfiguration = content
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the selected item and its location
        let selectedItem = items[indexPath.row]
        
        getLatAndLong(name: selectedItem.name)
    }
    
    func getLatAndLong(name: String) {
        print("getLatAndLong \(name)")
    
        guard let url = getURL(query: name, latitude: 0.0, longitude: 0.0, days: 1) else {
            print("Could not get URL")
            return
        }
        let session = URLSession.shared
    
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
                print(weatherResponse.location.lat)
    
                DispatchQueue.main.async { [self] in
                    setupMap(location: CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon))
                }
            }
        }
        // Step 4: Start the task
        dataTask.resume()
    }
}
