//
//  PinAnnotationController.swift
//  Trails
//
//  Created by Taylor Phillips on 5/4/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation
import MapKit



//class PinAnnotationController: HandleMapSearch {
//    
//    var selectedPin:MKPlacemark? = nil
//    let mapView = MKMapView()
//    static let shared = PinAnnotationController()
//    
//    func dropPinZoomIn(_ placemark: MKPlacemark) {
//        
//        selectedPin = placemark
//        mapView.removeAnnotations(mapView.annotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = placemark.coordinate
//        annotation.title = placemark.name
//        if let city = placemark.locality, let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        mapView.addAnnotation(annotation)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(placemark.coordinate, span)
//        mapView.setRegion(region, animated: true)
//    }
//    func dropPinZoomIn(_ events: [Event]) {
//        
//        mapView.removeAnnotations(mapView.annotations)
//        for event in events {
//            guard let longitude = Double(event.longitude),
//                let latitude = Double(event.latitude)
//                else { return }
//            let annotation = MKPointAnnotation()
//            
//            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
//            selectedPin = MKPlacemark(coordinate: coordinate)
//            annotation.coordinate = coordinate
//            annotation.title = event.eventTitle
//            annotation.subtitle = "\(event.city) \(event.state)"
//            
//            mapView.addAnnotation(annotation)
//            let span = MKCoordinateSpanMake(0.05, 0.05)
//            let region = MKCoordinateRegionMake(coordinate, span)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//
//}
