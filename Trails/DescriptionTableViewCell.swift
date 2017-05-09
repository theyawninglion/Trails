//
//  DescriptionTableViewCell.swift
//  Trails
//
//  Created by Taylor Phillips on 5/5/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var event: Event?{
        didSet{
            updateViews()
        }
    }
    func updateViews(){
        guard let event = event
            else { return }
        var endTime = ""

        if event.stopTime != nil {
            endTime = "Ends:\(event.stopTime ?? "")"
        }
        startTimeLabel.text = "Starts:\(event.startTime) \(endTime)"
        descriptionTextView.text = event.description
    }
}
