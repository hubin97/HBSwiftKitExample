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
    
    /// 导航栏返回按钮图片🔙 默认黑色
    /** 修改导航栏样式
     if let navi = self.navigationController as? BaseNavigationController {
         //navi.leftBtnImage = UIImage(named: "navi_back_b")
         navi.navigationBar.barTintColor = .blue
         navi.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
         navi.darkMode = true
     }
     */
    open var leftBtnImage = UIImage.bundleImage(named: "navi_back_b")
    /// 夜间模式, 注意夜间白色图,白天相反
    open var darkMode = false {
        didSet {
            leftBtnImage = UIImage.bundleImage(named: darkMode ? "navi_back_w": "navi_back_b")
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationBar.isTranslucent = false
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance.init()
            appearance.backgroundColor = .white
            navigationBar.titleTextAttributes = titleTextAttributes
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.barTintColor = .white
            navigationBar.titleTextAttributes = titleTextAttributes
        }
        
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
    
    //MARK: 回调返回到上层控制器,
    @objc open func backTapAction() {
        if self.topViewController?.responds(to: #selector(backTapAction)) == true {
            self.topViewController?.perform(#selector(backTapAction))
        } else {
            self.popViewController(animated: true)
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension BaseNavigationController: UINavigationControllerDelegate {
    
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let rooVc = navigationController.viewControllers[0]
        if rooVc != viewController {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: leftBtnImage?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backTapAction))
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
        //if rootViewController, set delegate nil /
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


