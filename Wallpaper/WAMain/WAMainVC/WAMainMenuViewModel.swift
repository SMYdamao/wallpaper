//
//  WAMainMenuViewModel.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/25.
//

import Cocoa

extension WAMainVC {
    func initMenuView() {
        menuList.append(wallpaperListMenu)
        menuList.append(myWallpaperMenu)
        menuList.append(myUploadMenu)
        menuList.append(settingMenu)

        for (index, menu) in menuList.enumerated() {
            // 分割线
            let lineView = getMenuLineView(menu: menu)
            lineView.setBackgroundColor(NSColor.init(0x1A1A1A))
            lineView.isHidden = true
            
            // 按钮
            let menuBtn = getMenuButton(menu: menu)
            menuBtn.wa_Index = index
            menuBtn.mouse_delegate = self
            menuBtn.openMouseEvent()
            menuBtn.click_delegate = self
            menuBtn.openClickEvent()
        }
        
        // 设置边框
        categoryView.setBackgroundColor(NSColor.init(0x343535))
        
        // 默认选中第一个菜单
        choosedMenu(menuIdx: 0, ignoreMut: true)
    }
}

// MARK: - 菜单事件
extension WAMainVC {
    func getMenuLineView(menu: NSView) -> NSView {
        return menu.viewWithTag(1)!
    }
    
    func getMenuButton(menu: NSView) -> WABaseButton {
        return menu.viewWithTag(2) as! WABaseButton
    }
    
    func updateMenuState(menu: NSView, state: WAMenuState) {
        let lineView = getMenuLineView(menu: menu)
        switch state {
        case .normal:
            lineView.isHidden = true
            menu.setBackgroundColor(.clear)
        case .highlight:
            lineView.isHidden = true
            menu.setBackgroundColor(NSColor.init(0x343535))
        case .choosed:
            lineView.isHidden = false
            menu.setBackgroundColor(NSColor.init(0x343535))
        }
    }
    
    func choosedMenu(menuIdx: Int, ignoreMut: Bool = false) {
        if !ignoreMut && menuIdx == currentMenuIdx {
            return
        }
        let menu = menuList[menuIdx]
        updateMenuState(menu: menu, state: .choosed)
        if currentMenuIdx >= 0 && currentMenuIdx < menuList.count {
            let prefenu = menuList[currentMenuIdx]
            updateMenuState(menu: prefenu, state: .normal)
        }
        currentMenuIdx = menuIdx
    }
}

extension WAMainVC: WABaseButtonMouseEventDelegate, WABaseButtonClickDelegate {
    func wa_buttonMouseExited(button: WABaseButton) {
        if button.wa_Index == currentMenuIdx {
            return
        }
        let menu = menuList[button.wa_Index]
        updateMenuState(menu: menu, state: .normal)
    }
    
    func wa_buttonMouseEntered(button: WABaseButton) {
        if button.wa_Index == currentMenuIdx {
            return
        }
        let menu = menuList[button.wa_Index]
        updateMenuState(menu: menu, state: .highlight)
    }
    
    func wa_buttonClick(button: WABaseButton) {
        choosedMenu(menuIdx: button.wa_Index)
    }
}
