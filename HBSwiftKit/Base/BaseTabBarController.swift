//
//  BaseTabBarController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/3/5.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods

//MARK: - main class
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
    open func setTabBarColors(barTintColor: UIColor = .white, normalColor: UIColor, selectColor: UIColor) {
        self.tabBar.barTintColor = barTintColor
        //self.tabBar.backgroundImage = nil
        //self.tabBar.shadowImage = nil
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: normalColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectColor], for: .selected)
    }
}

//MARK: - private mothods
extension BaseTabBarController {
    
}

//MARK: - call backs
extension BaseTabBarController {
    
}

//MARK: - delegate or data source
extension BaseTabBarController {
    
}

//MARK: - other classes
