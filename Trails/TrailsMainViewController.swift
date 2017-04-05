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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileMenuSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileMenuView: UIView!
    
    static let shared = TrailsMainViewController()
    
    //MARK: - search controller properties
    var selectedPin:MKPlacemark? = nil
    let locationMananger = CLLocationManager()
    

    var menuIsShowing = false
    
    
    
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
    }
    
    
    
    //MARK: - animation
    func menuAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - bottom sheet view
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addBottomSheetView()
        
    }
    
    func addBottomSheetView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bottomSheetVC = storyboard.instantiateViewController(withIdentifier: "BottomSheetViewController")
        bottomSheetVC.loadView()
        bottomSheetVC.viewDidLoad()
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
    
    //MARK: - searchBar
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


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
}
