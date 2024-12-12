//
//  ViewController.swift
//  LuteExample
//
//  Created by hubin.h on 2023/11/10.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods

// MARK: - main class
open class ViewController: UIViewController, Navigatable, NaviBarDelegate {
        
    public var viewModel: ViewModel?
    public var navigator: Navigator!

    public init(viewModel: ViewModel?, navigator: Navigator = Navigator.default) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 默认开启左滑导航手势
    public var enablePopGestureRecognizer = true
    
    public lazy var naviBar: NaviBar = {
        let _naviBar = NaviBar()
        _naviBar.delegate = self
        return _naviBar
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(naviBar)
        
        if let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
            interactivePopGestureRecognizer.addTarget(self, action: #selector(handlePopGesture(_:)))
        }
        
        if LocalizedUtils.isRTL() {
            self.view.semanticContentAttribute = .forceRightToLeft
        } else {
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        
        self.setupLayout()
        self.bindViewModel()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 禁用返回手势,需要开启只需设置为yes即可。默认开启
        if let navi = self.navigationController, navi.responds(to: #selector(getter: navi.interactivePopGestureRecognizer)) {
            if self.navigationController?.viewControllers.count == 1 {
                navi.interactivePopGestureRecognizer?.isEnabled = false
                navi.interactivePopGestureRecognizer?.delegate = nil
            } else {
                navi.interactivePopGestureRecognizer?.delegate = navi as? UIGestureRecognizerDelegate
                navi.interactivePopGestureRecognizer?.isEnabled = enablePopGestureRecognizer
            }
        }
    }

    deinit {
        print("\(String(describing: type(of: self))) deinit")
    }
    
    // MARK: 配置
    /// 设置布局
    open func setupLayout() {
    
    }
    
    /// viewModel绑定
    open func bindViewModel() {}
    
    // MARK: 导航栏事件
    open func backAction() {
        if self.presentingViewController != nil {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    open func rightAction() {}
    
    open func popGestureAction() {}
    
    // MARK: 是否旋转
    open override var shouldAutorotate: Bool {
        return false
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - private mothods
extension ViewController { 
    
    @objc open func handlePopGesture(_ ges: UIGestureRecognizer) {
        if ges.state == .began {
            self.popGestureAction()
        }
    }
}
