//
//  ViewController.swift
//  Project2
//
//  Created by Алла Верхоглядова on 02.04.2023.
//

import UIKit
import MapKit
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //lan 42.983612
    //lon -81.249725
    
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    private var items: [LocationList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        loadDefaultItems()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadDefaultItems(){
        items.append(LocationList(title: "Lviv", subtitle: "12C(H:15,L:3)", icon: UIImage(systemName: "cloud")))
//        items.append(ItemToDo(title: "Item 2", description: "Description 2", icon: UIImage(systemName: "drop")))
//        items.append(ItemToDo(title: "Item 3", description: "Description 3", icon: UIImage(systemName: "pawprint")))
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse:
                print("User has granted permission to use location services")
                locationManager.startUpdatingLocation()
            case .denied:
                print("User has denied permission to use location services")
                break
            default:
                print("The user has not yet made a choice regarding location services")
                break
            }
        }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("locationManager, didUpdateLocations")
        guard let location = locations.last else {
            return
        }
        currentLocation = location.coordinate
        setupMap()
        
        //loading current Weather and annotation
        loadCurrentWeather(search: nil, location: location.coordinate)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error::: \(error.localizedDescription)")
    }

    private func setupMap() {
        print("setupMap")
        //set delegate
        mapView.delegate = self
        
//        let locationCoordinates = getLatAndLong(name: name ?? "")
//        let locationCoordinates = try await getLatAndLong(name: name ?? "")

        
        //enable showing user location on map
//        mapView.showsUserLocation = true
        
        guard let location = currentLocation else {
            return
        }
        
        let radiusInMeters: CLLocationDistance = 10000
//        let region: MKCoordinateRegion
        
//        if name != nil{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
//        } else {
//            region = MKCoordinateRegion(center: locationOnMap, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
//        }
        
        mapView.setRegion(region, animated: true)
        
        //camera boundry
        let cameraBoundry = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundry, animated: true)
        
        //control zooming
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 500000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
    }
    
    @IBAction func addLocationTapped(_ sender: UIBarButtonItem) {
        
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
        let dataTask = session.dataTask(with: url) { [self] data, response, error in
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
                
                if search != nil {
                    let annotation = MyAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon),
                        title: weatherResponse.current.condition.text, // current weather condition
                        tempDescription: "Temperature: \(weatherResponse.current.temp_c)ºC \nFeels like: \(weatherResponse.current.feelslike_c)ºC",
                        glyphText: "\(weatherResponse.current.temp_c)ºC",
                        code: weatherResponse.current.condition.code
                    )
                    mapView.addAnnotation(annotation)
                } else {
                    let annotation = MyAnnotation(
                        coordinate: location,
                        title: weatherResponse.current.condition.text, // current weather condition
                        tempDescription: "Temperature: \(weatherResponse.current.temp_c)ºC \nFeels like: \(weatherResponse.current.feelslike_c)ºC",
                        glyphText: "\(weatherResponse.current.temp_c)ºC",
                        code: weatherResponse.current.condition.code
                    )
                    mapView.addAnnotation(annotation)
                }
                
            }
        }
        
        // Step 4: Start the task
        dataTask.resume()
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myIdentifier"
        var view: MKMarkerAnnotationView
        
        //check to see if we have a view to reuse
        if let dequequeView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView{
            //get updated annotation
            dequequeView.annotation = annotation
            //use our reusable view
            view = dequequeView
        }else{
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
            //set the position of the callout
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            //add a button to right side of callout
            let button = UIButton(type: .detailDisclosure)
            button.tag = 100
            view.rightCalloutAccessoryView = button
            
            
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
                }
                let label = UILabel()
                label.numberOfLines = 0
                label.text = myAnnotation.tempDescription
                label.font = UIFont.systemFont(ofSize: 12)
                view.detailCalloutAccessoryView = label
                
                //add an image to left side of callout
                guard let (_, _) = codeToSymbolColor[myAnnotation.code] else {
                    print("Invalid code: \(myAnnotation.code)")
                    return nil
                }
                
                let image = UIImage(systemName: codeToSymbolColor[myAnnotation.code]?.symbol ?? "")
                view.leftCalloutAccessoryView = UIImageView(image: image)
                
            }

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
//                viewController. = annotation.title ?? ""
            }
        }
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.subtitle
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
        let locationCoordinate = getLatAndLong(name: selectedItem.title)
        
        let region = MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: 10000, longitudinalMeters: 10000) // adjust the zoom level as needed
        mapView.setRegion(region, animated: true)
    }
        

//        Task {
//                // Get the location coordinates asynchronously
////            let locationCoordinates = await getLatAndLong(name: selectedItem.title)
//
//                // Update the map and weather
//                DispatchQueue.main.async {
//                    self.setupMap(name: selectedItem.title, locationOnMap: <#T##CLLocationCoordinate2D#>)
//                    self.loadCurrentWeather(search: "", location: locationCoordinates)
//                }
//            }
//    }
    
//    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        // Get the selected item
//        let selectedItem = items[indexPath.row]
//
//        Task {
//            // Get the location coordinates asynchronously
//            print("\n")
////            let locationCoordinates = try await getLatAndLong(name: selectedItem.title)
//
//            // Update the map and weather
//            DispatchQueue.main.async {
//                try self.setupMap(name: selectedItem.title, locationOnMap: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
////                self.loadCurrentWeather(search: "", location: locationCoordinates)
//            }
//        }
//    }
    
    func getLatAndLong(name: String) -> CLLocationCoordinate2D {
        guard let url = getURL(query: name, latitude: 0.0, longitude: 0.0, days: 1) else {
            print("Could not get URL")
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        
        let session = URLSession.shared
        
        var location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        let dataTask = session.dataTask(with: url) { [self] data, response, error in
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
                
                DispatchQueue.main.async {
                    location.latitude = weatherResponse.location.lat
                    location.longitude = weatherResponse.location.lon
                    print("inside \(location)")
                }
            }
        }
        
        dataTask.resume()
        print(location)
        return location
    }

    
//    func getLatAndLong(name: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
//        guard let url = getURL(query: name, latitude: 0.0, longitude: 0.0, days: 1) else {
//            print("Could not get URL")
//            completion(.failure(NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get URL"])))
//            return
//        }
//
//        let session = URLSession.shared
//
//        let dataTask = session.dataTask(with: url) { [self] data, response, error in
//            print("Network call complete")
//
//            if let error = error {
//                print("Received error")
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                print("No data found")
//                completion(.failure(NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
//                return
//            }
//
//            if let weatherResponse = parseJSON(data: data) {
//                print(weatherResponse.location.lat)
//                let location = CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon)
//                completion(.success(location))
//            }
//        }
//        // Step 4: Start the task
//        dataTask.resume()
//    }

    
//    func getLatAndLong(name: String) -> CLLocationCoordinate2D {
//
//        print("getLatAndLong \(name)")
//
//        guard let url = getURL(query: name, latitude: 0.0, longitude: 0.0, days: 1) else {
//            print("Could not get URL")
//            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//        }
//        let session = URLSession.shared
//
//        var location: CLLocationCoordinate2D// = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//
//        let dataTask = session.dataTask(with: url) { [self] data, response, error in
//            print("Network call complete")
//
//            guard error == nil else {
//                print("Received error")
//                return
//            }
//
//            guard let data = data else {
//                print("No data found")
//                return
//            }
//
//            if let weatherResponse = parseJSON(data: data) {
//                print(weatherResponse.location.lat)
//
//                DispatchQueue.main.async { [] in
//                    location.latitude = weatherResponse.location.lat
//                    location.longitude = weatherResponse.location.lon
//                }
//            }
//        }
//        // Step 4: Start the task
//        dataTask.resume()
//        print("getLatAndLong \(location)")
//        return location
//    }
}





