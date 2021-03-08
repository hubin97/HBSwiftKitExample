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

    public override func viewDidLoad() {
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
    public func addChildVcs(naviVcs: [UIViewController], titles: [String?], normalImages: [UIImage?], selectedImages: [UIImage?]) {
        guard naviVcs.count == titles.count && naviVcs.count == normalImages.count && naviVcs.count == selectedImages.count else {
            print("初始数组元素个数有误!")
            return
        }
        for idx in 0..<naviVcs.count {
            let navi = naviVcs[idx]
            navi.tabBarItem = UITabBarItem.init(title: titles[idx], image: normalImages[idx], selectedImage: selectedImages[idx])
        }
        self.viewControllers = naviVcs
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
