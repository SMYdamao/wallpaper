//
//  WADataManager.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Cocoa
import Carbon
import ServiceManagement
import UserNotifications
import MASShortcut
import FMDB
import ScreenSaver
import Kingfisher

enum WAImageQualityType: Int {
    case small = 0  // 低
    case medium = 1 // 中
    case large = 2  // 高
}

enum WAAutoChnageWallperType: Int {
    case off = 0    // 关闭
    case fiteen = 1 // 十五分钟
    case thirty = 2 // 三十分钟
    case fortyFive = 3  // 四十五分钟
    case hour = 4   // 1小时
    case twoHour = 5    // 2小时
    case day = 6    // 1天
}

enum WAWallpaperPlatform: Int {
    case unsplash
    case pexels
    case pixabay
}

/// 壁纸设置模式
public enum WAWallpaperSettingType: Int {
    /// 当前屏幕
    case current = 0
    /// 所有屏幕
    case total = 1
}

class WADataManager: NSObject {
    static let shared = WADataManager.init()
    
    private struct WADataKey {
        let rawValue: String
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let startUp = WADataKey.init("startUp")
        static let unite = WADataKey.init("unite")
        static let notification = WADataKey.init("notification")
        static let wallpaperPath = WADataKey.init("wallpaperPath")
        static let imageQuality = WADataKey.init("imageQuality")
        static let wallpaperType = WADataKey.init("wallpaperType")
        static let previous = WADataKey.init("previous")
        static let next = WADataKey.init("next")
        static let version = WADataKey.init("version")
        static let wallpaperSettingType = WADataKey.init("wallpaperSettingType")
    }
    
    enum HotKeyType {
        case previous
        case next
    }

    private var timer: Timer?
    private var db: WADBManager = .shared
    
    
    override init() {
        super.init()
        db.setup()
    }
    
    // MARK: < App info >
    var appName: String? {
        get {
            return info?["CFBundleDisplayName"] as? String
        }
    }
    
    var appVersion: String? {
        get {
            return info?["CFBundleShortVersionString"] as? String
        }
    }
    
    var copyright: String? {
        get {
            return info?["NSHumanReadableCopyright"] as? String
        }
    }
    
    var info: [String: Any]? {
        get {
            return Bundle.main.infoDictionary
        }
    }
    
    var currentWallpaper: WAMainWallpaperModel? {    // 当前的壁纸
        get {
            if let data = UserDefaults.standard.object(forKey: "wa.currentWallpaper") as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                return try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? WAMainWallpaperModel
            }
            return nil
        }
        set {
            if let model = newValue {
                let data = try? NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "wa.currentWallpaper")
            }
        }
    }
    
    private var previousWallpaperModel: WAMainWallpaperModel? // 上一张
    
    // MARK: < Cofig info >
    var isStartUp: Bool {   // 开启自启
        get {
            let value = UserDefaults.standard.bool(forKey: WADataKey.startUp.rawValue)
            return value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: WADataKey.startUp.rawValue)
            configAppStartUp(newValue)
        }
    }
    
    var isUnite: Bool { // 多屏统一
        get {
            if UserDefaults.standard.object(forKey: WADataKey.unite.rawValue) != nil {
                return UserDefaults.standard.bool(forKey: WADataKey.unite.rawValue)
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: WADataKey.unite.rawValue)
        }
    }
    
    var isNotification: Bool {  // 更换通知
        get {
            if UserDefaults.standard.object(forKey: WADataKey.notification.rawValue) != nil {
                return UserDefaults.standard.bool(forKey: WADataKey.notification.rawValue)
            }
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: WADataKey.notification.rawValue)
        }
    }
    
    var wallpaperSettingType: WAWallpaperSettingType {
        get {
            if UserDefaults.standard.object(forKey: WADataKey.wallpaperSettingType.rawValue) != nil {
                let value = UserDefaults.standard.integer(forKey: WADataKey.wallpaperSettingType.rawValue)
                return WAWallpaperSettingType(rawValue: value) ?? .current
            }
            return .current
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: WADataKey.wallpaperSettingType.rawValue)
        }
    }
    
    var wallpaperPath: String { // 存储路径
        get {
            if let path = UserDefaults.standard.string(forKey: WADataKey.wallpaperPath.rawValue) {
                return path
            } else {
                var defaultPath: String = ""
                if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                    defaultPath = path + "/Wallpaper/Wallpaper"
                } else {
                    defaultPath = NSHomeDirectory() + "/Documents/Wallpaper/Wallpaper"
                }
                if !FileManager.default.fileExists(atPath: defaultPath) {
                    do {
                        try FileManager.default.createDirectory(atPath: defaultPath, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        WALog("\(error)")
                    }
                }
                return defaultPath
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: WADataKey.wallpaperPath.rawValue)
        }
    }
    
    var imageQuality: WAImageQualityType {  // 图片预览质量
        get {
            if UserDefaults.standard.object(forKey: WADataKey.imageQuality.rawValue) != nil {
                let rawValue = UserDefaults.standard.integer(forKey: WADataKey.imageQuality.rawValue)
                return WAImageQualityType.init(rawValue: rawValue) ?? .medium
            } else {
                return .medium
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: WADataKey.imageQuality.rawValue)
        }
    }
    
    var autoChangeWallpaperType: WAAutoChnageWallperType {  // 自动切换
        get {
            if UserDefaults.standard.object(forKey: WADataKey.wallpaperType.rawValue) != nil {
                let rawValue = UserDefaults.standard.integer(forKey: WADataKey.wallpaperType.rawValue)
                return WAAutoChnageWallperType.init(rawValue: rawValue) ?? .off
            } else {
                return .off
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: WADataKey.wallpaperType.rawValue)
            startAutoChangeWallpaper()
        }
    }
    
    var previousShortcut: MASShortcut? { // 上一张快捷键
        get {
            if let data = UserDefaults.standard.object(forKey: WADataKey.previous.rawValue) as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                let value = try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? MASShortcut
                return value
            }
            let modifier: NSEvent.ModifierFlags = [.command, .option]
            return MASShortcut.init(keyCode: kVK_LeftArrow, modifierFlags: modifier)
        }
    }
    
    var nextShortcut: MASShortcut? { // 下一张快捷键
        get {
            if let data = UserDefaults.standard.object(forKey: WADataKey.next.rawValue) as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                let value = try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? MASShortcut
                return value
            }
            let modifier: NSEvent.ModifierFlags = [.command, .option]
            return MASShortcut.init(keyCode: kVK_RightArrow, modifierFlags: modifier)
        }
    }
    
    // MARK: < Public function >
    
    /// 设置壁纸 - 传入模型，设置后会自动存入本地数据库
    func setDesctopImage(data: WAMainWallpaperModel) {
        guard let url = data.oriUrl else {
            return
        }
        WANetwork.download(url, progress: nil) { [unowned self] (filePath) in
            if let path = filePath {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {[unowned self] in
                    // 存储到数据库
                    self.append(data)
                    // 设置壁纸
                    self.setDesktopImage(URL(fileURLWithPath: path))
                }
            }
        }
    }
    
    /// 设置壁纸 - 传入url
    func setDesktopImage(_ url: URL) {
        var result: Bool = true
        switch wallpaperSettingType {
        case .current:
            if let screen = NSScreen.main {
                do {
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [NSWorkspace.DesktopImageOptionKey.imageScaling: NSImageScaling.scaleAxesIndependently.rawValue])
                } catch {
                    result = false
                }
            } else {
                result = false
            }
        case .total:
            for screen in NSScreen.screens {
                do {
                    try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [NSWorkspace.DesktopImageOptionKey.imageScaling: NSImageScaling.scaleAxesIndependently.rawValue])
                } catch {
                    result = false
                }
            }
        }
       
        if isNotification {
            let title = result ? NSLocalizedString("WAChangeWallpaperSuccess", comment: "壁纸切换成功") : NSLocalizedString("WAChangeWallpaperError", comment: "壁纸切换失败")
            postNotification(with: title)
        }
    }
    
    // 获取壁纸
    func getDesktopImage() -> URL? {
        guard let screen = NSScreen.main else {
            return nil
        }
        let desktopImageUrl = NSWorkspace.shared.desktopImageURL(for: screen)
        return desktopImageUrl
    }
    
    // 配置快捷键
    func configHotKey() {
        MASShortcutMonitor.shared()?.register(previousShortcut, withAction: { [unowned self] in
            self.previousWallpaper()
        })
        MASShortcutMonitor.shared()?.register(nextShortcut, withAction: { [unowned self] in
            self.nextWallpaper()
        })
    }
    
    // 设置快捷键
    func setHotKey(_ keycode: Int, modifier: NSEvent.ModifierFlags, type: HotKeyType) {
        var key: String!
        if type == .previous {
            key = WADataKey.previous.rawValue
        } else {
            key = WADataKey.next.rawValue
        }
        if let shortcut = MASShortcut.init(keyCode: keycode, modifierFlags: modifier) {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: shortcut, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // 开始更换壁纸
    func startAutoChangeWallpaper() {
        let second = autoChangeWallpaperTypeToSecond(autoChangeWallpaperType)
        if second > 0 {
            timer = Timer.scheduledTimer(timeInterval: second, target: self, selector: #selector(timerDidAction), userInfo: nil, repeats: true)
            timer?.fire()
            RunLoop.current.add(timer!, forMode: .common)
        } else {
            stopAutoChangeWallpaper()
        }
    }
    
    // 停止自动更换壁纸
    func stopAutoChangeWallpaper() {
        timer?.invalidate()
        timer = nil
    }
    
    // 添加数据
    func append(_ model: WAMainWallpaperModel) {
        db.insert(model)
    }
    
    // 移除数据
    func remove(_ models: [WAMainWallpaperModel], handler: (()->())?) {
        db.remove(models) { model in
            if let urlString = model.oriUrl {    // 本地存在文件删除
                ImageCache.default.removeImage(forKey: urlString)
            }
        } completionHandler: {
            handler?()
        }
    }
    
    // 下一张
    func nextWallpaper() {
        if getDownloads().count <= 1 {
            return
        }
        if let wid = currentWallpaper?.wid {
            // 存储上一张
            previousWallpaperModel = currentWallpaper
            // 设置下一张
            if let model = db.query(wid: wid) {
                currentWallpaper = model
                if let url = model.oriUrl {
                    WANetwork.download(url, progress: nil) { [unowned self] (filePath) in
                        if let path = filePath {
                            DispatchQueue.main.async { [unowned self] in
                                self.setDesktopImage(URL(fileURLWithPath: path))
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 上一张
    func previousWallpaper() {
        if let url = previousWallpaperModel?.oriUrl {
            WANetwork.download(url, progress: nil) { [unowned self] (filePath) in
                if let path = filePath {
                    let temp = self.previousWallpaperModel
                    self.previousWallpaperModel = self.currentWallpaper
                    self.currentWallpaper = temp
                    self.setDesktopImage(URL(fileURLWithPath: path))
                }
            }
        }
    }
    
    // 下载历史
    func getDownloads() -> [WAMainWallpaperModel] {
        return db.queryAll()
    }
    
    // 路径移动
    func wallpaperMove(_ path: String, toPath: String) {
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
            // 移动壁纸到新目录
            for item in contents {
                let fileName = (item as NSString).lastPathComponent
                let path = toPath + "/" + fileName
                do {
                    // 移动文件
                    try FileManager.default.copyItem(atPath: item, toPath: path)
                } catch {
                    WALog(error)
                }
            }
            
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    // 清除网络缓存
    func clearNetworkCache() {
        WACacheHelper.clearCache()
    }
    
    // MARK: < Private function >
    private func postNotification(with message: String) {
        // 请求权限
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if granted {
                print("授权成功")
            }
        }
        
        // 发送通知
        let content = UNMutableNotificationContent.init()
        content.title = message
        content.sound = UNNotificationSound.default
        let categoryId = "com.damao.wallpaper.category"
        content.categoryIdentifier = categoryId
        let category = UNNotificationCategory.init(identifier: categoryId, actions: [], intentIdentifiers: [], options: .customDismissAction)
        let request = UNNotificationRequest.init(identifier: "com.damao.wallpaper.notification", content: content, trigger: nil)
        
        center.setNotificationCategories([category])
        center.add(request, withCompletionHandler: nil)
    }
    
    private func configAppStartUp(_ isStartUp: Bool) {
        let helperAppIdentifier = "com.damao.wallpaperHelper"
        let success = SMLoginItemSetEnabled(helperAppIdentifier as CFString, isStartUp)
        if success {
            WALog(isStartUp ? "添加登录项成功" : "移除登录项成功")
        } else {
            WALog("配置登录项失败")
        }
    }
    
    private func autoChangeWallpaperTypeToSecond(_ type: WAAutoChnageWallperType) -> TimeInterval {
        var second: TimeInterval = 0;
        switch type {
        case .fiteen:
            second = 15 * 60
        case .thirty:
            second = 30 * 60
        case .fortyFive:
            second = 45 * 60
        case .hour:
            second = 60 * 60
        case .twoHour:
            second = 120 * 60
        case .day:
            second = 24 * 60 * 60
        default:
            break
        }
        return second
    }
    
    @objc private func timerDidAction() {
        nextWallpaper()
    }
}

extension WADataManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
