//
//  AppDelegate.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit
import CocoaLumberjack
import HBSwiftKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.frame = UIScreen.main.bounds
        self.window?.makeKeyAndVisible()

        let navi = BaseNavigationController.init(rootViewController: ViewController())
        let navi2 = BaseNavigationController.init(rootViewController: UIKitTestController())
        let navi3 = BaseNavigationController.init(rootViewController: WebPreviewController())
        let tabBarVc = BaseTabBarController()
        tabBarVc.addChildVcs(naviVcs: [navi, navi2, navi3], titles: ["Example List", "UIKit Test", "Web Preview"], normalImages: [R.image.tabBar.home_n(), R.image.tabBar.like_n(), R.image.tabBar.web_n()], selectImages: [R.image.tabBar.home_h(), R.image.tabBar.like_h(), R.image.tabBar.web_h()])
        // tabBarVc.tabBar.barTintColor = .orange
        tabBarVc.setTabBarColors(normalColor: .lightGray, selectColor: .systemBlue)
        self.window?.rootViewController = tabBarVc

        LoggerManager.shared.launch(.debug).entrance()
        // LoggerManager.shared.removeEntrance() // 隐藏入口
        // LoggerManager.shared.logLevel = .debug // 设置日志级别
        DDLogInfo("DDLogInfo Override point for customization after application launch. ")
        DDLogDebug("DDLogDebug Override point for customization after application launch. Override point for customization after application launch. ")
        DDLogVerbose("DDLogVerbose Override point for customization after application launch. Override point for customization after application launch. Override point for customization after application launch")
        return true
    }
}
