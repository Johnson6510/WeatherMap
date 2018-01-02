//
//  ViewController.swift
//  WeatherMap
//
//  Created by 黃健偉 on 2017/12/20.
//  Copyright © 2017年 黃健偉. All rights reserved.
//  http://media.bemyapp.com/integrate-alamofire-swift/
//  https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
//

import UIKit
import CoreData
import MapKit
import Alamofire

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class ViewController: UIViewController, MKMapViewDelegate {

    let OpenWeatherAPIKey = "cc97bcab2f8e89e1d4a5af6e6029022f"

    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark! = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let entityName = "StoredPlace"
    let entity = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredPlace")
    var myLocation = MKPointAnnotation()
    
    @IBAction func returnHome(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: myLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func LongPress(_ sender: UILongPressGestureRecognizer) {
        handleLongPress(gestureRecognizer: sender)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        entity.returnsObjectsAsFaults = false

        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as UISearchResultsUpdating
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)

        mapView.showsUserLocation = true;

        //load all POIs from Core Data
        loadSavedPOI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.showsUserLocation = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            addAnnotationOnLocationRecord(coordinates: newCoordinates)
        }
    }
    
    func addAnnotationOnLocation(coordinates: CLLocationCoordinate2D) {
        self.mapView.delegate = self

        let annotation = CustomPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Loading…"
        annotation.subtitle = "Loading…"
        //https://openweathermap.org/weather-conditions
        annotation.imageName = "50d.png"
        
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&APIKEY=\(OpenWeatherAPIKey)&units=metric"
        
        Alamofire.request(url).responseJSON { response in
            DispatchQueue.main.async {
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print(errorMessage!)
                    return
                }
                guard let JSON = response.result.value as? Dictionary<String, AnyObject> else {
                    print("JSON formate error")
                    return
                }
                //print(JSON)
                annotation.title = "\(JSON["name"]!), \(JSON["sys"]!["country"]! ?? "")"
                annotation.subtitle = "\(JSON["main"]!["temp"]! ?? 0)(\(JSON["main"]!["temp_min"]! ?? 0)~\(JSON["main"]!["temp_max"]! ?? 0)) ℃"

                if let weather = JSON["weather"] as? [[String: AnyObject]] {
                    annotation.imageName = weather[0]["icon"] as! String + ".png"
                    annotation.subtitle! += ", \(weather[0]["description"] ?? "Unknow" as AnyObject)"
                    //print (annotation.imageName)
                    self.mapView.addAnnotation(annotation)
                }

                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }

    func addAnnotationOnLocationRecord(coordinates: CLLocationCoordinate2D) {
        self.mapView.delegate = self
        
        let annotation = CustomPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Loading…"
        annotation.subtitle = "Loading…"
        //https://openweathermap.org/weather-conditions
        annotation.imageName = "50d.png"
        
        let url = "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&APIKEY=\(OpenWeatherAPIKey)&units=metric"
        
        Alamofire.request(url).responseJSON { response in
            DispatchQueue.main.async {
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print(errorMessage!)
                    return
                }
                guard let JSON = response.result.value as? Dictionary<String, AnyObject> else {
                    print("JSON formate error")
                    return
                }
                //print(JSON)
                annotation.title = "\(JSON["name"]!), \(JSON["sys"]!["country"]! ?? "")"
                annotation.subtitle = "\(JSON["main"]!["temp"]! ?? 0)(\(JSON["main"]!["temp_min"]! ?? 0)~\(JSON["main"]!["temp_max"]! ?? 0)) ℃"
                
                if let weather = JSON["weather"] as? [[String: AnyObject]] {
                    annotation.imageName = weather[0]["icon"] as! String + ".png"
                    annotation.subtitle! += ", \(weather[0]["description"] ?? "Unknow" as AnyObject)"
                    //print (annotation.imageName)
                    self.mapView.addAnnotation(annotation)
                }
                
                self.mapView.selectAnnotation(annotation, animated: true)
                self.insert(latitude: coordinates.latitude, longitude: coordinates.longitude, titleString: annotation.title!, subTitleString: "", typeString: "Weather")

            }
        }
    }

    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
    }

    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func insert(latitude: Double, longitude: Double, titleString: String, subTitleString: String, typeString: String) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let newPOI = NSManagedObject(entity: entity!, insertInto: context)
        
        newPOI.setValue(String(latitude), forKey: "latitude")
        newPOI.setValue(String(longitude), forKey: "longitude")
        newPOI.setValue(titleString, forKey: "title")
        newPOI.setValue(subTitleString, forKey: "subTitle")
        newPOI.setValue(typeString, forKey: "poiType")

        do {
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func loadSavedPOI() {
        do {
            let results = try context.fetch(entity)
            let totalEntries = results.count
            print ("Total Location to Load: \(totalEntries)")
            if totalEntries != 0 {
                for row in 0 ... (totalEntries - 1) {
                    let thisPlace: StoredPlace = results[row] as! StoredPlace
                    let latitude = Double(thisPlace.latitude!)
                    let longitude = Double(thisPlace.longitude!)
                    let myLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)

                    if (thisPlace.poiType == "Weather") {
                        _ = addAnnotationOnLocation(coordinates: myLocation)
                    } else if (thisPlace.poiType == "POI") {
                        let myPlace = MKPlacemark(coordinate: myLocation)
                        dropPin(placemark: myPlace, title: thisPlace.title!, subTitle: thisPlace.subTitle!)
                    } else {
                        print("LoadLocation Error!!")
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if let location = locations.first {
        if let location = locations.last {
            myLocation.coordinate = location.coordinate
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }    
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        //for getDirections
        selectedPin = placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        insert(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude, titleString: annotation.title!, subTitleString: annotation.subtitle!, typeString: "POI")
    }
    
    func dropPin(placemark: MKPlacemark, title: String, subTitle: String) {
        //for getDirections
        selectedPin = placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = title
        annotation.subtitle = subTitle
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)

        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }    
}

extension ViewController {
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
       } else if annotation is CustomPointAnnotation {
            let reuseId = "test"
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView!.canShowCallout = true
            } else {
                anView!.annotation = annotation
            }
            let cpa = annotation as! CustomPointAnnotation
            anView!.image = UIImage(named: cpa.imageName)
            return anView
        } else if annotation is MKPointAnnotation {
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                
                pinView!.pinTintColor = UIColor.orange
                let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 30, height: 30)))
                button.setBackgroundImage(UIImage(named: "car"), for: .normal)
                button.addTarget(self, action: #selector(ViewController.getDirections), for: .touchUpInside)
                pinView!.leftCalloutAccessoryView = button
            } else {
                pinView!.annotation = annotation
            }
            return pinView
       } else {
            return nil
        }
    }
}





