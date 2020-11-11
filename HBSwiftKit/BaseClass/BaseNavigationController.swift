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
    public var leftBtnImage = UIImage.bundleImage(named: "navi_back_b")
    /// 夜间模式, 注意夜间白色图,白天相反
    public var darkMode = false {
        didSet {
            leftBtnImage = UIImage.bundleImage(named: darkMode ? "navi_back_w": "navi_back_b")
        }
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationBar.barTintColor = .white
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)]
        navigationBar.isTranslucent = false
        
        if responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            delegate = self
        }
    }
    
    //
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
}

// MARK: - Others
extension BaseNavigationController {
    
    @objc func backAction() {
        popViewController(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension BaseNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let rooVc = navigationController.viewControllers[0]
        if rooVc != viewController {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: leftBtnImage?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
            navigationBar.backIndicatorImage = UIImage()
            navigationBar.backIndicatorTransitionMaskImage = UIImage()
            // 设置系统自带的右滑手势返回
            interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
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
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
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


