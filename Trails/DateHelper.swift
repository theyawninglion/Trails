//
//  DateHelper.swift
//  Trails
//
//  Created by Taylor Phillips on 4/5/17.
//  Copyright © 2017 Taylor Phillips. All rights reserved.
//

import Foundation

extension Date{
    func stringValue() -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return formatter.string(from: self)
    }
}
