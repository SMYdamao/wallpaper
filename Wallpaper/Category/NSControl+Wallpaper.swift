//
//  NSControl+Wallpaper.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import AppKit

extension NSControl {
    func addTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
}
