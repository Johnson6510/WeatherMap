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
    let urlTwUv = "http://opendata2.epa.gov.tw/UV/UV.json"
    var isPm2d5: Bool = false

    let OpenWeatherAPIKey = "cc97bcab2f8e89e1d4a5af6e6029022f"

    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark! = nil
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let entityName = "StoredPlace"
    let entity = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredPlace")
    var myLocation = MKPointAnnotation()
    var selectedAnnotation = MKPointAnnotation()
    var pm2d5Annotations = [CustomPointAnnotation()]
    
    @IBAction func returnHome(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: myLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    let sites: [String: [String: Double]] = [
        "麥寮": ["longitude": 120.25626620000003 ,"latitude": 23.7485306],
        "關山": ["longitude": 121.16463390000001 ,"latitude": 23.0495603],
        "馬公": ["longitude": 119.57746159999999 ,"latitude": 23.5706269],
        "金門": ["longitude": 118.3285644        ,"latitude": 24.3487792],
        "馬祖": ["longitude": 119.95166519999998 ,"latitude": 26.160243 ],
        "埔里": ["longitude": 120.96468660000005 ,"latitude": 23.9932872],
        "復興": ["longitude": 120.31172220000008 ,"latitude": 22.6083352],
        "永和": ["longitude": 121.51453530000003 ,"latitude": 25.0103251],
        "竹山": ["longitude": 120.68900550000001 ,"latitude": 23.712201 ],
        "中壢": ["longitude": 121.20539630000007 ,"latitude": 24.9721514],
        "三重": ["longitude": 121.48671139999999 ,"latitude": 25.0614534],
        "冬山": ["longitude": 121.75374039999997 ,"latitude": 24.631919 ],
        "宜蘭": ["longitude": 121.73775019999994 ,"latitude": 24.7021073],
        "陽明": ["longitude": 121.51727219999998 ,"latitude": 25.0921827],
        "花蓮": ["longitude": 121.61119489999999 ,"latitude": 23.9910732],
        "臺東": ["longitude": 121.14381520000006 ,"latitude": 22.7613207],
        "恆春": ["longitude": 120.74476379999999 ,"latitude": 22.0008277],
        "潮州": ["longitude": 120.54026720000002 ,"latitude": 22.5514922],
        "屏東": ["longitude": 120.5487597        ,"latitude": 22.5519759],
        "小港": ["longitude": 120.36084549999998 ,"latitude": 22.5553185],
        "前鎮": ["longitude": 120.31472080000003 ,"latitude": 22.5970794],
        "前金": ["longitude": 120.29453620000004 ,"latitude": 22.6254162],
        "左營": ["longitude": 120.29165239999998 ,"latitude": 22.6877358],
        "楠梓": ["longitude": 120.30318710000006 ,"latitude": 22.7175372],
        "林園": ["longitude": 120.4011911        ,"latitude": 22.4986756],
        "大寮": ["longitude": 120.4011911        ,"latitude": 22.584481 ],
        "鳳山": ["longitude": 120.3493158        ,"latitude": 22.6113591],
        "仁武": ["longitude": 120.36084549999998 ,"latitude": 22.6947932],
        "橋頭": ["longitude": 120.30895409999994 ,"latitude": 22.7539012],
        "美濃": ["longitude": 120.55093579999993 ,"latitude": 22.885385 ],
        "臺南": ["longitude": 120.22702770000001 ,"latitude": 22.9997281],
        "安南": ["longitude": 120.13583459999995 ,"latitude": 23.0585336],
        "善化": ["longitude": 120.30895409999994 ,"latitude": 23.1402613],
        "新營": ["longitude": 120.30895409999994 ,"latitude": 23.3119567],
        "嘉義": ["longitude": 120.44911130000003 ,"latitude": 23.4800751],
        "臺西": ["longitude": 120.19356629999993 ,"latitude": 23.7229714],
        "朴子": ["longitude": 120.25704210000004 ,"latitude": 23.4464152],
        "新港": ["longitude": 120.3550808        ,"latitude": 23.538123 ],
        "崙背": ["longitude": 120.3531749        ,"latitude": 23.7601594],
        "斗六": ["longitude": 120.54090889999998 ,"latitude": 23.7077947],
        "南投": ["longitude": 120.67750539999997 ,"latitude": 23.9179637],
        "二林": ["longitude": 120.4011911        ,"latitude": 23.9141358],
        "線西": ["longitude": 120.46220160000007 ,"latitude": 24.1316695],
        "彰化": ["longitude": 120.5624474        ,"latitude": 24.0716583],
        "西屯": ["longitude": 120.6424333        ,"latitude": 24.1769764],
        "忠明": ["longitude": 120.66361430000006 ,"latitude": 24.1588789],
        "大里": ["longitude": 120.68121139999994 ,"latitude": 24.1046899],
        "沙鹿": ["longitude": 120.58546739999997 ,"latitude": 24.2377939],
        "豐原": ["longitude": 120.72235720000003 ,"latitude": 24.2521156],
        "三義": ["longitude": 120.76947599999994 ,"latitude": 24.3892633],
        "苗栗": ["longitude": 120.81543579999993 ,"latitude": 24.5711502],
        "頭份": ["longitude": 120.90248359999998 ,"latitude": 24.6884438],
        "新竹": ["longitude": 120.96747979999998 ,"latitude": 24.8138287],
        "竹東": ["longitude": 121.04497679999997 ,"latitude": 24.774922 ],
        "湖口": ["longitude": 121.04497679999997 ,"latitude": 24.8814458],
        "龍潭": ["longitude": 121.20539630000007 ,"latitude": 24.8444927],
        "平鎮": ["longitude": 121.20539630000007 ,"latitude": 24.9296022],
        "觀音": ["longitude": 121.11375440000006 ,"latitude": 25.0359365],
        "大園": ["longitude": 121.19394499999999 ,"latitude": 25.0492632],
        "桃園": ["longitude": 121.30097980000005 ,"latitude": 24.9936281],
        "大同": ["longitude": 121.51130639999997 ,"latitude": 25.0627243],
        "松山": ["longitude": 121.56386210000005 ,"latitude": 25.0541591],
        "古亭": ["longitude": 121.52747870000007 ,"latitude": 25.021694 ],
        "萬華": ["longitude": 121.49702939999997 ,"latitude": 25.0262857],
        "中山": ["longitude": 121.54270930000007 ,"latitude": 25.0792018],
        "士林": ["longitude": 121.52460769999993 ,"latitude": 25.0950492],
        "淡水": ["longitude": 121.44337059999998 ,"latitude": 25.1719805],
        "林口": ["longitude": 121.38813779999998 ,"latitude": 25.0790108],
        "菜寮": ["longitude": 121.49215600000002 ,"latitude": 25.060274 ],
        "新莊": ["longitude": 121.41783469999996 ,"latitude": 25.0265985],
        "板橋": ["longitude": 121.46184149999999 ,"latitude": 25.0114095],
        "土城": ["longitude": 121.43803400000002 ,"latitude": 24.968371 ],
        "新店": ["longitude": 121.53948220000007 ,"latitude": 24.978282 ],
        "萬里": ["longitude": 121.63971839999999 ,"latitude": 25.1676024],
        "汐止": ["longitude": 121.63971839999999 ,"latitude": 25.0616059],
        "基隆": ["longitude": 121.73918329999992 ,"latitude": 25.1276033],
   ]

    @IBAction func showPM2d5(_ sender: Any) {
        isPm2d5 = !isPm2d5
        if isPm2d5 {
            //create annotations
            let parameters: Parameters = ["foo": "bar"]
            let urlPm2d5 = "http://opendata.epa.gov.tw/ws/Data/ATM00625/?$format=json"
            Alamofire.request(urlPm2d5, parameters: parameters).responseJSON { response in
                DispatchQueue.main.async {
                    guard response.result.isSuccess else {
                        let errorMessage = response.result.error?.localizedDescription
                        print(errorMessage!)
                        return
                    }
                    guard let JSON = response.result.value as? Array<Dictionary<String,String>> else {
                        print("JSON formate error")
                        return
                    }
                    //print(JSON)
                    for key in 0..<JSON.count {
                        if let site = JSON[key]["Site"] {
                            let country = JSON[key]["county"]
                            let pm25 = JSON[key]["PM25"]
                            //print(self.sites[site]!["longitude"] ?? 0)
                            //print(self.sites[site]!["latitude"] ?? 0)
                            //print(country! + ", " + site)
                            //print(pm25 ?? -1)
                            var coordinates = CLLocationCoordinate2D()
                            coordinates.longitude = self.sites[site]!["longitude"]!
                            coordinates.latitude = self.sites[site]!["latitude"]!
                            self.addPM2d5Annotation(coordinates: coordinates, title: country! + ", " + site, subtitle: pm25!)

                        }
                    }
                }
            }
        } else {
            //remove annotations
            for annotation in pm2d5Annotations {
                self.mapView.removeAnnotation(annotation)
            }
        }
    }
    
    func addPM2d5Annotation(coordinates: CLLocationCoordinate2D, title: String, subtitle: String) {
        let annotation = CustomPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.imageName = "air5"
        if let pm25 = Int(subtitle) {
            switch pm25 {
            case 0...11:
                annotation.imageName = "air1"
            case 12...23:
                annotation.imageName = "air1"
            case 24...35:
                annotation.imageName = "air2"
            case 36...41:
                annotation.imageName = "air2"
            case 42...47:
                annotation.imageName = "air3"
            case 48...53:
                annotation.imageName = "air3"
            case 54...58:
                annotation.imageName = "air4"
            case 59...64:
                annotation.imageName = "air4"
            case 65...70:
                annotation.imageName = "air5"
            case 71...999:
                annotation.imageName = "air5"
            default:
                annotation.imageName = "air5"
            }
        }
        self.mapView.addAnnotation(annotation)
        pm2d5Annotations.append(annotation)
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
        annotation.imageName = "50d"
        
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
                print(JSON)
                annotation.title = "\(JSON["name"]!), \(JSON["sys"]!["country"]! ?? "")"
                annotation.subtitle = "\(JSON["main"]!["temp"]! ?? 0)(\(JSON["main"]!["temp_min"]! ?? 0)~\(JSON["main"]!["temp_max"]! ?? 0)) ℃"

                if let weather = JSON["weather"] as? [[String: AnyObject]] {
                    annotation.imageName = weather[0]["icon"] as! String// + ".png"
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
        annotation.imageName = "50d"
        
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
                    annotation.imageName = weather[0]["icon"] as! String// + ".png"
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

    @objc func getDirections() {
        selectedPin = MKPlacemark(coordinate: selectedAnnotation.coordinate)
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            print(mapItem.placemark.coordinate)
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
        //print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }    
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark){
        //for getDirections
        //selectedPin = placemark
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
        //selectedPin = placemark
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
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKPointAnnotation {
            self.selectedAnnotation = (view.annotation as? MKPointAnnotation)!
        }
    }
    
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





