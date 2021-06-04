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
 
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
    }
    
    open func setupUi() {
     
        view.backgroundColor = .white
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: 隐藏底部边线, 注意iOS13和iOS14底线层级顺序有变,故遍历获取
        //self.navigationController?.navigationBar.subviews.first?.subviews.first?.isHidden = true
        self.navigationController?.navigationBar.subviews.first?.subviews.filter({ $0.bounds.height < 1})
            .forEach({ $0.isHidden = true })
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension BaseViewController {
    
    ///!!!!: 响应BaseNavigation导航左按钮事件
    @objc func backTapAction() {
        //print("Base_backTapAction")
        self.navigationController?.popViewController(animated: true)
    }
    
}
