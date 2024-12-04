//
//  Application.swift
//  Petcozy
//
//  Created by hubin.h on 2024/5/23.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import HBSwiftKit

// MARK: - main class
final class Application: NSObject {
    
    static let shared = Application()
    
    var window: UIWindow?
    
    /// 埋点会话Id
    let sessionId = UUID().uuidString
    /// 路由
    let navigator: Navigator
    /// 协议版本号, 注意, 服务器默认`最小版本是1`
    var pVersionNum: Int?
 
    private override init() {
        navigator = Navigator.default
        super.init()
        
        // 设置监听
        setupMonitoring()
        // 网络检测
        //networkListening()
    }
}

// MARK: - 
extension Application {
    
    /// 更新配置项
    func setupConfig() {
        self.setupLocalized()
        self.setupBTManager()
        self.setupPluginsConfig()
    }
    
    func setupBTManager() {
        //FIXME: 变更外设名前缀为 广播头匹配 0x01 为产品编码(0x00-App; 0x01-M9; 0x02-G1)
        //BTManager.shared.filterKey = "LT_"
        //FIXME: OTA时, 升级前的设备重启回连, 设备的mac地址会改变, 并且广播包不符合特定约定, 所以移除广播包前缀校验
        // 排除单备份包, 后续都是双备份的
//        BTManager.shared.advDataFilter = [0xaa]
//        BTManager.shared.scan_countdown = SCAN_COUNTDOWN_MAX
//        BTManager.shared.cnct_countdown = CNCT_COUNTDOWN_MAX
    }
    
    func setupLocalized() {
        LocalizedUtils.setupLocalized()
    }
    
    func setupPluginsConfig() {
        NetworkPrintlnPlugin.showLoggers = true
    }
}

// MARK: -
extension Application {
    
    /// 设置全局监听项
    func setupMonitoring() {
//        NotificationCenter.default.rx.notification(Notification.Name.Login).subscribe(onNext: {[weak self] _ in
//            self?.initialScreen(in: self?.window)
//        }).disposed(by: rx.disposeBag)

        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe(onNext: { _ in
            print("<<切回前台")
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).subscribe(onNext: { _ in
            print(">>切换到后台")
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - call backs
extension Application {
    
    func launch(in window: UIWindow?) {
        guard let window = window else { return }
        self.window = window
        self.setupConfig()
        
        // 禁用夜间模式
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
      
        self.initialScreen(in: window)
    }
    
    func initialScreen(in window: UIWindow?) {
        guard let window = window else { return }
        
        /// 添加日志入口
        defer {
            LibsManager.shared.setupLogger()
        }
      
        /// 主页
        self.navigator.show(provider: AppScene.tabs(viewModel: TabBarViewModel(tabBarItems: TabBarItem.allCases)), sender: nil, transition: .root(in: window))
    }
}

// MARK: - delegate or data source
//extension Application { 
//    
//    // 检测网络权限变更
//    func networkListening() {
//        // import Network, NWPathMonitor 有些问题, APP启动时总数检测为蜂窝网络
//        connectedToInternet()/*.skip(1)*/.subscribe(onNext: {[weak self] status in
//            if status == .notReachable {
//                iToast.makeToast(RLocalizable.app_no_internet_tips.key.localized)
//            } else {
//                // 网络可用
//                self?.networkReachable()
//                if status == .reachable(.cellular) {
//                    iToast.makeToast(RLocalizable.app_use_mobile_data_tips.key.localized)
//                }
//            }
//        }).disposed(by: rx.disposeBag)
//    }
//    
//    func networkReachable() {
//        /// `用户协议版本`校验
//        getPublicConfig().done { config in
//            DataManager.setPConfigModel(config)
//        }.catch { error in
//            print(error.localizedDescription)
//        }
//        
//        /// `token`有效性校验
//        if AuthManager.shared.token != nil {
//            /// `refreshToken`接口暂时有问题
////            refreshToken(token: token).done { newToken in
////                AuthManager.setToken(token: newToken)
////                AuthManager.setTokenValid(true)
////            }.catch { error in
////                print(error.localizedDescription)
////            }
//            checkToken().done { status in
//                AuthManager.setTokenValid(status)
//            }.catch { error in
//                print(error.localizedDescription)
//            }
//        }
//    }
//}
