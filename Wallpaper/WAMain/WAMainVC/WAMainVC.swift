//
//  WAMainVC.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Cocoa

class WAMainVC: NSViewController {
    
    @IBOutlet weak var leftContentView: NSView!
    @IBOutlet weak var middleContentView: NSView!
    @IBOutlet weak var rightContentView: NSView!
    @IBOutlet weak var wallpaperListMenu: NSView!
    @IBOutlet weak var myWallpaperMenu: NSView!
    @IBOutlet weak var myUploadMenu: NSView!
    @IBOutlet weak var settingMenu: NSView!
    @IBOutlet weak var categoryView: NSView!
    
    lazy var wallpaperListVC: WAMainWallpaperListVC = { WAMainWallpaperListVC() }()
    lazy var wallpaperSettingVC: WAMainWallpaperSettingVC = { WAMainWallpaperSettingVC() }()
    
    
    // MARK: - 菜单
    /// 菜单列表
    var menuList: [NSView] = []
    /// 当前选择的菜单角标
    var currentMenuIdx: Int = -1
    /// 菜单状态
    enum WAMenuState {
        case normal
        case highlight
        case choosed
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initContentView()
        initMenuView()
        initWallpaperView()
        initWallpaperSetting()
        // Do any additional setup after loading the view.
    }
    
    func initContentView() {
        view.setBackgroundColor(NSColor.init(0x282828))
        middleContentView.setBackgroundColor(NSColor.init(0x1A1A1A))
    }
    
    func initWallpaperView() {
        middleContentView.addSubview(wallpaperListVC.view)
        wallpaperListVC.view.frame = middleContentView.bounds
        wallpaperListVC.viewDidLoad()
        wallpaperListVC.delegate = self
    }
    
    func initWallpaperSetting() {
        rightContentView.addSubview(wallpaperSettingVC.view)
        wallpaperSettingVC.view.frame = rightContentView.bounds
        wallpaperSettingVC.viewDidLoad()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension WAMainVC: WAMainWallpaperListDelegate {
    func wallpaperList(vc: WAMainWallpaperListVC, didSelect item: WAMainWallpaperModel) {
        wallpaperSettingVC.refreshWallpaperPreview(data: item)
    }
}
