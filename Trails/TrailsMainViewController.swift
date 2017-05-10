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
    let locationManager = LocationManager.shared.locationMananger
    var event: Event?
    var events: [Event]?
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: - actions
    
    
    //MARK: -  view load out
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        mapView.center.y = view.center.y + 500

    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addBottomSheetView()
        //        addPinDetailSheetView()
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
    
    func addPinDetailSheetView(event: Event) {
        
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let pinDetailSheetVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailTableViewController
            else { return }
        pinDetailSheetVC.event = event
        
        pinDetailSheetVC.loadView()
        pinDetailSheetVC.viewDidLoad()
        self.addChildViewController(pinDetailSheetVC)
        mapView.addSubview(pinDetailSheetVC.view)
        pinDetailSheetVC.didMove(toParentViewController: self)
        
        let height = view.frame.height
        let width = view.frame.width
        pinDetailSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY - 350, width: width, height: height)
    }
    func addApplePinDetailSheetView(placemark: MKPlacemark) {
        
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let pinDetailSheetVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailTableViewController
            else { return }
        pinDetailSheetVC.placemark = placemark
        pinDetailSheetVC.loadView()
        pinDetailSheetVC.viewDidLoad()
        self.addChildViewController(pinDetailSheetVC)
        mapView.addSubview(pinDetailSheetVC.view)
        pinDetailSheetVC.didMove(toParentViewController: self)
        
        let height = view.frame.height
        let width = view.frame.width
        pinDetailSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY - 240, width: width, height: height)
    }
    
    
    //MARK: - Location Manager
    func setupLocationManager() {
        
        locationManager.delegate = LocationManager.shared
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    //MARK: - opens apple maps for selected pin
    func presentDetailVC() {
        
        if let annotation = mapView.selectedAnnotations.first as? MyMKPointAnnotation,
            let event = annotation.event {
            
            addPinDetailSheetView(event: event)
        }
            
        else if let appleAnnotation = mapView.selectedAnnotations.first as? MyMKPointAnnotation,
            let placemark = appleAnnotation.placemark {
            addApplePinDetailSheetView(placemark: placemark)
            
        }
    }
}

//MARK: - extention for handleMapSearch protocol
extension TrailsMainViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark: MKPlacemark) {
        
        LocationManager.shared.selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MyMKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        annotation.placemark = placemark
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
            let annotation = MyMKPointAnnotation()
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            LocationManager.shared.selectedPin = MKPlacemark(coordinate: coordinate)
            annotation.coordinate = coordinate
            annotation.title = event.eventTitle
            annotation.subtitle = "\(event.city) \(event.state)"
            annotation.event = event
            
            mapView.addAnnotation(annotation)
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
        
        button.addTarget(self, action: #selector(TrailsMainViewController.presentDetailVC), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}

class MyMKPointAnnotation: MKPointAnnotation {
    var event: Event?
    var placemark: MKPlacemark?
}
