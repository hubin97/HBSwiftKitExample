//
//  AppCore.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2020/5/6.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation
// 全局导入, 若主工程没有混编生成.pch文件, 可以使用此方法
//@_exported import RxSwift

//MARK: - Lay out
/// 屏幕宽高
public let kScreenW = UIScreen.main.bounds.size.width
public let kScreenH = UIScreen.main.bounds.size.height

/// 以iPhone6屏幕为设计底稿的比例换算
public let kScaleW = kScreenW/375.0
public let kScaleH = kScreenH/667.0
public func kScaleW(_ w: CGFloat) -> CGFloat { return kScaleW * w }
public func kScaleH(_ h: CGFloat) -> CGFloat { return kScaleH * h }

/// 默认导航栏高度
public let kNavBarHeight: CGFloat = 44.0
/// 默认标签栏高度
public let kTabBarHeight: CGFloat = 49.0

/// 状态栏高度 iPhone X (44.0) / iPhone 11 (48.0) / 20.0
//public let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height

/// 兼容适配  iOS 13 + 仅开启多任务屏时生效
public let kStatusBarHeight: CGFloat = {
    var statusBarHeight: CGFloat = 0
    if #available(iOS 13.0, *), UIApplication.shared.connectedScenes.count > 0 {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let statusBarManager = windowScene.statusBarManager else { return 0 }
        statusBarHeight = statusBarManager.statusBarFrame.size.height
    } else {
        statusBarHeight = UIApplication.shared.statusBarFrame.size.height
    }
    return statusBarHeight
}()


/// 是否有前刘海  (iPhone X系统 iOS 11+)
public let kIsHaveBangs = kStatusBarHeight > 20.0

/// 顶部安全区域高度
public let kTopSafeHeight: CGFloat = kIsHaveBangs ? kStatusBarHeight : 0

/// 底部安全区域高度
public let kBottomSafeHeight: CGFloat = kIsHaveBangs ? 34: 0.0

/// 状态栏和导航栏总高度
public let kNavBarAndSafeHeight: CGFloat = kStatusBarHeight + kNavBarHeight

/// tabbar和底部安全区域总高度
public let kTabBarAndSafeHeight: CGFloat = kBottomSafeHeight + kTabBarHeight

//MARK: - Info
/// UIDevice
/// systemVersion
public let kSystemVersion = Float(UIDevice.current.systemVersion) ?? 0.0
public let kiOS9Later  = (kSystemVersion >= 9)
public let kiOS10Later = (kSystemVersion >= 10)
public let kiOS11Later = (kSystemVersion >= 11)
public let kiOS12Later = (kSystemVersion >= 12)
public let kiOS13Later = (kSystemVersion >= 13)
public let kiOS14Later = (kSystemVersion >= 14)

/// uuidString
public let kUUIDString = UIDevice.current.identifierForVendor?.uuidString

/// info.plist
public let kInfoPlist = Bundle.main.infoDictionary ?? Dictionary()
/// 版本号（内部标示）
public let kAppVersion = kInfoPlist["CFBundleShortVersionString"] as? String
/// Build号
public let kAppBuildVersion = kInfoPlist["CFBundleVersion"] as? String

/// 获取主窗口
public let kAppKeyWindow: UIWindow? = {
    if #available(iOS 13, *) {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    } else {
        return UIApplication.shared.keyWindow
    }
}()

/// Top of stack Vc
public func stackTopViewController(_ vc: UIViewController? = nil) -> UIViewController? {
    //注意UIApplication.shared.keyWindow?.rootViewController有时为nil 比如当页面有菊花在转的时候，这个rootViewController就为nil
    //guard let tmpRootVc = kAppKeyWindow?.rootViewController else { return nil }
    var rootVc = vc ?? kAppKeyWindow?.rootViewController
   
    /// 模态遍历
    while rootVc?.presentedViewController != nil {
        rootVc = rootVc?.presentedViewController
    }
    
    var currentVc: UIViewController?
    //presentedViewController 和presentingViewController
    //当A弹出B //A.presentedViewController=B //B.presentingViewController=A
    if rootVc?.presentedViewController != nil {
        currentVc = stackTopViewController(rootVc?.presentedViewController)
    } else if (rootVc?.isKind(of: UITabBarController.self) == true) {
        currentVc = stackTopViewController((rootVc as! UITabBarController).selectedViewController)
    } else if (rootVc?.isKind(of: UINavigationController.self) == true) {
        currentVc = stackTopViewController((rootVc as! UINavigationController).visibleViewController)
    } else {
        currentVc = rootVc
    }
    return currentVc
}

/// 根据字符串获取工程中的对应Swift类
/// \\ 使用 swiftClassFromString("xxx") as? UIViewController.Type
///
/// - Parameter aClassName: 类名字符串
/// - Returns: 类
public func swiftClassFromString(_ aClassName: String) -> AnyClass? {
    // 获取工程名
    guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else { return nil }
    // 过滤无效字符 空格不转换的话 得不到准确类名
    let formattedAppName = appName.replacingOccurrences(of: " ", with: "_")
    // 拼接控制器名
    let classStringName = "\(formattedAppName).\(aClassName)"
    // 将控制名转换为类
    return NSClassFromString(classStringName)
}

/// 自定义Log打印
/// - Parameters:
///   - items: 输出文本
///   - filePath: 文件名
///   - method: 方法
///   - line: 所在行数
public func printLog(_ items: Any, filePath: String = #filePath, method: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(URL(fileURLWithPath: filePath).lastPathComponent)[line:\(line),method:\(method)]: \(items)")
    #endif
}

//
//public let getIpAddress:(() -> String? ) = { () -> String? in
//
//    var addresses = [String]()
//    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
//    if getifaddrs(&ifaddr) == 0 {
//        var ptr = ifaddr
//        while (ptr != nil) {
//            let flags = Int32(ptr!.pointee.ifa_flags)
//            var addr = ptr!.pointee.ifa_addr.pointee
//            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
//                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
//                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
//                        if let address = String(validatingUTF8:hostname) {
//                            addresses.append(address)
//                        }
//                    }
//                }
//            }
//            ptr = ptr!.pointee.ifa_next
//        }
//        freeifaddrs(ifaddr)
//    }
//    return addresses.first ?? "0.0.0.0"
//}

