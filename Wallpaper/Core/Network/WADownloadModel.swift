//
//  WADownloadModel.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Cocoa

class WADownloadModel: NSObject, NSCoding {
    var fullUrl: String? = nil
    var smallUrl: String? = nil
    var mediumUrl: String? = nil
    var wid : String? = nil
    var user: String? = nil
    
    init(_ gallery: WAGalleryModel? = nil) {
        super.init()
        if let model = gallery {
            fullUrl = model.largeImageURL
            smallUrl = model.previewURL
            mediumUrl = model.webformatURL
            wid = model.id
            user = model.user
        }
    }
    
    required init?(coder: NSCoder) {
        fullUrl = coder.decodeObject(forKey: "fullUrl") as? String
        smallUrl = coder.decodeObject(forKey: "smallUrl") as? String
        mediumUrl = coder.decodeObject(forKey: "mediumUrl") as? String
        wid = coder.decodeObject(forKey: "wid") as? String
        user = coder.decodeObject(forKey: "user") as? String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(fullUrl, forKey: "fullUrl")
        coder.encode(smallUrl, forKey: "smallUrl")
        coder.encode(mediumUrl, forKey: "mediumUrl")
        coder.encode(wid, forKey: "wid")
        coder.encode(user, forKey: "user")
    }
    
}
