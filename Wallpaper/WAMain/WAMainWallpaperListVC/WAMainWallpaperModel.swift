//
//  WAMainWallpaperModel.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/24.
//

import Foundation

class WAMainWallpaperModel {
    /// 原图片链接
    var oriUrl: String?
    /// 缩略图链接
    var thuUrl: String?
    /// 标题
    var title: String?
    /// 宽度
    var width: Int = 0
    /// 高度
    var height: Int = 0
    /// 尺寸
    var size: Int = 0
    
    var sizeDesc: String {
        get {
            let _mSize = CGFloat(size)/(1024*1024)
            return String(format: "%.1fMB", _mSize)
        }
    }
    
    // 下载进度
    var progresValue: Double = 0
    
}
