//
//  LocationManager.swift
//  Trails
//
//  Created by Taylor Phillips on 5/2/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var selectedPin:MKPlacemark? = nil
    
    var locationMananger = CLLocationManager()
    var mapView = MKMapView()
    var cityName: String?
    var zipCode: String?
    
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
