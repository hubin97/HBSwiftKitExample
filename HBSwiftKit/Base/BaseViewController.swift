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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
    }
    
    open func setupUi() {
     
        view.backgroundColor = .white
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    deinit {
        print("\(String(describing: type(of: self))) deinit")
    }
}

extension BaseViewController {
    
    ///!!!!: 响应BaseNavigation导航左按钮事件
    @objc open func backTapAction() {
        //print("Base_backTapAction")
        self.navigationController?.popViewController(animated: true)
    }
    
}
