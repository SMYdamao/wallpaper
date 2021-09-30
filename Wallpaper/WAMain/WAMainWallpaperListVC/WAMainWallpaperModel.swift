//
//  WAMainWallpaperModel.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/24.
//

import Foundation
import FMDB

class WAMainWallpaperModel: NSObject {
    /// id
    var wid: String?
    /// 原图片链接
    var oriUrl: String?
    /// 缩略图链接
    var thuUrl: String?
    /// 标题
    var title: String?
    /// 尺寸
    var size: CGSize = .zero
    /// 大小
    var bSize: Int = 0
    
    
    var bSizeDesc: String {
        get {
            let _mSize = CGFloat(bSize)/(1024*1024)
            return String(format: "%.1fMB", _mSize)
        }
    }
    
    // 下载进度
    var progresValue: Double = 0
    
    override init() {
        super.init()
    }
    
    convenience init(result: FMResultSet) {
        self.init()
        oriUrl = result.string(forColumn: "oriUrl")
        thuUrl = result.string(forColumn: "thuUrl")
        bSize = result.long(forColumn: "bSize")
        title = result.string(forColumn: "title")
        wid = result.string(forColumn: "wid")
        if let sizeStr = result.string(forColumn: "size") {
            size = NSSizeFromString(sizeStr)
        }
    }
}
