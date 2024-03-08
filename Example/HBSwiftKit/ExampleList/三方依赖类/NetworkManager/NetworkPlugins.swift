//
//  NetworkPlugins.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/3/28.
//  Copyright © 2020 云图数字. All rights reserved.

import Moya
import SVProgressHUD

// MARK: - 加载配置
/**
 其他加载情况可以使用Moya自带的插件处理, NetworkActivityPlugin
 let networkActivityClosure = { (_ change: NetworkActivityChangeType, _ target: TargetType) in
     switch change {
     case .began:
         print("\(target) =>began")
     case .ended:
         print("\(target) =>ended")
     }
 }
 NetworkActivityPlugin(networkActivityClosure: networkActivityClosure)
 */
/// 加载动画, 结合SVProgressHUD一起使用
public class NetworkLoadingPlugin: PluginType {

    let content: String?
    let hudSize: CGSize
    let bgColor: UIColor?
    let fgColor: UIColor?
    let isEnable: Bool

    /// 初始化加载
    /// - Parameters:
    ///   - content: 文本, 默认 nil
    ///   - hudSize: 尺寸, 默认 100 * 100
    ///   - bgColor: 背景色, 默认.groupTableViewBackground
    ///   - fgColor: 字体色, 默认.black
    ///   - isEnable: 是否允许Hud底下交互, 默认禁用 false
    init(content: String? = nil, hudSize: CGSize = CGSize(width: 100, height: 100), bgColor: UIColor? = nil, fgColor: UIColor? = nil, isEnable: Bool = false) {
        self.content = content
        self.hudSize = hudSize
        self.bgColor = bgColor
        self.fgColor = fgColor
        self.isEnable = isEnable
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
            // hud loading
            SVProgressHUD.show(withStatus: self.content)
            SVProgressHUD.setMinimumSize(self.hudSize)
            // 自定义hud背景色
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setBackgroundColor(self.bgColor ?? .white)
            SVProgressHUD.setForegroundColor(self.fgColor ?? .black)
            // 是否允许hud底下交互
            SVProgressHUD.setDefaultMaskType(self.isEnable ? .none: .clear)
            
            guard #available(iOS 13.0, *) else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                return
            }
        }
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            guard #available(iOS 13.0, *) else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                return
            }
        }
    }
}

// MARK: - 超时配置
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

// MARK: - 日志打印
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


// MARK: - 异常处理
import Alamofire
class NetworkHandlePlugin: PluginType {
   
    let dismiss: Bool
    init(dismiss: Bool = true) {
        self.dismiss = dismiss
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            guard let dict = response.data.dict else {
                // 如果接口请求正常, 移除loading
                if self.dismiss {
                    SVProgressHUD.dismiss()
                }
                return
            }
            // TODO: 其他错误处理
        case let .failure(error):
            switch error {
            case .underlying(let err as AFError, _):
                // 去掉 AFError 的"URLSessionTask failed with error:"前缀提示
                if err.isSessionTaskError {
                    SVProgressHUD.showError(withStatus: err.underlyingError?.localizedDescription ?? "")
                } else {
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
            default:
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
}
