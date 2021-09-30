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
        choosedMenu(menuType: .serverList, ignoreMut: true)
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
    
    func choosedMenu(menuType: WAMenuType, ignoreMut: Bool = false) {
        if !ignoreMut && menuType == currentMenu {
            return
        }
        // 重置上一个
        if  currentMenu.rawValue < menuList.count {
            let prefenu = menuList[currentMenu.rawValue]
            updateMenuState(menu: prefenu, state: .normal)
        }
        // 设置当前选中
        let menu = menuList[menuType.rawValue]
        updateMenuState(menu: menu, state: .choosed)
        currentMenu = menuType
    }
}

extension WAMainVC: WABaseButtonMouseEventDelegate, WABaseButtonClickDelegate {
    func wa_buttonMouseExited(button: WABaseButton) {
        if button.wa_Index == currentMenu.rawValue {
            return
        }
        let menu = menuList[button.wa_Index]
        updateMenuState(menu: menu, state: .normal)
    }
    
    func wa_buttonMouseEntered(button: WABaseButton) {
        if button.wa_Index == currentMenu.rawValue {
            return
        }
        let menu = menuList[button.wa_Index]
        updateMenuState(menu: menu, state: .highlight)
    }
    
    func wa_buttonClick(button: WABaseButton) {
        guard let type = WAMenuType(rawValue: button.wa_Index) else {
            return
        }
        choosedMenu(menuType: type)
    }
}
