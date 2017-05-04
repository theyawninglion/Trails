//
//  TrailsMainViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 3/20/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

//MARK: -  protocol that handles the pin drops

protocol HandleMapSearch: class { func dropPinZoomIn(_ placemark: MKPlacemark)
    
    func dropPinZoomIn(_ events: [Event])
}

class TrailsMainViewController: UIViewController {
    
    
    //MARK: - properties & outlets
    let locationMananger = LocationManager.shared.locationMananger
    var selectedPin:MKPlacemark? = nil
    var menuIsShowing = false
    
    var event: Event?
    var events: [Event]?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileMenuSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileMenuView: UIView!
    
    //MARK: - actions
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
    
    //MARK: -  view load out
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        sideMenu()
        mapView.center.y = view.center.y + 500
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
    
    //MARK: - bottom searchbar sliding sheet view
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
    
    //MARK: - Location Manager
    func setupLocationManager() {
        locationMananger.delegate = LocationManager.shared
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        locationMananger.requestWhenInUseAuthorization()
        locationMananger.requestLocation()
    }
    
    //MARK: - initial setup of the side menu
    func sideMenu() {
        profileMenuSideConstraint.constant = -250
        profileMenuView.layer.opacity = 0.9
        profileMenuView.layer.shadowOpacity = 0.2
        profileMenuView.layer.shadowRadius = 3
    }
    
    //MARK: - opens apple maps for selected pin
    func getDirections() {
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    // FIXME: - display selected pin information
    //MARK: - displays detail information on the selected pin
    func displayPinDetails() {
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        
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
    func dropPinZoomIn(_ events: [Event]) {
        
        mapView.removeAnnotations(mapView.annotations)
        for event in events {
            guard let longitude = Double(event.longitude),
                let latitude = Double(event.latitude)
                else { return }
            let annotation = MKPointAnnotation()
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            selectedPin = MKPlacemark(coordinate: coordinate)
            annotation.coordinate = coordinate
            annotation.title = event.eventTitle
            annotation.subtitle = "\(event.city) \(event.state)"
            
            
            mapView.addAnnotation(annotation)
//            let span = MKCoordinateSpanMake(0.05, 0.05)
//            let region = MKCoordinateRegionMake(coordinate, span)
//            mapView.setRegion(region, animated: true)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
}

//MARK: -  creation of pins
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
        
        if event?.smallImage != nil {
            button.setBackgroundImage(event?.smallImage, for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        }
        
        button.addTarget(self, action: #selector(TrailsMainViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
    
    //MARK: -  future feature that allows the user to change their location by pressing longer on the screen
    // FIXME: - long press to change location doesn't work
    
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
