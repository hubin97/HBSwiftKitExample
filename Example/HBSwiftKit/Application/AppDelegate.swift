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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LibsManager.shared.setupLibs()
        Application.shared.launch(in: window)
        BGTaskManager.shared.setupBackgroundTask()
        return true
    }
}
