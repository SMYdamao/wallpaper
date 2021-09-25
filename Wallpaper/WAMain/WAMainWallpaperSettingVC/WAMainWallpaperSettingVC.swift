//
//  WAMainWallpaperSettingVC.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/25.
//

import Cocoa
import Kingfisher

class WAMainWallpaperSettingVC: NSViewController {
    
    // MARK: - 壁纸预览
    @IBOutlet weak var previewImage: NSImageView!
    @IBOutlet weak var windowSettingView: NSView!
    @IBOutlet weak var windowRadioCurrent: WABaseButton!
    @IBOutlet weak var windowRadioTotal: WABaseButton!
    
    @IBOutlet weak var wallpaperDownloadView: NSView!
    @IBOutlet weak var wallpaperTitle: NSTextField!
    @IBOutlet weak var wallpaperSize: NSTextField!
    @IBOutlet weak var downloadBtn: WABaseButton!
    @IBOutlet weak var confimSettingBtn: WABaseButton!
    @IBOutlet weak var progresBar: NSProgressIndicator!
    
    var downloadCache: [String:WAMainWallpaperModel] = [:]
    
    private var data: WAMainWallpaperModel?
    
    enum ButtonType: Int {
        case windowChoose = 0
        case download = 1
        case confimSetting = 2
    }
    
    
    private var currentChoosedWindowType: WAWallpaperSettingType = WADataManager.shared.wallpaperSettingType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        initWallpaperSetting()
    }
    
    public func refreshWallpaperPreview(data: WAMainWallpaperModel? = nil) {
        if let model = data, let url = model.thuUrl {
            wallpaperDownloadView.isHidden = false
            self.data = model
            previewImage.kf.setImage(with: URL(string: url))
            wallpaperTitle.stringValue = model.title ?? ""
            wallpaperSize.stringValue = "\(model.width)*\(model.height)    \(model.sizeDesc)"
            updateButtonState()
        } else {
            //            if let url = WADataManager.shared.getDesktopImage() {
            // TODOSMY:  由于APP不能获取APP沙盒以外的资源，因此需 判断桌面壁纸是否是我设置上去的，若是直接展示项目内的图片
            //                previewImage.kf.setImage(with: url, placeholder: NSImage.createImage(with: NSColor.init(0x343535), size: previewImage.size))
            //            }
        }
    }
}

extension WAMainWallpaperSettingVC {
    private  func initWallpaperSetting() {
        
        let bgColor = NSColor.init(0x343535)
        windowSettingView.setBackgroundColor(bgColor)
        wallpaperDownloadView.setBackgroundColor(bgColor)
        downloadBtn.setCornerRadius(4)
        confimSettingBtn.setCornerRadius(4)
        downloadBtn.setBackgroundColor(NSColor.init(0x1269FF))
        confimSettingBtn.setBackgroundColor(NSColor.init(0x1269FF))
        downloadBtn.openClickEvent()
        confimSettingBtn.openClickEvent()
        downloadBtn.click_delegate = self
        confimSettingBtn.click_delegate = self
        downloadBtn.wa_btnType = ButtonType.download.rawValue
        confimSettingBtn.wa_btnType = ButtonType.confimSetting.rawValue
        
        wallpaperDownloadView.isHidden = true
        progresBar.isHidden = true
        
        previewImage.imageScaling = .scaleAxesIndependently
        windowRadioCurrent.wa_Index = WAWallpaperSettingType.current.rawValue
        windowRadioCurrent.openClickEvent()
        windowRadioCurrent.click_delegate = self
        windowRadioCurrent.state = .on
        
        windowRadioCurrent.wa_btnType = ButtonType.windowChoose.rawValue
        windowRadioTotal.wa_btnType = ButtonType.windowChoose.rawValue
        windowRadioTotal.wa_Index = WAWallpaperSettingType.total.rawValue
        windowRadioTotal.openClickEvent()
        windowRadioTotal.click_delegate = self
        
        choosedWindowSetting(type: WADataManager.shared.wallpaperSettingType, saveToLocal: false)
    }
    
    private func choosedWindowSetting(type: WAWallpaperSettingType, saveToLocal: Bool = true) {
        currentChoosedWindowType = type
        switch type {
        case .current:
            windowRadioCurrent.state = .on
            windowRadioTotal.state = .off
        case .total:
            windowRadioCurrent.state = .off
            windowRadioTotal.state = .on
        }
        if saveToLocal {
            WADataManager.shared.wallpaperSettingType = type
        }
    }
    private func updateButtonState() {
        guard let url = data?.oriUrl else {
            return
        }
        if  FileManager.default.fileExists(atPath: ImageCache.default.cachePath(forKey: url)) {
            downloadBtn.setBackgroundColor(NSColor.init(0x1269FF).withAlphaComponent(0.5))
            downloadBtn.setTitle("已下载")
            downloadBtn.isEnabled = false
            confimSettingBtn.isEnabled = true
            confimSettingBtn.setBackgroundColor(NSColor.init(0x1269FF))
        } else {
            downloadBtn.setTitle("下载")
            downloadBtn.setBackgroundColor(NSColor.init(0x1269FF))
            downloadBtn.isEnabled = true
            confimSettingBtn.isEnabled = false
            confimSettingBtn.setBackgroundColor(NSColor.init(0x1269FF).withAlphaComponent(0.5))
        }
        
        if let cacheData = downloadCache[url] {
            progresBar.isHidden = false
            downloadBtn.isHidden = true
            progresBar.doubleValue = cacheData.progresValue
        } else {
            progresBar.doubleValue = 0
            progresBar.isHidden = true
            downloadBtn.isHidden = false
        }
    }
}

extension WAMainWallpaperSettingVC {
    private func windowChoose(button: WABaseButton) {
        guard let type = WAWallpaperSettingType(rawValue: button.wa_Index) else {
            return
        }
        if type == currentChoosedWindowType {
            return
        }
        choosedWindowSetting(type: type)
    }
    
    private func downloadWallpaper() {
        guard let urlStr = data?.oriUrl, let url = URL(string: urlStr) else {
            return
        }
        self.downloadBtn.isHidden = true
        self.progresBar.isHidden = false
        // 缓存
        downloadCache[urlStr] = data
        ImageDownloader.default.downloadImage(with: url, options: nil) { receivedSize, totalSize in
            let progress =  Double(receivedSize/totalSize)
            if urlStr == self.data?.oriUrl {
                self.progresBar.doubleValue = progress
                self.data?.progresValue = progress
                self.downloadBtn.isHidden = true
            } else {
                let cacheData = self.downloadCache[urlStr]
                cacheData?.progresValue = progress
            }
        } completionHandler: { [unowned self] result in
            if let data = try? result.get().originalData {
                // 缓存下来
                ImageCache.default.storeToDisk(data, forKey: urlStr)
            }
            if urlStr == self.data?.oriUrl {
                self.progresBar.doubleValue = 1
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    // 移除
                    self.downloadCache.removeValue(forKey: urlStr)
                   // 刷新状态
                    self.data?.progresValue = 0
                    self.updateButtonState()
                }
            } else {
                // 移除
                let cacheData = self.downloadCache.removeValue(forKey: urlStr)
                cacheData?.progresValue = 0
            }
        }
    }
    
    private func settingWallpaper() {
        var toasStr = ""
        if let url = data?.oriUrl {
            let path =  ImageCache.default.cachePath(forKey: url)
            if FileManager.default.fileExists(atPath: path) {
                WADataManager.shared.setDesktopImage(URL(fileURLWithPath: path))
            } else {
                toasStr = "请先下载"
            }
        } else {
            toasStr = "请先下载"
        }
        
        if toasStr.count > 0 {
            WAHUDManager.show(to: (view.superview?.superview)!, text: toasStr, delay: 0)
        }
    }
}

extension WAMainWallpaperSettingVC: WABaseButtonClickDelegate {
    func wa_buttonClick(button: WABaseButton) {
        guard let type = ButtonType(rawValue: button.wa_btnType) else {
            return
        }
        switch type {
        case .windowChoose:
            windowChoose(button: button)
        case .download:
            downloadWallpaper()
        case .confimSetting:
            settingWallpaper()
        }
    }
}
