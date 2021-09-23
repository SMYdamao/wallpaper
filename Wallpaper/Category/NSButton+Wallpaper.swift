//
//  NSButton+Wallpaper.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import AppKit

extension NSButton {
    func setTitle(_ title: String) {
        self.title = title
        bezelStyle = .recessed
        isBordered = false
        image = nil
        setButtonType(.momentaryLight)
    }
    
    func setImage(_ image: NSImage?, state: NSControl.StateValue = .off) {
        self.image = image
        self.state = state
        self.title = ""
        setButtonType(.radio)
    }
    
    func setTitleColor(_ color: NSColor) {
        let att = NSAttributedString.init(string: title, attributes: [NSAttributedString.Key.foregroundColor: color])
        attributedTitle = att
    }
}
