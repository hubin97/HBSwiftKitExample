//
//  BaseNavigationController.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/7.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation

open class BaseNavigationController: UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationBar.isTranslucent = false
        
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            delegate = self
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
}

// MARK: - Others
extension BaseNavigationController {
    
    /// 设置导航栏
    /// - Parameters:
    ///   - barTintColor: 背景色
    ///   - titleFont: 文字大小
    ///   - titleColor: 文字颜色
    ///   - shadowColor: 导航栏底部下划线颜色, 默认同背景色
    public func setBarAppearance(barTintColor: UIColor = .white, titleFont: UIFont = UIFont.systemFont(ofSize: 17, weight: .medium), titleColor: UIColor = .black, shadowColor: UIColor? = nil) {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font : titleFont]
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
extension BaseNavigationController: UINavigationControllerDelegate {
    
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let rooVc = navigationController.viewControllers[0]
        if rooVc != viewController {
            navigationBar.backIndicatorImage = UIImage()
            navigationBar.backIndicatorTransitionMaskImage = UIImage()
            // 设置系统自带的右滑手势返回
            interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.isEnabled = true
        }
        
        // if rootViewController, set delegate nil
        if children.count == 1 {
            interactivePopGestureRecognizer?.isEnabled = false
            interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    // 自定义非根控制左侧返回按钮
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count == 1 {
            // 根控制tabBar隐藏其他控制底部
            viewController.hidesBottomBarWhenPushed = true;
        }
        super.pushViewController(viewController, animated: animated)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension BaseNavigationController: UIGestureRecognizerDelegate {
    
}


