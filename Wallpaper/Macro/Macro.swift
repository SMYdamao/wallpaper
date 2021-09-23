//
//  Macro.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Foundation

// Pixabay密钥
let WAPixabayAccesskey = "12956784-91c84f326fcbd73df660f8c5b"

// 图片质量
let WAUpdateImageQualityNotification = NSNotification.Name.init(rawValue: "is.updateImageQualityNotification")
// 清理缓存
let WACleanCacheNotification = NSNotification.Name.init(rawValue: "is.cleanCacheNotification")
// 开机自启
let WAStartUpNotification = NSNotification.Name.init(rawValue: "is.startUpNotification")

let WAAutoChangeTimes: [String] = [NSLocalizedString("WAAutoTimeOff", comment: "关"), NSLocalizedString("WAAutoTime15", comment: "15分钟"), NSLocalizedString("WAAutoTime30", comment: "30分钟"), NSLocalizedString("WAAutoTime45", comment: "45分钟"), NSLocalizedString("WAAutoTime60", comment: "1小时"), NSLocalizedString("WAAutoTime120", comment: "2小时"), NSLocalizedString("WAAutoTime1", comment: "1天")]
let WAImageQualitys: [String] = [NSLocalizedString("WAPreviewQuilatySmall", comment: "低质量"), NSLocalizedString("WAPreviewQuilatyMedium", comment: "中等质量"), NSLocalizedString("WAPreviewQuilatyFull", comment: "高质量")]

let WAPlaceholderColors: [String] = ["24a19c", "0f4c75", "6ebfb5", "3b2e5a", "fe91ca", "251f44", "e8505b", "2bb2bb", "162447", "e19999", "eb6383", "fa744f", "4d3e3e", "562349", "63b7af", "58b4ae", "00005c", "bb3b0e", "c3edea", "00263b", "565d47", "d92027", "10375c", "222831", "364f6b", "aa96da", "8785a2", "2b2e4a", "e84545", "ffb6b9", "48466d", "00b8a9", "ffcfdf", "522546", "c06c84", "355c7d", "f07b3f", "303841", "f85f73", "00e0ff", "62d2a2", "1fab89", "15b7b9", "ebfffa", "fefaec", "155263", "aedefc", "7c7575", "fbf0f0", "9e579d", "a393eb", "ff847c", "726a95"]

let isSearchColors: [[String: String]] = [
    ["title": NSLocalizedString("WAGrayscaleColor", comment: "grayscale"), "image": "grayscale_color", "key": "grayscale"],
    ["title": NSLocalizedString("WATransparentColor", comment: "transparent"), "image": "transparent_color", "key": "transparent"],
    ["title": NSLocalizedString("WARedColor", comment: "red"), "image": "red_color", "key": "red"],
    ["title": NSLocalizedString("WAOrangeColor", comment: "orange"), "image": "orange_color", "key": "orange"],
    ["title": NSLocalizedString("WAYellowColor", comment: "yellow"), "image": "yellow_color", "key": "yellow"],
    ["title": NSLocalizedString("WAGreenColor", comment: "green"), "image": "green_color", "key": "green"],
    ["title": NSLocalizedString("WATurquoiseColor", comment: "turquoise"), "image": "turquoise_color", "key": "turquoise"],
    ["title": NSLocalizedString("WABlueColor", comment: "blue"), "image": "blue_color", "key": "blue"],
    ["title": NSLocalizedString("WALilacColor", comment: "lilac"), "image": "lilac_color", "key": "lilac"],
    ["title": NSLocalizedString("WAPinkColor", comment: "pink"), "image": "pink_color", "key": "pink"],
    ["title": NSLocalizedString("WAWhiteColor", comment: "white"), "image": "white_color", "key": "white"],
    ["title": NSLocalizedString("WAGrayColor", comment: "gray"), "image": "gray_color", "key": "gray"],
    ["title": NSLocalizedString("WABlackColor", comment: "black"), "image": "black_color", "key": "black"],
    ["title": NSLocalizedString("WABrownColor", comment: "brown"), "image": "brown_color", "key": "brown"]]

// log
func WALog(_ item: Any) {
    #if DEBUG
    print(item)
    #endif
}

// 版本比较
func compareVersion(_ version1: String, _ version2: String) -> ComparisonResult {
    let array1 = version1.split(separator: ".")
    let array2 = version2.split(separator: ".")
    let minLength = min(array1.count, array2.count)
    
    var temp1 : String
    var temp2 : String
    for i in 0..<minLength {
        
        temp1 = "\(array1[i])"
        temp2 = "\(array2[i])"
        if Int(temp1)! > Int(temp2)! {
            return .orderedDescending
        } else if Int(temp1)! < Int(temp2)! {
            return .orderedAscending
        }
    }
    
    if minLength < array1.count {
        for i in minLength..<array1.count {
            temp1 = "\(array1[i])"
            if Int(temp1)! > 0 {
                return .orderedDescending
            }
        }
    } else if minLength < array2.count {
        for i in minLength..<array2.count {
            temp2 = "\(array2[i])"
            if Int(temp2)! > 0 {
                return .orderedAscending
            }
        }
    }
    
    return .orderedSame
}
