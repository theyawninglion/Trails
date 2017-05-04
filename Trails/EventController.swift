//
//  EventController.swift
//  Trails
//
//  Created by Taylor Phillips on 4/5/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation

class EventController {
    
    static let baseURL = URL(string: "http://api.eventful.com/json/events/search")
    static let apiKey = "app_key"
    static let securityKey = "zHKbcM58mVrqnf8t"
    static let timeKey = "date"
    static let time = "Today"
    static let locationKey = "locatoin"
    static let categoryKey = "c"
    static let imageKey = "image_sizes"
    static let imageSizes = "small,block100,large"
    static let distanceKey = "within"
    static func fetchEvent(category: String, userLocation: String, completion: @escaping ([Event]) -> Void) {
        
        guard let url = baseURL else { completion([]) ; return }
        let urlParameters = [ apiKey : securityKey, timeKey: time, imageKey: imageSizes,  categoryKey: category, locationKey: userLocation]
        
        NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: urlParameters, body: nil) { (data, error) in
            if let error = error {
                NSLog("ERROR: NetworkController.EventController \(error.localizedDescription)")
                completion([])
                return
            }
            guard let data = data,
            let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any],
            let eventsDictionary = jsonDictionary["events"] as? [String:Any],
            let eventsArray = eventsDictionary["event"] as? [[String: Any]]
                
                else { completion([]); return }
            
            let events = eventsArray.flatMap({ Event(dictionary: $0) })
            
//            
//            for event in events {
//                guard let largeImageURL = event.largeImageURL, let smallImageURL = event.smallImageURL
//                    else {completion([]); return }
//                
//                ImageController.image(forURL: largeImageURL, completion: { (image) in
//                    event.largeImage = image
//                })
//                ImageController.image(forURL: smallImageURL, completion: { (image) in
//                    event.smallImage = image
//                })
//            }

            print(events.first?.venueAddress ?? "nothing there")
            completion(events)
            
        }
       
    }
}
