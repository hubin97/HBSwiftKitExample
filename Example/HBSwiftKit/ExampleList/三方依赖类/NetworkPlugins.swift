//
//  NetworkPlugins.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/3/28.
//  Copyright © 2020 云图数字. All rights reserved.

import Moya

/// 补充加载动画, 结合iToast一起使用
public class NetworkLoadingPlugin: PluginType {

    public func willSend(_ request: RequestType, target: TargetType) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

/// 默认 20s超时
public class NetworkTimeoutPlugin: PluginType {

    let timeout: TimeInterval
    public init(_ timeout: TimeInterval = 20) {
        self.timeout = timeout
    }
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var req = request
        req.timeoutInterval = timeout
        return req
    }
}

import CocoaLumberjack
/// 日志格式输出 Moya NetworkLoggerPlugin 改
public class NetworkPrintlnPlugin: PluginType {

    /// 是否打印日志详情
    #if DEBUG
    public static var showLoggers = true
    #else
    public static var showLoggers = false
    #endif
    /// 是否打印response.description
    public static var showRspDesc = false

    fileprivate let loggerId = "Moya_Logger"
    fileprivate let dateFormatString = "dd/MM/yyyy HH:mm:ss"
    fileprivate let dateFormatter = DateFormatter()
    var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = Locale(identifier: "zh_CN")
        return dateFormatter.string(from: Date())
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        let req_content = logNetworkRequest(request.request as URLRequest?)
        if NetworkPrintlnPlugin.showLoggers {
            DDLogInfo("Request 🚀🚀🚀")
            req_content.forEach({ DDLogInfo("\($0)") })
        }
    }

    /// Result库缺少导入, didReceive不执行
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        var rsp_content = [String]()
        if case .success(let response) = result {
            rsp_content = logNetworkResponse(response.response, data: response.data, target: target)
        } else {
            rsp_content = logNetworkResponse(nil, data: nil, target: target)
        }
        if NetworkPrintlnPlugin.showLoggers {
            DDLogInfo("Response ✨✨✨")
            DDLogInfo("PATH: \(target.path)")
            rsp_content.forEach({ DDLogInfo("\($0)") })
        }
    }

    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        var output = [String]()
        output += [format(loggerId, date: date, identifier: "Request", message: request?.description ?? "(invalid request)")]
        if let headers = request?.allHTTPHeaderFields {
            output += [format(loggerId, date: date, identifier: "Request Headers", message: headers.description)]
        }
        if let bodyStream = request?.httpBodyStream {
            output += [format(loggerId, date: date, identifier: "Request Body Stream", message: bodyStream.description)]
        }
        if let httpMethod = request?.httpMethod {
            output += [format(loggerId, date: date, identifier: "HTTP Request Method", message: httpMethod)]
        }
        if let body = request?.httpBody, let stringOutput = String(data: body, encoding: .utf8) {
            output += [format(loggerId, date: date, identifier: "Request Body", message: stringOutput)]
        }
        return output
    }

    func logNetworkResponse(_ response: HTTPURLResponse?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
           return [format(loggerId, date: date, identifier: "Response", message: "Received empty network response for \(target).")]
        }
        var output = [String]()
        if NetworkPrintlnPlugin.showRspDesc {
            output += [format(loggerId, date: date, identifier: "Response", message: response.description)]
        }
        if let data = data, let stringData = String(data: data, encoding: String.Encoding.utf8) {
            output += [format(loggerId, date: date, identifier: "Response Data", message: stringData)]
        }
        return output
    }

    func format(_ loggerId: String, date: String, identifier: String, message: String) -> String {
        return "\(loggerId): \(identifier): \(message)"
    }
}
