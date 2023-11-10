//
//  BaseViewController.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/7.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation

open class BaseViewController: UIViewController {
    
    //MARK: 隐藏底部边线
    var isHideNaviBarBottomLine = false {
        didSet {
            if isHideNaviBarBottomLine {
                // 注意iOS13和iOS14底线层级顺序有变,故遍历获取
                //self.navigationController?.navigationBar.subviews.first?.subviews.first?.isHidden = true
                self.navigationController?.navigationBar.subviews.first?.subviews.filter({ $0.bounds.height < 1})
                    .forEach({ $0.isHidden = true })
            }
        }
    }
    
    public enum ModeStyle {
        case white; case black
    }
    
    var autoHandle: Bool = true
    var backTapCallBack: (() -> Void)?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackBarButtonItem()
        self.setupUi()
    }
    
    open func setupUi() {
        view.backgroundColor = .white
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
    }
}

extension BaseViewController {
    
    @objc func backAction() {
        if self.autoHandle {
            self.navigationController?.popViewController(animated: true)
        }
        self.backTapCallBack?()
    }
    
    /// 自定义导航栏返回按钮
    /// - Parameters:
    ///   - autoHandle: 协助处理
    ///   - modeStyle: 主题模式, 白/ 黑
    ///   - tapEvent: 事件回调
    public func setBackBarButtonItem(modeStyle: ModeStyle = .black, autoHandle: Bool = true, tapEvent: (() -> Void)? = nil) {
        // 获取栈顶控制器, 且不是最底的控制器
        guard var topViewController = self.navigationController?.topViewController, self.navigationController?.viewControllers[0] != topViewController else { return }
        self.autoHandle = autoHandle
        self.backTapCallBack = tapEvent
        let itemImage = UIImage.bundleImage(named: modeStyle == .white ? "navi_back_w": "navi_back_b")?.withRenderingMode(.alwaysOriginal)
        topViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: itemImage, style: .plain, target: self, action: #selector(backAction))
    }
}
