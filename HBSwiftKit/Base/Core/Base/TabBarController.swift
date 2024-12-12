//
//  TabBarController.swift
//  LuteExample
//
//  Created by hubin.h on 2023/11/10.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods

// MARK: - main class
open class TabBarController: UITabBarController, UITabBarControllerDelegate, Navigatable {
    
    var viewModel: ViewModel?
    public var navigator: Navigator!

    // 自定义初始化方法
    public init(viewModel: ViewModel?, navigator: Navigator = Navigator.default) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func bindViewModel() {
        guard let viewModel = viewModel as? TabBarViewModel else { return }
        let controllers = viewModel.tabBarItems.map({ $0.getController(with: $0.viewModel, navigator: self.navigator) })
        self.setViewControllers(controllers, animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = .white
        self.delegate = self
        self.bindViewModel()
    }
    
    /// 快捷初始化
    /// - Parameters:
    ///   - naviVcs: Vc数组, 或者Navi数组
    ///   - titles: 页签标题
    ///   - normalImages: 常态图片数组
    ///   - selectedImages: 选中图片数组
    open func addChildVcs(naviVcs: [UIViewController], titles: [String?], normalImages: [UIImage?], selectImages: [UIImage?]) {
        guard naviVcs.count == titles.count || naviVcs.count == normalImages.count && naviVcs.count == selectImages.count else {
            print("初始数组元素个数有误!")
            return
        }
        for idx in 0..<naviVcs.count {
            let navi = naviVcs[idx]
            if normalImages.isEmpty && selectImages.isEmpty {
                navi.tabBarItem = UITabBarItem(title: titles[idx], image: nil, selectedImage: nil)
            } else {
                let normal_image = normalImages[idx]?.withRenderingMode(.alwaysOriginal)
                let select_image = selectImages[idx]?.withRenderingMode(.alwaysOriginal)
                if titles.isEmpty {
                    navi.tabBarItem = UITabBarItem(title: nil, image: normal_image, selectedImage: select_image)
                } else {
                    navi.tabBarItem = UITabBarItem(title: titles[idx], image: normal_image, selectedImage: select_image)
                }
            }
        }
        self.viewControllers = naviVcs
    }
    
    /// 设置TabBar颜色相关项
    /// - Parameters:
    ///   - barTintColor: 背景色
    ///   - shadowColor: 标签栏顶部分割线颜色, 默认同 barTintColor
    ///   - normalColor: 标题正常颜色
    ///   - selectColor: 标题选中颜色
    open func setAppearance(barTintColor: UIColor = .white, shadowColor: UIColor? = nil, normalColor: UIColor, selectColor: UIColor, blurStyle: UIBlurEffect.Style? = nil) {
        
        // 如果设置了模糊效果, 则背景色设置为透明
        let barTintColor = blurStyle != nil ? UIColor.clear : barTintColor
        self.tabBar.barTintColor = barTintColor

        // @available(iOS 13.0, *) 新增UITabBarItemAppearance属性, 导致不适配tabbar上UITabBarItem 文字颜色失效
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: normalColor]
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: selectColor]
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = barTintColor
        appearance.shadowColor = shadowColor ?? barTintColor
        appearance.stackedLayoutAppearance = itemAppearance
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            // @available(iOS 15.0, *) 新增tabBar.scrollEdgeAppearance属性, 导致不适配tabbar透明现象
            self.tabBar.scrollEdgeAppearance = appearance
        }
        
        if let blurStyle = blurStyle {
            self.applyBlurEffect(blurStyle)
        }
    }
    
    // 设置模糊效果
    private func applyBlurEffect(_ blurStyle: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.tabBar.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 清除现有的子视图
        self.tabBar.subviews.forEach { subview in
            if subview is UIVisualEffectView {
                subview.removeFromSuperview() // 移除已有的模糊视图
            }
        }
        
        // 将模糊视图添加到 UITabBar
        self.tabBar.addSubview(blurEffectView)
        self.tabBar.sendSubviewToBack(blurEffectView) // 确保模糊视图在最底层
    }
    
    open override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: - private mothods
extension TabBarController { 
}

// MARK: - call backs
extension TabBarController { 
}

// MARK: - delegate or data source
extension TabBarController { 
}

// MARK: - other classes
