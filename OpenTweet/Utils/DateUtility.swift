//
//  DateUtility.swift
//  OpenTweet
//
//  Created by on 2024-05-08.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation

class DateUtility {
    
    static func formatDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
        
        if let date = isoFormatter.date(from: isoDate) {
            return displayFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
}
