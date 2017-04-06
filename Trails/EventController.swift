//
//  EventController.swift
//  Trails
//
//  Created by Taylor Phillips on 4/5/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation

class EventController {
    
    static let baseURL = URL(string: "http://api.eventful.com/")
    static let apiKey = "app_key=zHKbcM58mVrqnf8t"
    static let time = "date=Today"
    static let locationKey = "locatoin"
    static let categoryKey = "c"
    static func fetchEvent(for catagory: String, userLocation: String, completion: @escaping (Event?) -> Void) {
        
        guard let unwrappedUrl = baseURL else { completion(nil) ; return }
        
       
    }
}
