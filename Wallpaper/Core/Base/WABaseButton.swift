//
//  WABaseButton.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/24.
//

import Cocoa

protocol WABaseButtonMouseEventDelegate: NSObjectProtocol {
    /// 鼠标进入事件
    func wa_buttonMouseEntered(button: WABaseButton)
    /// 鼠标出来时间
    func wa_buttonMouseExited(button: WABaseButton)
}

protocol WABaseButtonClickDelegate: NSObjectProtocol {
    func wa_buttonClick(button: WABaseButton)
}

class WABaseButton: NSButton {
        
    /// 类型，使用者可随意设置
    public var wa_btnType: Int = 0
    /// 角标，使用者可随意设置
    public var wa_Index: Int = 0
    /// mouse事件代理
    public weak var mouse_delegate: WABaseButtonMouseEventDelegate?
    /// 点击事件代理
    public weak var click_delegate: WABaseButtonClickDelegate?
    
    func openMouseEvent() {
        let options: NSTrackingArea.Options = NSTrackingArea.Options(rawValue: NSTrackingArea.Options.activeInKeyWindow.rawValue|NSTrackingArea.Options.mouseEnteredAndExited.rawValue)
        let mTrackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(mTrackingArea)
    }
    
    func openClickEvent() {
        addTarget(self, action: #selector(clickButton))
    }
    
    @objc private func clickButton() {
        click_delegate?.wa_buttonClick(button: self)
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouse_delegate?.wa_buttonMouseEntered(button: self)
    }
    
    override func mouseExited(with event: NSEvent) {
        mouse_delegate?.wa_buttonMouseExited(button: self)
    }
    
}
