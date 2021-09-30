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
    
    lazy var wallpaperServerListVC: WAMainWallpaperListVC = {
        let vc = WAMainWallpaperListVC()
        vc.listType = .service
        middleContentView.addSubview(vc.view)
        vc.view.frame = middleContentView.bounds
        vc.viewDidLoad()
        vc.delegate = self
        return vc
    }()
    
    lazy var wallpaperLocalListVC: WAMainWallpaperListVC = {
        let vc = WAMainWallpaperListVC()
        vc.listType = .local
        middleContentView.addSubview(vc.view)
        vc.view.frame = middleContentView.bounds
        vc.viewDidLoad()
        vc.delegate = self
        return vc
    }()
    
    lazy var wallpaperSettingVC: WAMainWallpaperSettingVC = {
        let vc = WAMainWallpaperSettingVC()
        rightContentView.addSubview(vc.view)
        vc.view.frame = rightContentView.bounds
        vc.viewDidLoad()
        return vc
    }()
    
    
    // MARK: - 菜单
    enum WAMenuType: Int {
        case serverList = 0
        case localList = 1
        case myUpload = 2
        case setting = 3
    }
    /// 菜单列表
    var menuList: [NSView] = []
    /// 当前选择的菜单角标
    var currentMenu: WAMenuType = .serverList {
        didSet {
            wallpaperServerListVC.view.isHidden = true
            wallpaperLocalListVC.view.isHidden = true
            switch currentMenu {
            case .serverList:
                wallpaperServerListVC.view.isHidden = false
                wallpaperSettingVC.view.isHidden = false
                wallpaperSettingVC.refreshWallpaperPreview()
            case .localList:
                wallpaperLocalListVC.view.isHidden = false
                wallpaperLocalListVC.reloadData()
                wallpaperSettingVC.view.isHidden = false
                wallpaperSettingVC.refreshWallpaperPreview()
            case .myUpload:
                wallpaperServerListVC.view.isHidden = false
                wallpaperSettingVC.view.isHidden = true
            case .setting:
                wallpaperLocalListVC.view.isHidden = false
                wallpaperSettingVC.view.isHidden = true
            }
        }
    }
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
        // Do any additional setup after loading the view.
    }
    
    func initContentView() {
        view.setBackgroundColor(NSColor.init(0x282828))
        middleContentView.setBackgroundColor(NSColor.init(0x1A1A1A))
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
