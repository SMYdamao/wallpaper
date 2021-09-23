//
//  Date+Wallpaper.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Foundation

extension Date {
    static func currentDate(_ format: String? = nil) -> String {
        let date = Date.init()
        let formatter = DateFormatter.init()
        formatter.dateFormat = format ?? "yyyy-HH-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
