//
//  AppDelegate.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

// [Swift常用资料整理](https://hubin97.github.io/2020/12/25/Swift常用资料整理/)
import UIKit
import CocoaLumberjack
import HBSwiftKit
import FLEX

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
        tabBarVc.setAppearance(normalColor: .lightGray, selectColor: .systemBlue)
        
        navi.setBarAppearance(shadowColor: .blue)
        navi2.setBarAppearance(barTintColor: UIColor(hexStr: "#F7F7F7"), titleColor: .black)
        navi3.setBarAppearance(titleFont: UIFont.systemFont(ofSize: 20, weight: .medium), titleColor: .brown)

        self.window?.rootViewController = tabBarVc

        //FLEXManager.shared.showExplorer()
        LoggerManager.shared.launch(.debug).entrance()
        // LoggerManager.shared.removeEntrance() // 隐藏入口
        // LoggerManager.shared.logLevel = .debug // 设置日志级别
        //DDLogInfo("DDLogInfo Override point for customization after application launch. ")
        //DDLogDebug("DDLogDebug Override point for customization after application launch. Override point for customization after application launch. ")
        //DDLogVerbose("DDLogVerbose Override point for customization after application launch. Override point for customization after application launch. Override point for customization after application launch")
        return true
    }
}
