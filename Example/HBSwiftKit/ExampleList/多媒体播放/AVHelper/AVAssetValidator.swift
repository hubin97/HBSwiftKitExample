//
//  AVAssetValidator.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation
import AVFoundation

// MARK: - global var and methods
extension AVKeyValueStatus {
    public var description: String {
        switch self {
        case .unknown:
            return "未知状态，尚未开始加载或正在异步加载中"
        case .loading:
            return "正在加载资源的值"
        case .loaded:
            return "资源的值已成功加载"
        case .failed:
            return "资源的值加载失败"
        case .cancelled:
            return "加载请求已被取消"
        @unknown default:
            return "未知错误状态"
        }
    }
}

// MARK: - main class
class AVAssetValidator {
    
    /// 音视频资源有效性校验
    static func validateAudioAsset(_ asset: AVAsset, completion: @escaping (Bool, AVKeyValueStatus) -> Void) {

        let date = Date()
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            let duration = Date().timeIntervalSince(date)
            LogM.debug("音频资源加载校验耗时: \(duration) 秒")
            
            DispatchQueue.main.async {
                var error: NSError?
                let status = asset.statusOfValue(forKey: "playable", error: &error)
                
                if status == .loaded {
                    LogM.debug("音频资源校验通过: \(status)")
                    completion(true, status)
                } else {
                    LogM.error("音频资源校验失败: \(status). 错误: \(status.description)")
                    completion(false, status)
                }
            }
        }
    }
}
