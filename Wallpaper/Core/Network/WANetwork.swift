//
//  WANetwork.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Foundation
import Kingfisher

struct WANetwork {
    
    private static var downloadTask: DownloadTask?
    
    static func download(_ urlString: String, progress:( (Double)->())? = nil, completion: @escaping (String?)->()) {
        if let url = URL.init(string: urlString) {
            let filePath = ImageCache.default.cachePath(forKey: urlString)
            if FileManager.default.fileExists(atPath: filePath) {   // 文件存在，直接返回
                completion(filePath)
            } else {
                self.downloadTask = ImageDownloader.default.downloadImage(with: url, options: .none, progressBlock: { (receivedSize, totalSize) in
                    progress?(Double(receivedSize)/Double(totalSize))
                }) { (result) in
                    let resultData = try? result.get()
                    if let data = resultData?.originalData {
                        ImageCache.default.storeToDisk(data, forKey: urlString)
                        completion(filePath)
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
}
