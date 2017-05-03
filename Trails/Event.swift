//
//  Event.swift
//  Trails
//
//  Created by Taylor Phillips on 4/3/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation
import UIKit

class Event {
    
    private let latitudeKey = "latitude"
    private let longitudeKey = "longitude"
    private let eventURLKey = "url"
    private let cityKey = "city_name"
    private let countryKey = "country_name"
    private let startTimeKey = "start_time"
    private let stopTimeKey = "stop_time"
    private let descriptionKey = "description"
    private let eventTitleKey = "title"
    private let venueAddressKey = "venue_address"
    private let venueNameKey = "venue_name"
    private let venueURLKey = "venue_url"
    
    private let imageDictionaryKey = "image"
    private let largeImageDictionaryKey = "large"
    private let largeImageURLKey = "url"
    private let smallImageDictionaryKey = "small"
    private let smallImageURLKey = "url"
    
    
    
    let latitude: String
    let longitude: String
    let eventURL: String
    let city: String
    let country: String
    let startTime: String
    let stopTime: String?
    let description: String?
    let eventTitle: String
    var venueAddress: String
    let venueName: String
    let venueURL: String
    
    let largeImageURL: String?
    let smallImageURL: String?
    
    var largeImage: UIImage?
    var smallImage: UIImage?
    
    init?(dictionary: [String: Any]) {
        
        guard let latitude = dictionary[latitudeKey] as? String,
            let longitude = dictionary[longitudeKey] as? String,
            let eventURL = dictionary[eventURLKey] as? String,
            let city = dictionary[cityKey] as? String,
            let country = dictionary[countryKey] as? String,
            let startTime = dictionary[startTimeKey] as? String,
            let eventTitle = dictionary[eventTitleKey] as? String,
            let venueAddress =  dictionary[venueAddressKey] as? String,
            let venueName = dictionary[venueNameKey] as? String,
            let venueURL = dictionary[venueURLKey] as? String
            
            else { return nil }
        
        let imageDictionary = dictionary[imageDictionaryKey] as? [String:Any]
        let largeImageDictionary = imageDictionary?[largeImageDictionaryKey] as? [String:Any]
        let smallImageDictionary = imageDictionary?[smallImageDictionaryKey] as? [String:Any]
        
        
        self.latitude = latitude
        self.longitude = longitude
        self.eventURL = eventURL
        self.city = city
        self.country = country
        self.startTime = startTime
        self.stopTime = dictionary[stopTimeKey] as? String
        self.description = dictionary[descriptionKey] as? String
        self.eventTitle = eventTitle
        self.venueAddress = venueAddress
        self.venueName = venueName
        self.venueURL = venueURL
        
        self.largeImageURL = largeImageDictionary?[largeImageURLKey] as? String
        self.smallImageURL = smallImageDictionary?[smallImageURLKey] as? String
    }
}
