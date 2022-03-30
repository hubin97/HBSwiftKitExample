//
//  NetworkRequest.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/3/28.
//  Copyright © 2020 云图数字. All rights reserved.

// Moya文档 https://github.com/Moya/Moya/tree/master/docs/Examples
// Moya解析 https://dirtmelon.github.io/posts/Moya/

import Moya
import ObjectMapper
import PromiseKit

/// 自定义网络错误
public enum NetworkError: Error {
    /// 解析映射出错
    case objectMapperError(mapType: Any)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .objectMapperError(let mapType):
            return "Failed to map data to \(type(of: mapType))."
        }
    }
}

/// 如果返回的数据并不能直接映射, 使用插件预处理
/// func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError>

/// 获取JSONString
/// - Returns: Promise<String>
public func fetchJSONString<T: TargetType>(targetType: T.Type, target: T, plugins: [PluginType]) -> Promise<String> {
    return Promise<String>.init { resolver in
        MoyaProvider(plugins: plugins).request(target, completion: { result in
            switch result {
            case let .success(response):
                guard let string = response.data.string else {
                    resolver.reject(NetworkError.objectMapperError(mapType: ""))
                    return
                }
                resolver.fulfill(string)
            case let .failure(error):
                resolver.reject(error)
            }
        })
    }
}

/// 获取指定模型
/// - Returns: Promise<M>
public func fetchTargetMeta<T: TargetType, M: Mappable>(targetType: T.Type, target: T, metaType: M.Type, plugins: [PluginType]) -> Promise<M> {
    return Promise<M>.init { resolver in
        fetchJSONString(targetType: targetType, target: target, plugins: plugins).done { result in
            guard let meta = Mapper<M>().map(JSONString: result) else {
                resolver.reject(NetworkError.objectMapperError(mapType: metaType.self))
                return
            }
            resolver.fulfill(meta)
        }.catch { error in
            resolver.reject(error)
        }
    }
}

/// 获取指定模型数组
/// - Returns: Promise<[M]>
public func fetchTargetList<T: TargetType, M: Mappable>(targetType: T.Type, target: T, metaType: M.Type, plugins: [PluginType]) -> Promise<[M]> {
    return Promise<[M]>.init { resolver in
        fetchJSONString(targetType: targetType, target: target, plugins: plugins).done { result in
            guard let list = Mapper<M>().mapArray(JSONString: result) else {
                resolver.reject(NetworkError.objectMapperError(mapType: [metaType.self]))
                return
            }
            resolver.fulfill(list)
        }.catch { error in
            resolver.reject(error)
        }
    }
}
