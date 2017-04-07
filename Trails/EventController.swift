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
    static let apiKey = "app_key"
    static let securityKey = "zHKbcM58mVrqnf8t"
    static let timeKey = "date"
    static let time = "Today"
    static let locationKey = "locatoin"
    static let categoryKey = "c"
    static func fetchEvent(for category: String, userLocation: String, completion: @escaping ([Event]) -> Void) {
        
        guard let url = baseURL else { completion([]) ; return }
        let urlParameters = [ apiKey : securityKey, timeKey: time, categoryKey: category, locationKey: userLocation]
        
        NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: urlParameters, body: nil) { (data, error) in
            if let error = error {
                NSLog("ERROR: NetworkController.EventController \(error.localizedDescription)")
                completion([])
                return
            }
            guard let data = data,
            let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any],
            let eventsArray = jsonDictionary["events"] as? [[String:Any]]
                else { completion([]); return }
            
            let events = eventsArray.flatMap({ Event(dictionary: $0) })
            
            // FIXME: - fetch array of images
//            for event in events {
//                ImageController.image(forURL: event.eventImageURLString, completion: { (eventImage) in
//                    event.eventImage = eventImage
//                })
//            }
            completion(events)
        }
       
    }
}
