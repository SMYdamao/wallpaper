//
//  Dictionary+Wallpaper.swift
//  Wallpaper
//
//  Created by 生茂元 on 2021/9/22.
//

import Foundation

extension Dictionary {
    func toParameterString() -> String? {
        var params: String = "?"
        for (key,value) in self {
            guard let k = key as? String else {
                return nil
            }
            var v = value as? String
            if v == nil {
                v = "\(value)"
            }
            params.append("\(k)=\(v!)&")
        }
        params.removeLast()
        return params
    }
}
