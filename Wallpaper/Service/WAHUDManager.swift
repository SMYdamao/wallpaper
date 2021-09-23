//
//  WAHUDManager.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Cocoa
import LYBProgressHUD

class WAHUDManager: NSObject {
    class func show(to view: NSView) {
        LYBProgressHUD.show(in: view)
    }
    
    class func hide(to view: NSView) {
        LYBProgressHUD.dismiss(in: view)
    }
    
    class func show(to view: NSView, text: String, delay: TimeInterval) {
        LYBProgressHUD.show(in: view, message: text, style: .init(.text, position: .center))
        LYBProgressHUD.dismiss(in: view, after: delay)
    }
}
