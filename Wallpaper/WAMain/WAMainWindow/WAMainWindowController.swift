//
//  WAMainWindowController.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/23.
//

import Cocoa

class WAMainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        initWindow()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func initWindow() {
                
        guard let view1 = window?.standardWindowButton(.closeButton)?.superview, let view2 = view1.superview, let view3 = view2.superview else {
            return
        }
        // 切圆角
        let radius: CGFloat = 8
        view1.layer?.cornerRadius = radius
        view2.layer?.cornerRadius = radius
        view3.layer?.cornerRadius = radius
        view1.layer?.masksToBounds = true
        view2.layer?.masksToBounds = true
        view3.layer?.masksToBounds = true
        window?.isOpaque = false
        window?.backgroundColor = .black
    }

}
