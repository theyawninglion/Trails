//
//  AddressTableViewCell.swift
//  Trails
//
//  Created by Taylor Phillips on 5/5/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

class AddressTableViewCell: UITableViewCell {
    
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak var cityStateLabel: UILabel!
//    @IBOutlet weak var goButton: UIButton!
//    @IBOutlet weak var startTimeTextView: UITextView!
//    
//    @IBAction func goButtonTapped(_ sender: Any) {
//        guard let selectedPin = LocationManager.shared.selectedPin else { return }
//        let mapItem = MKMapItem(placemark: selectedPin)
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
//        mapItem.openInMaps(launchOptions: launchOptions)
//        
//        
//    }
//    var event: Event?
//    var placemark: MKPlacemark?
//    
//    func updateViews() {
//        
//        
//        if self.placemark != nil {
//            guard let placemark = placemark else { return }
//            guard let city = placemark.locality,
//                let state = placemark.administrativeArea,
//                let zipcode = placemark.postalCode,
//                let address = placemark.addressDictionary?.first?.value
//                else { return }
//            addressLabel.text = "\(address)"
//            cityStateLabel.text = "\(city) \(state) \(zipcode)"
//            startTimeTextView.text = ""
//            
//        } else {
//            
//            var address: String
//            guard let event = event else { return }
//            if event.venueAddress == nil {
//                address = "\(event.longitude) \(event.longitude)"
//            } else {
//                guard let venueAddress = event.venueAddress else {
//                    return
//                }
//                address = venueAddress
//            }
//            addressLabel.text = address
//            cityStateLabel.text = "\(event.city) \(event.state) \(event.postalCode)"
//            var endTime = ""
//            
//            if event.stopTime != nil {
//                endTime = "Ends: \(event.stopTime ?? "")"
//            }
//            startTimeTextView.text = "Starts: \(event.startTime)\n\(endTime)"
//        }
//    }
    
    
}
