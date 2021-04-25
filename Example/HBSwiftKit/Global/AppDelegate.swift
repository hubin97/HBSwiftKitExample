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
        self.window?.makeKeyAndVisible()

        let navi = BaseNavigationController.init(rootViewController: ViewController())
        let navi2 = BaseNavigationController.init(rootViewController: UIKitTestController())
        let navi3 = BaseNavigationController.init(rootViewController: WebPreviewController())
        let tabBarVc = BaseTabBarController()
        tabBarVc.addChildVcs(naviVcs: [navi, navi2, navi3], titles: ["Example List", "UIKit Test", "Web Preview"], normalImages: [R.image.tabBar.home_n(), R.image.tabBar.like_n(), R.image.tabBar.web_n()], selectImages: [R.image.tabBar.home_h(), R.image.tabBar.like_h(), R.image.tabBar.web_h()])
        //tabBarVc.tabBar.barTintColor = .orange
        tabBarVc.setTabBarColors(normalColor: .lightGray, selectColor: .systemBlue)
        self.window?.rootViewController = tabBarVc 
        return true
    }
}
