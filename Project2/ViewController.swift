//
//  ViewController.swift
//  Project2
//
//  Created by Алла Верхоглядова on 02.04.2023.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //lan 42.983612
    //lon -81.249725
    
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

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
//        setupMap()
//        locationManager.requestWhenInUseAuthorization()
//        addAnnotation(location: getLondonLocation())
//        addAnnotation()
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
        loadCurrentWeather(search: "", location: location.coordinate)
        
//        addAnnotation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error::: \(error.localizedDescription)")
    }

    private func setupMap(){
        print("setupMap")
        //set delegate
        mapView.delegate = self
        
        //enable showing user location on map
        mapView.showsUserLocation = true
        
        guard let location = currentLocation else {
            return
        }
        
        let radiusInMeters: CLLocationDistance = 10000
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
        
        //camera boundry
        let cameraBoundry = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundry, animated: true)
        
        //control zooming
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 500000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
    }
    
    func loadCurrentWeather(search: String?, location: CLLocationCoordinate2D) {
        // Step 1: Getting URL
        guard let url = getURL(query: search ?? "", latitude: location.latitude, longitude: location.longitude) else {
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
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.condition.text)
                
                let annotation = MyAnnotation(
                    coordinate: location,
                    title: weatherResponse.current.condition.text, // current weather condition
                    tempDescription: "Temperature: \(weatherResponse.current.temp_c)ºC \nFeels like: \(weatherResponse.current.feelslike_c)ºC",
//                    subtitle: "Temperature: \(weatherResponse.current.temp_c)ºC \n Feels like: \(weatherResponse.current.feelslike_c)ºC",
                    glyphText: "\(weatherResponse.current.temp_c)ºC",
                    code: weatherResponse.current.condition.code
                )
                
                mapView.addAnnotation(annotation)
                
            }
        }
        
        // Step 4: Start the task
        dataTask.resume()
    }


    private func getURL(query: String, latitude: Double, longitude: Double) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "c157243c17f94c8495673213231303"
//        let query = "q=Toronto"
        let aqi = "aqi=no"
        
        var url: String
        
        if query != "" {
            url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(String(describing: query))&\(aqi)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        } else {
            url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(latitude),\(longitude)&\(aqi)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        
        print(url)
        return URL(string: url)
    }
    
    private func parseJSON(data: Data) -> WeatherResponse? {
        // Decode the data
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding: \(error.localizedDescription)")
        }
        return weather
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
//                    print(temperature)
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
//        print("Button clicked! \(control.tag)")
//
//        guard let coordinates = view.annotation?.coordinate else {
//            return
//        }
//
//        let launchOptions = [ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking ]
//
//        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "goToDetails"{
//                let viewController = segue.destination as! DetailsViewController
//                viewController.labelMessage = "Hello there"
//            }
//        }
//
////        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
////        mapItem.openInMaps(launchOptions: launchOptions)
//    }
    if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "goToDetails", sender: view)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            if let viewController = segue.destination as? DetailsViewController, let annotationView = sender as? MKAnnotationView, let annotation = annotationView.annotation as? MyAnnotation {
                viewController.labelMessage = annotation.title ?? ""
            }
        }
    }
}

    

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
//    var subtitle: String?
    var tempDescription: String?
    var glyphText: String?
    var code: Int
    
    init(coordinate: CLLocationCoordinate2D, title: String, tempDescription: String? = nil, glyphText: String?, code: Int){
        self.coordinate = coordinate
        self.title = title
//        self.subtitle = subtitle
        self.tempDescription = tempDescription
        self.glyphText = glyphText
        self.code = code
        
        super.init()
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
    let feelslike_c: Float
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}


