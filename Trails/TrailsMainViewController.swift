//
//  TrailsMainViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 3/20/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark: MKPlacemark)
}

class TrailsMainViewController: UIViewController{
    
    
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var profileMenuSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileMenuView: UIView!
    
    var selectedPin:MKPlacemark? = nil
    var resultSearchController: UISearchController? = nil
    var menuIsShowing = false
    let locationMananger = CLLocationManager()
    
    
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
    
    //MARK: - animation
    func menuAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView()
        sideMenu()
        locationMananger.delegate = self
        locationMananger.desiredAccuracy = kCLLocationAccuracyBest
        locationMananger.requestWhenInUseAuthorization()
        locationMananger.requestLocation()
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as!LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        //searchBar?.resignFirstResponder()
        navigationItem.titleView = resultSearchController?.searchBar
        
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mainMapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    //func mapView() {
        
        
   // }
    func sideMenu(){
        
        profileMenuSideConstraint.constant = -250
        profileMenuView.layer.opacity = 0.9
        profileMenuView.layer.shadowOpacity = 0.5
        profileMenuView.layer.shadowRadius = 6
    }
    func getDirections() {
        guard let selectedPin = selectedPin else { return }
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
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
            mainMapView.setRegion(region, animated: true)
            
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
        mainMapView.removeAnnotations(mainMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mainMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mainMapView.setRegion(region, animated: true)
    }
}
extension TrailsMainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mainMapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView?.pinTintColor = .orange
        pinView?.canShowCallout  = true
        let smallSquare = CGSize(width: 30, height: 30)
        let CGPointZero = CGPoint(x: 0, y: 0)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(TrailsMainViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
}
