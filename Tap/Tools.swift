//
//  Tools.swift
//  Tap
//
//  Created by user on 2022/7/11.
//

import Foundation

class Tool {
    
    static func TodayDateString() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: now)
    }
    
    static func CurrentTimeString() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: now)
    }
    
}
