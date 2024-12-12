//
//  Extension+PTEnum.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/12.

import Foundation
import Moya
import ObjectMapper
import ProgressHUD

// MARK: - global var and methods
/// 全局网络处理
class NetworkResponseHandler: NetworkHandleProvider {

    enum ErrorCode: String {
        /// token无效
        case noVaildToken  = "10001002"
        /// 登录过期
        case loginExpire   = "10001003"
        /// 注销验证不通过
        case disableCheck  = "10004309"
    }
    
    /// 响应成功处理
    func successHandle(dismiss: Bool, response: Response) {
        guard let dict = response.data.dict, let baseRsp = Mapper<LTBaseRsp>().map(JSON: dict), let code = baseRsp.code, !baseRsp.isOK else {
            // 如果接口请求正常, 移除loading
            if dismiss {
                ProgressHUD.dismiss()
            }
            return
        }
        switch code {
        case ErrorCode.noVaildToken.rawValue, ErrorCode.loginExpire.rawValue:
            //ProgressHUD.showError(baseRsp.message)
            ProgressHUD.dismiss()
            iToast.makeToast(baseRsp.message ?? "")
            AuthManager.removeUid()
            AuthManager.removeToken()
            //NotificationCenter.default.post(name: Notification.Name.Login, object: nil)
        default:
            //let minDuration = max(Double(baseRsp.message?.count ?? 0) * 0.06 + 0.5, 1)
            //ProgressHUD.error(baseRsp.message, delay: minDuration)
            ProgressHUD.dismiss()
            iToast.makeToast(baseRsp.message ?? "")
            break
        }
    }
}

/// 扩展插件方法
extension PTEnum {

    /// 合并所有插件
    /// - Parameters:
    ///   - content: `loading提示文案`
    ///   - isEnable: 是否允许`hud`底下交互
    ///   - timeout: 超时时间
    ///   - autoDismiss: 处理成功是否直接隐藏hud,
    ///   `注意: 如果需要处理结果的业务, 不建议开启自动隐藏`
    ///
    /// - Returns: 插件集合
    public static func all(content: String? = nil, isEnable: Bool = false, timeout: TimeInterval = 20, autoDismiss: Bool = true) -> [PluginType] {
        return [PTEnum.loading(content: content, isEnable: isEnable), PTEnum.timeout(timeout), PTEnum.handle(provider: NetworkResponseHandler(), dismiss: autoDismiss), PTEnum.println()]
    }
    
    /// 排除loading 剩余的所有插件
    /// - Parameter timeout: 超时时间
    /// - Returns: 插件集合
    public static func noloadings(timeout: TimeInterval = 20) -> [PluginType] {
        return [PTEnum.timeout(timeout), PTEnum.handle(provider: NetworkResponseHandler(), dismiss: false), PTEnum.println()]
    }
}
