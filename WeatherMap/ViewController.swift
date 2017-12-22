//
//  ViewController.swift
//  WeatherMap
//
//  Created by 黃健偉 on 2017/12/20.
//  Copyright © 2017年 黃健偉. All rights reserved.
//  http://media.bemyapp.com/integrate-alamofire-swift/
//

import UIKit
import MapKit
import Alamofire

class ViewController: UIViewController, MKMapViewDelegate {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func LongPress(_ sender: UILongPressGestureRecognizer) {
        handleLongPress(gestureRecognizer: sender)
    }
    
    let OpenWeatherAPIKey = "cc97bcab2f8e89e1d4a5af6e6029022f"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            addAnnotationOnLocation(coordinates: newCoordinates)
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

    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
    }

    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = MapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.canShowCallout = true
        } else {
            anView?.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        anView?.image = UIImage(named:cpa.imageName)
        
        return anView
    }
}

extension ViewController : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
