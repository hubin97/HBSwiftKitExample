//
//  BaseTabBarController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/3/5.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

// MARK: - global var and methods

// MARK: - main class

// 注意: 必须实现setAppearance:方法, 以便适配iOS系统新版本
open class BaseTabBarController: UITabBarController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = .white
    }
    
    /// 快捷初始化
    /// - Parameters:
    ///   - naviVcs: Vc数组, 或者Navi数组
    ///   - titles: 页签标题
    ///   - normalImages: 常态图片数组
    ///   - selectedImages: 选中图片数组
    open func addChildVcs(naviVcs: [UIViewController], titles: [String?], normalImages: [UIImage?], selectImages: [UIImage?]) {
        guard naviVcs.count == titles.count && naviVcs.count == normalImages.count && naviVcs.count == selectImages.count else {
            print("初始数组元素个数有误!")
            return
        }
        for idx in 0..<naviVcs.count {
            let navi = naviVcs[idx]
            let normal_image = normalImages[idx]?.withRenderingMode(.alwaysOriginal)
            let select_image = selectImages[idx]?.withRenderingMode(.alwaysOriginal)
            navi.tabBarItem = UITabBarItem.init(title: titles[idx], image: normal_image, selectedImage: select_image)
        }
        self.viewControllers = naviVcs
    }
    
    /// 设置TabBar颜色相关项
    /// - Parameters:
    ///   - barTintColor: 背景色
    ///   - normalColor: 标题正常颜色
    ///   - selectColor: 标题选中颜色
    ///   - shadowColor: 标签栏顶部下划线颜色, 默认 lightGray
    open func setAppearance(barTintColor: UIColor = .white, normalColor: UIColor, selectColor: UIColor, shadowColor: UIColor? = nil) {
        self.tabBar.barTintColor = barTintColor

        if #available(iOS 13.0, *) {
            // @available(iOS 13.0, *) 新增UITabBarItemAppearance属性, 导致不适配tabbar上UITabBarItem 文字颜色失效
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: normalColor]
            itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: selectColor]
            
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = barTintColor
            appearance.shadowColor = shadowColor ?? .lightGray
            appearance.stackedLayoutAppearance = itemAppearance
            self.tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                // @available(iOS 15.0, *) 新增tabBar.scrollEdgeAppearance属性, 导致不适配tabbar透明现象
                self.tabBar.scrollEdgeAppearance = appearance
            }
        }
    }
}
