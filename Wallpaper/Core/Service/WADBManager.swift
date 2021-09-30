//
//  WADBManager.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/30.
//

import Foundation
import FMDB

class WADBManager: NSObject {
    static let shared = WADBManager.init()
    
    private lazy var database: FMDatabase? = {
        let path = WAUtils.cachePath() + "/wallpaper.sqlite"
        let db = FMDatabase.init(path: path)
        return db
    }()
    
    var tableName: String {
        get {
            return "Wallpaper"
        }
    }
    
    public func setup() {
        // 创建下载历史表
        if database?.open() ?? false {
            if let isExist = database?.tableExists(tableName), isExist {} else {
                let sql = "CREATE TABLE Wallpaper(wid TEXT PRIMARY KEY, oriUrl TEXT, thuUrl TEXT, title TEXT, size TEXT, bSize TEXT);"
                do {
                    try database?.executeUpdate(sql, values: nil)
                } catch {
                    WALog(error)
                }
                database?.close()
            }
        }
    }
    
    // 添加数据
    public func insert(_ model: WAMainWallpaperModel) {
        if let wid = model.wid, let oriUrl = model.oriUrl, let thuUrl = model.thuUrl, let title = model.title {
            let size = NSStringFromSize(model.size)
            let bSize = model.bSize
            let sql = "INSERT OR IGNORE INTO \(tableName) (wid,oriUrl,thuUrl,title,size,bSize) VALUES ('\(wid)','\(oriUrl)','\(thuUrl)','\(title)','\(size)','\(bSize)');"
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
    
    // 移除数据
    public func remove(_ models: [WAMainWallpaperModel], onceHandler: ((WAMainWallpaperModel)->())?, completionHandler: (()->())?) {
        DispatchQueue.init(label: "removeDownload").async { [unowned self] in
            for model in models {
                if let wid = model.wid {    // 数据库中删除数据
                    let sql = "DELETE FROM \(tableName) WHERE wid = '\(wid)';"
                    if self.database?.open() ?? false {
                        try? self.database?.executeUpdate(sql, values: nil)
                        onceHandler?(model)
                        self.database?.close()
                    }
                }
            }
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }
    
    /// 读取数据
    public func query(wid: String) -> WAMainWallpaperModel? {
        let sql = "SELECT * FROM \(tableName) WHERE wid != '\(wid)' ORDER BY RANDOM() LIMIT 1;"
        if database?.open() ?? false, let result = try? database?.executeQuery(sql, values: nil) {
            var model: WAMainWallpaperModel?
            while result.next() {
                model = WAMainWallpaperModel(result: result)
            }
            database?.close()
            return model
        }
        return nil
    }
    
    /// 读取所有数据
    public func queryAll() -> [WAMainWallpaperModel] {
        let sql = "SELECT * FROM \(tableName);"
        if database?.open() ?? false {
            var arr: [WAMainWallpaperModel] = []
            if let result = try? database?.executeQuery(sql, values: nil) {
                while result.next() {
                    let previousModel = WAMainWallpaperModel(result: result)
                    arr.append(previousModel)
                }
            }
            database?.close()
            return arr
        }
        return []
    }
}
