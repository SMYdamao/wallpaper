//
//  WANetwork.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Foundation
import Alamofire
import Kingfisher

struct WANetwork {
    enum Order: String {
        case latest = "lastest"
        case popular = "popular"
    }
    
    private static var downloadTask: DownloadTask?
    
    // MARK: < API >
    static func gallery(_ page: Int = 1, order: Order = .popular, handler: @escaping (Any?)->()) {
        var urlString = ""
        switch order {
        case .latest:
            urlString = "https://pixabay.com/api/?key=\(WAPixabayAccesskey)&editors_choice=true&page=\(page)&per_page=15&order=latest"
        case .popular:
            urlString = "https://pixabay.com/api/?key=\(WAPixabayAccesskey)&editors_choice=true&page=\(page)&per_page=15&order=popular"
        }
        if let url = URL.init(string: urlString) {
            if let cache = value(for: urlString, page: page), let date = cache["date"] as? Date, let value = cache["value"] {
                if compareDate(date) {  // 超过时长
                    AF.request(url).responseJSON { (resopnse) in
                        if let vue = resopnse.value {
                            save(vue, for: urlString, page: page)
                        }
                        handler(resopnse.value)
                    }
                } else {
                    handler(value)
                }
            } else {    // 没有缓存
                AF.request(url).responseJSON { (resopnse) in
                    if let vue = resopnse.value {
                        save(vue, for: urlString, page: page)
                    }
                    handler(resopnse.value)
                }
            }
        } else {
            handler(nil)
        }
    }
    
    static func search(_ keyword: String, page: Int = 1, color: String? = nil, handler: @escaping (Any?)->()) {
        var urlString: String = ""
        if let c = color {
            urlString = "https://pixabay.com/api/?key=\(WAPixabayAccesskey)&editors_choice=true&page=\(page)&per_page=15&q=\(keyword)&colors=\(c)"
        } else {
            urlString = "https://pixabay.com/api/?key=\(WAPixabayAccesskey)&editors_choice=true&page=\(page)&per_page=15&q=\(keyword)"
        }
        if let url = URL.init(string: urlString) {
            if let cache = value(for: urlString, page: page), let date = cache["date"] as? Date, let value = cache["value"] {
                if compareDate(date) {  // 超过时长
                    AF.request(url).responseJSON { (resopnse) in
                        if let vue = resopnse.value {
                            save(vue, for: urlString, page: page)
                        }
                        handler(resopnse.value)
                    }
                } else {
                    handler(value)
                }
            } else {    // 没有缓存
                AF.request(url).responseJSON { (resopnse) in
                    if let vue = resopnse.value {
                        save(vue, for: urlString, page: page)
                    }
                    handler(resopnse.value)
                }
            }
        } else {
            handler(nil)
        }
    }
    
    static func download(_ urlString: String, progress:( (CGFloat)->())? = nil, completion: @escaping (URL?)->()) {
        if let url = URL.init(string: urlString) {
            let fileName = url.path.md5()
            let filePath = WADataManager.shared.wallpaperPath + "/\(fileName).jpg"
            let fileUrl = URL.init(fileURLWithPath: filePath)
            if FileManager.default.fileExists(atPath: filePath) {   // 文件存在，直接返回
                completion(fileUrl)
            } else {
                self.downloadTask = ImageDownloader.default.downloadImage(with: url, options: .none, progressBlock: { (receivedSize, totalSize) in
                    progress?(CGFloat(receivedSize)/CGFloat(totalSize))
                }) { (result) in
                    let resultData = try? result.get()
                    if let data = resultData?.originalData {
                        do {
                            try data.write(to: fileUrl, options: .atomic)
                            completion(fileUrl)
                        } catch {
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
    
    static func cancelDownload() {
        downloadTask?.cancel()
    }
    
    // MARK: < 拼接默认参数 >
    private static func appendDefaultParameters(_ parameter: [String: Any]) -> [String: Any] {
        var p = parameter
        p["key"] = WAPixabayAccesskey
        p["editors_choice"] = "true"
        p["per_page"] = "15"
        return p
    }
    
    // MARK: < 时间比较 >
    private static func compareDate(_ date: Date) -> Bool {
        let calendar = NSCalendar.current
        let unit: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let components = calendar.dateComponents(unit, from: date, to: Date.init())
        if let day = components.day {
            if day >= 1 {   // 缓存24小时
                return true
            }
        }
        return false
    }
    
    // MARK: < 缓存 >
    private static func save(_ value: Any, for key: String, page: Int) {
        let obj = ["date": Date.init(), "value": value]
        if let k = (key + "page=\(page)").base64() {
            let suffix = "archiver"
            let path = WACacheHelper.savePath(for: k, suffix: suffix)
            let data = try? NSKeyedArchiver.archivedData(withRootObject: obj, requiringSecureCoding: false)
            try? data?.write(to: URL.init(fileURLWithPath: path))
        }
    }
    
    private static func value(for key: String, page: Int) -> [String: Any]? {
        if let k = (key + "page=\(page)").base64() {
            let suffix = "archiver"
            let path = WACacheHelper.savePath(for: k, suffix: suffix)
            if let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) {
                let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
                unarchiver?.requiresSecureCoding = false
                let value = try? unarchiver?.decodeTopLevelObject(forKey: NSKeyedArchiveRootObjectKey) as? [String: Any]
                return value
            } else {
                return nil
            }
        }
        return nil
    }
}
