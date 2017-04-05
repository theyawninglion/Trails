//
//  Event.swift
//  Trails
//
//  Created by Taylor Phillips on 4/3/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation

class Event {
    private let latitudeKey = "latitude"
    private let longitudeKey = "longitude"
    private let countryKey = "country_name"
    private let cityKey = "city_name"
    private let addressKey = "venue_address"
    private let titleKey = "title"
    private let startTimeKey = "start_time"
    private let stopTimeKey = "stop_time"
    private let eventNameKey = "venue_name"
    private let descriptionKey = "description"

    
    let latitude: Double
    let longitude: Double
    let country: String
    let city: String
    let address: String
    let title: String
    let startTime: Date
    let stopTime: Date
    let eventName: String
    let description: String
    
    init(latitude: Double, longitude: Double, country: String, city: String, address: String, title: String, startTime: Date, stopTime: Date, eventName: String, description: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.city = city
        self.address = address
        self.title = title
        self.startTime = startTime
        self.stopTime = stopTime
        self.eventName = eventName
        self.description = description
    }
    
    init?(dictionary: [String: Any]) {
        guard let latitude = dictionary[latitudeKey] as? Double,
        let longitude = dictionary[longitudeKey] as? Double,
        let country = dictionary[countryKey] as? String,
        let city = dictionary[cityKey] as? String,
        let address = dictionary[addressKey] as? String,
        let title = dictionary[titleKey] as? String,
        let startTime = dictionary[startTimeKey] as? Date,
        let stopTime = dictionary[stopTimeKey] as? Date,
        let eventName = dictionary[eventNameKey] as? String,
        let description = dictionary[descriptionKey] as? String
            else { return nil }
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.city = city
        self.address = address
        self.title = title
        self.startTime = startTime
        self.stopTime = stopTime
        self.eventName = eventName
        self.description = description
    }
}
