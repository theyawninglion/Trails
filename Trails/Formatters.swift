//
//  Formatters.swift
//  Trails
//
//  Created by Taylor Phillips on 5/11/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation
import UIKit

class Formatters {
    static func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let datea = formatter.date(from: dateString)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        guard let date = datea else { return "" }
        
        return formatter.string(from: date)
    }
    
    static func stripHTML(_ description: NSString) -> String {
        var stringToStrip = description
        var string = stringToStrip.range(of: "<.*?>", options: .regularExpression)
        while string.location != NSNotFound {
            stringToStrip = stringToStrip.replacingCharacters(in: string, with: "") as NSString
            string = stringToStrip.range(of: "<.*?>", options: .regularExpression)
        }
        return stringToStrip as String
    }
}

