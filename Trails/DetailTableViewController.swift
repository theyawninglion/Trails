//
//  DetailTableViewController.swift
//  Trails
//
//  Created by Taylor Phillips on 5/5/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit
import MapKit

class DetailTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var startTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func closeButtonTapped(_ sender: Any) {
                let width = self.view.frame.width
                let height = self.view.frame.height
        
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
                    self.view.frame = CGRect(x: 0, y: self.closeView, width: width, height: height)
                })

        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func goButtonTapped(_ sender: Any) {
        guard let selectedPin = LocationManager.shared.selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
 
    
    
    let fullView: CGFloat = 100
    var halfView: CGFloat = 275
    var closeView: CGFloat {
    return UIScreen.main.bounds.height
    }
    var bottomView: CGFloat {
        return UIScreen.main.bounds.height - 108
    }
    

    var event: Event?
    var placemark: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gesture()
        updateViews()

    }
    
    //MARK: -  view
    
    func updateViews() {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        goButton.layer.cornerRadius = 10
        goButton.clipsToBounds = true
        
        if self.placemark != nil {
            guard let placemark = placemark else { return }
            eventTitleLabel.text = placemark.name
            guard let city = placemark.locality,
            let state = placemark.administrativeArea,
            let zipcode = placemark.postalCode,
            let address = placemark.addressDictionary?.first?.value
                else { return }
            addressLabel.text = "\(address)"
            cityStateLabel.text = "\(city) \(state) \(zipcode)"
            startTextView.text = ""
            descriptionTextView.text = ""
            
        } else {
            
            var address: String
            guard let event = event else { return }
            eventTitleLabel.text = event.eventTitle
            if event.venueAddress == nil {
                address = "\(event.longitude) \(event.longitude)"
            } else {
                guard let venueAddress = event.venueAddress else {
                    return
                }
                address = venueAddress
            }
            addressLabel.text = address
            cityStateLabel.text = "\(event.city) \(event.state) \(event.postalCode)"
            var endTime = ""
            
            if event.stopTime != nil {
                endTime = "Ends: \(event.stopTime ?? "")"
            }
            startTextView.text = "Starts: \(event.startTime)\n\(endTime)"
            descriptionTextView.text = "At: \(event.venueName)\n\(event.description ?? "")\n\(event.eventURL)\n\(event.venueURL)"
        }
    }
    
    //MARK: - tableview datasource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = UITableViewAutomaticDimension
        
        switch indexPath.row {
        case 0 :
            height = eventTitleLabel.frame.height + 40
            return height
        case 1:
            height = 123
            return height
        case 2 :
            height = descriptionTextView.frame.height
            return height
            
        default:
        return height
        }
    }
    
    //MARK: -  pan gesture
    
    func gesture() {
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(SearchViewController.panGesture))
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        if (y + translation.y >= fullView) && (y + translation.y <= bottomView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: width, height: height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        if recognizer.state == .ended {
            var duration = velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((bottomView - y) / velocity.y)
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.bottomView, width: width, height: height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: width, height: height)
                }
            }, completion: { [weak self] _ in
                if velocity.y < 0 {
                    self?.tableView.isScrollEnabled = true
                }
            })
        }
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let gesture = gestureRecognizer as! UIPanGestureRecognizer
        let direction = gesture.velocity(in: view).y
        let y = view.frame.minY
        
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0 ) || (y == bottomView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        return false
    }


}
