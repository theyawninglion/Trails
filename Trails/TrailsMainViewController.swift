//
//  TrailsMainViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 3/20/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

//MARK: -  protocol

protocol HandleMapSearch: class { func dropPinZoomIn(_ placemark: MKPlacemark) }

class TrailsMainViewController: UIViewController{
    
    static let shared = TrailsMainViewController()
    
    //MARK: - search controller properties
    
    let locationMananger = CLLocationManager()
    var selectedPin:MKPlacemark? = nil
    var menuIsShowing = false
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileMenuSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileMenuView: UIView!
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        
        if menuIsShowing {
            profileMenuSideConstraint.constant = -250
            menuAnimation()
        } else {
            profileMenuSideConstraint.constant = 0
            menuAnimation()
        }
        menuIsShowing = !menuIsShowing
    }
    @IBAction func apiCallButtonTapped(_ sender: Any) {
        guard let location = self.cityName else { return }
        let music = "music"
        EventController.fetchEvent(category: music, userLocation: location) { (_) in
            
        }
        
    }
    
    //MARK: -  view load out
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        sideMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addBottomSheetView()
        
    }
    
    //MARK: - animation
    
    func menuAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - bottom sheet view
    
    func addBottomSheetView() {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        guard let bottomSheetVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        bottomSheetVC.loadView()
        bottomSheetVC.viewDidLoad()
        bottomSheetVC.mapView = mapView
        bottomSheetVC.handleMapSearchDelegate = self
        self.addChildViewController(bottomSheetVC)
        mapView.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        let height = view.frame.height
        let width = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    //MARK: - searchBarMapDisplay
    
    func setupLocationManager() {
        locationMananger.delegate = self
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        locationMananger.requestWhenInUseAuthorization()
        locationMananger.requestLocation()
    }
    
    func sideMenu() {
        profileMenuSideConstraint.constant = -250
        profileMenuView.layer.opacity = 0.9
        profileMenuView.layer.shadowOpacity = 0.2
        profileMenuView.layer.shadowRadius = 3
    }
    
    func getDirections() {
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    var cityName: String?
    var zipCode: String?
}



//MARK: - extention for CLLocationManager

extension TrailsMainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationMananger.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.095, 0.095)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                guard let addressDict = placemarks?[0].addressDictionary else {
                    return
                }
                
                // Print each key-value pair in a new row
                addressDict.forEach { print($0) }
                
                // Print fully formatted address
                if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                    print(formattedAddress.joined(separator: ", "))
                }
                
                // Access each element manually
                if let locationName = addressDict["Name"] as? String {
                    print(locationName)
                }
                if let street = addressDict["Thoroughfare"] as? String {
                    print(street)
                }
                if let city = addressDict["City"] as? String {
                    self.cityName = city
                    print(city)
                }
                if let zip = addressDict["ZIP"] as? String {
                    self.zipCode = zip
                    print(zip)
                }
                if let country = addressDict["Country"] as? String {
                    print(country)
                }
            })

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}



//MARK: - extention for handleMapSearch protocol

extension TrailsMainViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark: MKPlacemark) {
        
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension TrailsMainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        pinView?.pinTintColor = .orange
        pinView?.canShowCallout  = true
        let smallSquare = CGSize(width: 30, height: 30)
        
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(TrailsMainViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
    
    func didLongPressMap(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Your position"
            mapView.addAnnotation(annotation) //drops the pin
            print("lat:  \(touchCoordinate.latitude)")
            let num = touchCoordinate.latitude as NSNumber
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 4
            formatter.minimumFractionDigits = 4
            let str = formatter.string(from: num)
            print("long: \(touchCoordinate.longitude)")
            let num1 = touchCoordinate.longitude as NSNumber
            let formatter1 = NumberFormatter()
            formatter1.maximumFractionDigits = 4
            formatter1.minimumFractionDigits = 4
            let str1 = formatter1.string(from: num1)
            //            adressLoLa.text = "\(num),\(num1)"
            
            // Add below code to get address for touch coordinates.
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                guard let addressDict = placemarks?[0].addressDictionary else {
                    return
                }
                
                // Print each key-value pair in a new row
                addressDict.forEach { print($0) }
                
                // Print fully formatted address
                if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                    print(formattedAddress.joined(separator: ", "))
                }
                
                // Access each element manually
                if let locationName = addressDict["Name"] as? String {
                    print(locationName)
                }
                if let street = addressDict["Thoroughfare"] as? String {
                    print(street)
                }
                if let city = addressDict["City"] as? String {
                    print(city)
                }
                if let zip = addressDict["ZIP"] as? String {
                    print(zip)
                }
                if let country = addressDict["Country"] as? String {
                    print(country)
                }
            })
        }
    }
    
}
