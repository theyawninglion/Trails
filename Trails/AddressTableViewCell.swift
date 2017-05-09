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

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!

    @IBAction func goButtonTapped(_ sender: Any) {
        guard let selectedPin = LocationManager.shared.selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)

    }
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    func updateViews() {
        guard let event = event
            else { return }
        addressLabel.text = event.venueAddress
        cityStateLabel.text = "\(event.city) \(event.state)"
    }
    
}
