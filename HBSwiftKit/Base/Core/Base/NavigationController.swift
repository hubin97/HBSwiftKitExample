//
//  NavigationController.swift
//  LuteExample
//
//  Created by hubin.h on 2023/11/10.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
public struct BarAttributes {
    var barTintColor: UIColor = .white
    var shadowColor: UIColor?
    var titleColor: UIColor = .black
    var titleFont: UIFont = UIFont.systemFont(ofSize: 17.0, weight: .medium)
}

// MARK: - main class
open class NavigationController: UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationBar.isTranslucent = false
        
//        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
//            delegate = self
//        }        
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
    
    /// 便捷初始化
    /// - Parameters:
    ///   - rootViewController: 根控制器
    ///   - barAttributes: 导航栏特性
    public convenience init(rootVc: UIViewController, barAttributes: BarAttributes? = nil) {
        self.init(rootViewController: rootVc)
        let attributes = barAttributes ?? BarAttributes()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: attributes.titleColor, NSAttributedString.Key.font: attributes.titleFont]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = attributes.barTintColor
            appearance.titleTextAttributes = titleTextAttributes
            appearance.shadowColor = attributes.shadowColor ?? attributes.barTintColor
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = attributes.barTintColor
            navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
    
    // MARK: 
    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - Others
extension NavigationController {
    
    /// 设置导航栏
    /// - Parameters:
    ///   - barTintColor: 背景色
    ///   - titleFont: 文字大小
    ///   - titleColor: 文字颜色
    ///   - shadowColor: 导航栏底部下划线颜色, 默认同背景色
    open func setBarAppearance(barTintColor: UIColor = .white, titleFont: UIFont = UIFont.systemFont(ofSize: 17.0, weight: .medium), titleColor: UIColor = .black, shadowColor: UIColor? = nil) {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: titleFont]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = barTintColor
            appearance.titleTextAttributes = titleTextAttributes
            appearance.shadowColor = shadowColor ?? barTintColor
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = barTintColor
            navigationBar.titleTextAttributes = titleTextAttributes
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let rooVc = navigationController.viewControllers[0]
        if rooVc != viewController {
            navigationBar.backIndicatorImage = UIImage()
            navigationBar.backIndicatorTransitionMaskImage = UIImage()
            // 设置系统自带的右滑手势返回
//            interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
//            interactivePopGestureRecognizer?.isEnabled = true
//        }
//        
//        // if rootViewController, set delegate nil /
//        if children.count == 1 {
//            interactivePopGestureRecognizer?.isEnabled = false
//            interactivePopGestureRecognizer?.delegate = nil
//        }
    }
    
    // 自定义非根控制左侧返回按钮
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count == 1 {
            // 根控制tabBar隐藏其他控制底部
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
