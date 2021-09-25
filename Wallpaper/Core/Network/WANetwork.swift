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
    
    private static var downloadTask: DownloadTask?
    
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
}
