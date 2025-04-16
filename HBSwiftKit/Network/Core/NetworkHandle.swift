//
//  NetworkHandle.swift
//  Momcozy
//
//  Created by hubin.h on 2024/7/26.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import Moya
import ObjectMapper

/**
 外部实现
 1. 
 /// 全局网络处理
 class NetworkResponseHandler: NetworkHandleProvider {
    func successHandle(dismiss: Bool, response: Response) {}
 }
 
 2.
 /// 扩展插件方法
 extension PTEnum {
     /// 所有插件
     public static func all(content: String? = nil, isEnable: Bool = false, timeout: TimeInterval = 20) -> [PluginType] {
         return [PTEnum.loading(content: content, isEnable: isEnable), PTEnum.timeout(timeout), PTEnum.handle(provider: NetworkResponseHandler()), PTEnum.println()]
     }
     
     /// 排除loading 剩余的所有插件
     public static func noloadings(timeout: TimeInterval = 20) -> [PluginType] {
         return [PTEnum.timeout(timeout), PTEnum.handle(provider: NetworkResponseHandler()), PTEnum.println()]
     }
 }
 */

public protocol NetworkHandleProvider: AnyObject {
    /// 错误码
    // enum ErrorCode
    
    /// 响应成功处理
    func successHandle(dismiss: Bool, response: Response)
}

public enum PTEnum {
    case loading(content: String?, isEnable: Bool)
    case timeout(time: TimeInterval)
    case handle(provider: any NetworkHandleProvider, dismiss: Bool)
    case println

    var plugin: PluginType {
        switch self {
        case .loading(let content, let isEnable):
            return PTEnum.loading(content: content, isEnable: isEnable)
        case .timeout(let time):
            return PTEnum.timeout(time)
        case .handle(let provider, let dismiss):
            return PTEnum.handle(provider: provider, dismiss: dismiss)
        case .println:
            return PTEnum.println()
        }
    }
    
    public static func loading(content: String? = nil, isEnable: Bool = false) -> PluginType {
        return NetworkLoadingPlugin(content: content, isEnable: isEnable)
    }
    
    public static func println() -> PluginType {
        return NetworkPrintlnPlugin()
    }
    
    public static func timeout(_ time: TimeInterval = 20.0) -> PluginType {
        return NetworkTimeoutPlugin(time)
    }
    
    public static func handle(provider: any NetworkHandleProvider, dismiss: Bool = true) -> PluginType {
        return NetworkHandlePlugin(dismiss: dismiss) { response in
            provider.successHandle(dismiss: dismiss, response: response)
        }
    }
//    public static func handle(dismiss: Bool = true) -> PluginType {
//        return NetworkHandlePlugin(dismiss: dismiss) { response in
//            ResponseHandler.successHandle(dismiss: dismiss, response: response)
//        }
//    }
}
