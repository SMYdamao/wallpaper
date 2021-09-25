//
//  WACacheHelper.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import AppKit

struct WACacheHelper {
    static var document: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    static func savePath(for key: String, suffix: String? = nil) -> String {
        let path = document.appending("/Wallpaper/Cache")
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        if let s = suffix {
            return path.appending("/\(key).\(s)")
        } else {
            return path.appending("/\(key)")
        }
    }
    
    static func deletePath(for key: String, suffix: String? = nil) -> Bool {
        var path = document.appending("/Wallpaper/Cache")
        if let s = suffix {
            path = path.appending("/\(key).\(s)")
        } else {
            path = path.appending("/\(key)")
        }
        var result: Bool = false
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                result = true
            } catch {
                result = false
            }
        } else {
            result = true
        }
        return result
    }
    
    static func clearCache() {
        let path = document.appending("/Wallpaper/Cache")
        try? FileManager.default.removeItem(atPath: path)
    }
}
