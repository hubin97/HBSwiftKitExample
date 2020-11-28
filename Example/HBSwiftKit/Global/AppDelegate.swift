//
//  AppDelegate.swift
//  HBSwiftKitExample
//
//  Created by design on 2020/11/2.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window?.frame = UIScreen.main.bounds
        let navi = BaseNavigationController.init(rootViewController: ViewController())
        self.window?.rootViewController = navi
        self.window?.makeKeyAndVisible()
        return true
    }
}

