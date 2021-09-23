//
//  WAGalleryModel.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import AppKit
import HandyJSON

struct WAGalleryModel: HandyJSON {
    var id: String = ""
    var pageURL: String = ""
    var type: String = ""
    var tags: String = ""
    var previewURL: String = ""
    var previewWidth: Int = 0
    var previewHeight: Int = 0
    var webformatURL: String = ""
    var webformatWidth: Int = 0
    var webformatHeight: Int = 0
    var largeImageURL: String = ""
    var fullHDURL: String = ""
    var imageURL: String = ""
    var imageWidth: Int = 0
    var imageHeight: Int = 0
    var imageSize: Int = 0
    var views: Int = 0
    var downloads: Int = 0
    var likes: Int = 0
    var comments: Int = 0
    var user_id: String = ""
    var user: String = ""
    var userImageURL: String = ""
    
    var color: NSColor = NSColor.placeholderColor()
    
}
