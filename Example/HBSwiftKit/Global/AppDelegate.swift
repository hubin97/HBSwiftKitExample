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
//import FLEX

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        //FLEXManager.shared.showExplorer()
//        LoggerManager.shared.launch(.debug).entrance()
        // LoggerManager.shared.removeEntrance() // 隐藏入口
        // LoggerManager.shared.logLevel = .debug // 设置日志级别
        //DDLogInfo("DDLogInfo Override point for customization after application launch. ")
        //DDLogDebug("DDLogDebug Override point for customization after application launch. Override point for customization after application launch. ")
        //DDLogVerbose("DDLogVerbose Override point for customization after application launch. Override point for customization after application launch. Override point for customization after application launch")
        
        Application.shared.launch(in: window)
        return true
    }
}
