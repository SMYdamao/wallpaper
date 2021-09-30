//
//  WAUtils.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/30.
//

import Foundation

class WAUtils {
    class func cachePath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }
}
