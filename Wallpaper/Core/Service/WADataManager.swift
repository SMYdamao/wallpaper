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

    var timer: Timer?
    
    private lazy var database: FMDatabase? = {
        let path = cachePath + "/Wallpaper.sqlite"
        let db = FMDatabase.init(path: path)
        return db
    }()
    
    override init() {
        super.init()
        // 修复v1.0版本Bug，下载历史重复添加问题
        if let version = appVersion {
            switch compareVersion(version, "1.0") {
            case .orderedDescending:
                if UserDefaults.standard.object(forKey: WADataKey.version.rawValue) == nil, let _ = try? FileManager.default.removeItem(atPath: cachePath + "/Wallpaper.sqlite") {
                    UserDefaults.standard.setValue("version", forKey: WADataKey.version.rawValue)
                }
            default:
                break
            }
        }
        // 创建下载历史表
        if database?.open() ?? false {
            if let isExist = database?.tableExists("WADownload"), isExist {} else {
                let sql = "CREATE TABLE WADownload(wid TEXT PRIMARY KEY, fullUrl TEXT, mediumUrl TEXT, smallUrl TEXT,user TEXT);"
                do {
                    try database?.executeUpdate(sql, values: nil)
                } catch {
                    WALog(error)
                }
                database?.close()
            }
        }
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
    
    var cachePath: String {
        get {
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        }
    }
    
    var currentWallpaper: WADownloadModel? {    // 当前的壁纸
        get {
            if let data = UserDefaults.standard.object(forKey: "wa.currentWallpaper") as? Data {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                return try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? WADownloadModel
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
    
    private var previousWallpaperModel: WADownloadModel? // 上一张
    
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
    // 设置壁纸
    func setDesktopImage(_ url: URL, model: Any? = nil) {
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
            var m: WADownloadModel?
            if model is WAGalleryModel {
                m = WADownloadModel.init(model as? WAGalleryModel)
            } else if model is WADownloadModel {
                m = model as? WADownloadModel
            }
            postNotification(with: title, model: m)
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
    
    // 添加历史
    func append(_ model: WADownloadModel) {
        if let fullUrl = model.fullUrl, let smallUrl = model.smallUrl, let mediumUrl = model.mediumUrl, let wid = model.wid, let user = model.user {
            let sql = "INSERT OR IGNORE INTO WADownload (wid,fullUrl,mediumUrl,smallUrl,user) VALUES ('\(wid)','\(fullUrl)','\(mediumUrl)','\(smallUrl)','\(user)');"
            if database?.open() ?? false {
                do {
                    try database?.executeUpdate(sql, values: nil)
                } catch {
                    WALog(error)
                }
                database?.close()
            }
        }
    }
    
    // 移出历史
    func remove(_ models: [WADownloadModel], handler: (()->())?) {
        DispatchQueue.init(label: "removeDownload").async { [unowned self] in
            for model in models {
                if let wid = model.wid {    // 数据库中删除数据
                    let sql = "DELETE FROM WADownload WHERE wid = '\(wid)';"
                    if self.database?.open() ?? false {
                        try? self.database?.executeUpdate(sql, values: nil)
                        self.database?.close()
                    }
                }
                if let urlString = model.fullUrl, let url = URL.init(string: urlString) {    // 本地存在文件删除
                    let fileName = url.path.md5()
                    let filePath = WADataManager.shared.wallpaperPath + "/\(fileName).jpg"
                    if FileManager.default.fileExists(atPath: filePath) {
                        try? FileManager.default.removeItem(atPath: filePath)
                    }
                }
            }
            DispatchQueue.main.async {
                handler?()
            }
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
            let sql = "SELECT * FROM WADownload WHERE wid != '\(wid)' ORDER BY RANDOM() LIMIT 1;"
            if database?.open() ?? false, let result = try? database?.executeQuery(sql, values: nil) {
                var download: WADownloadModel?
                while result.next() {
                    download = WADownloadModel.init()
                    download?.fullUrl = result.string(forColumn: "fullUrl")
                    download?.smallUrl = result.string(forColumn: "smallUrl")
                    download?.mediumUrl = result.string(forColumn: "mediumUrl")
                    download?.wid = result.string(forColumn: "wid")
                    download?.user = result.string(forColumn: "user")
                }
                database?.close()
                currentWallpaper = download
                if let url = download?.fullUrl {
                    WANetwork.download(url, progress: nil) { [unowned self] (fileUrl) in
                        if let file = fileUrl {
                            DispatchQueue.main.async { [unowned self] in
                                self.setDesktopImage(file, model: download)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 上一张
    func previousWallpaper() {
        if let url = previousWallpaperModel?.fullUrl {
            WANetwork.download(url, progress: nil) { [unowned self] (fileUrl) in
                if let file = fileUrl {
                    let temp = self.previousWallpaperModel
                    self.previousWallpaperModel = self.currentWallpaper
                    self.currentWallpaper = temp
                    self.setDesktopImage(file, model: self.previousWallpaperModel)
                }
            }
        }
    }
    
    // 下载历史
    func getDownloads() -> [WADownloadModel] {
        let sql = "SELECT * FROM WADownload;"
        if database?.open() ?? false {
            var arr: [WADownloadModel] = []
            if let result = try? database?.executeQuery(sql, values: nil) {
                while result.next() {
                    let previousModel = WADownloadModel.init()
                    previousModel.fullUrl = result.string(forColumn: "fullUrl")
                    previousModel.smallUrl = result.string(forColumn: "smallUrl")
                    previousModel.mediumUrl = result.string(forColumn: "mediumUrl")
                    previousModel.wid = result.string(forColumn: "wid")
                    previousModel.user = result.string(forColumn: "user")
                    arr.append(previousModel)
                }
            }
            database?.close()
            return arr
        }
        return []
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
    private func postNotification(with message: String, model: WADownloadModel?) {
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
        if let user = model?.user {
            content.body =  "Pixabay-\(user)"
        }
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
