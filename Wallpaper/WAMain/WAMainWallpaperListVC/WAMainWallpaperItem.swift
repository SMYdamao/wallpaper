//
//  WAMainWallpaperItem.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/24.
//

import Cocoa
import Kingfisher

protocol WAMainWallpaperItemDelegate: NSObjectProtocol {
    func wallpaperItem(cell: WAMainWallpaperItem, didClick data: WAMainWallpaperModel)
}

class WAMainWallpaperItem: NSCollectionViewItem {

    @IBOutlet weak var wallpaperImage: NSImageView!
    @IBOutlet weak var shadowView: NSView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    public weak var delegate: WAMainWallpaperItemDelegate?
    
    private var placholder: NSImage?
    private var data: WAMainWallpaperModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        commonInit()
        configEventListener()
    }
    
    private func commonInit() {
        shadowView.setBackgroundColor(NSColor.init(0x000000).withAlphaComponent(0.1))
        shadowView.isHidden = true
        titleLabel.isHidden = true
        wallpaperImage.imageScaling = .scaleAxesIndependently
        placholder = NSImage.createImage(with: NSColor.init(0x343535), size: view.size)
    }
    
    private func configEventListener() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeWhenFirstResponder, .inVisibleRect, .activeInActiveApp]
        let area = NSTrackingArea.init(rect: view.frame, options: options, owner: self, userInfo: nil)
        view.addTrackingArea(area)
        view.becomeFirstResponder()
    }
    
    // 退出区域
    override func mouseExited(with event: NSEvent) {
        titleLabel.isHidden = true
        shadowView.isHidden = true
    }
    
    // 进入区域
    override func mouseEntered(with event: NSEvent) {
        titleLabel.isHidden = false
        shadowView.isHidden = false
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate?.wallpaperItem(cell: self, didClick: data!)
    }
    
    public func setupData(data: WAMainWallpaperModel) {
        self.data = data
        titleLabel.stringValue = data.title ?? ""
        if let url = data.thuUrl {
            wallpaperImage.kf.indicatorType = .activity
            wallpaperImage.kf.setImage(with: URL.init(string: url), placeholder: placholder)
        }
    }
}
