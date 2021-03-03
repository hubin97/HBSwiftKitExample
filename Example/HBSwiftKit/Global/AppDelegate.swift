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
        navi.tabBarItem = UITabBarItem.init(title: "Example List", image: R.image.tabBar.home_n(), selectedImage: R.image.tabBar.home_h())
        navi2.tabBarItem = UITabBarItem.init(title: "UIKit Test", image: R.image.tabBar.like_n(), selectedImage: R.image.tabBar.like_h())
        navi3.tabBarItem = UITabBarItem.init(title: "Web Preview", image: R.image.tabBar.web_n(), selectedImage: R.image.tabBar.web_h())
        let tabBarVc = UITabBarController.init()
        tabBarVc.viewControllers = [navi, navi2, navi3]
        //tabBarVc.bas = [barItems, barItems2, barItems3]
        tabBarVc.delegate = self
        tabBarVc.tabBar.isTranslucent = false
        tabBarVc.tabBar.barTintColor = .white
        self.window?.rootViewController = tabBarVc
        return true
    }
}

extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("viewController:\(viewController.title ?? ""), tag:")
    }
}
