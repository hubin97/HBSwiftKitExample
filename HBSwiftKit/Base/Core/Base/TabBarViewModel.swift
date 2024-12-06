//
//  TabBarViewModel.swift
//  Petcozy
//
//  Created by hubin.h on 2024/5/28.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import UIKit

public protocol TabBarItemDataProvider where Self: CaseIterable {
    // 根据枚举值返回对应的图标
    var image_n: UIImage? { get }
    // 根据枚举值返回对应的图标
    var image_h: UIImage? { get }
    // 根据枚举值返回对应的标题
    var title: String? { get }
    
    // 根据底部标签栏项目返回对应的ViewModel
    var viewModel: ViewModel { get }
    // 重写指定返回对应的视图控制器
    func controller(with viewModel: ViewModel, navigator: Navigator) -> UIViewController
}

extension TabBarItemDataProvider {
    
    // 创建并返回对应的视图控制器，同时配置 TabBarItem
    func getController(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        let vc = controller(with: viewModel, navigator: navigator)
        vc.tabBarItem = UITabBarItem(title: title, image: image_n?.withRenderingMode(.alwaysOriginal), selectedImage: image_h?.withRenderingMode(.alwaysOriginal))
        vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        return vc
    }
}

// MARK: - main class
public class TabBarViewModel: ViewModel {

    var tabBarItems: [any TabBarItemDataProvider] = []
    public init(tabBarItems: [any TabBarItemDataProvider]) {
        self.tabBarItems = tabBarItems
    }
    
    required public override init() {
        fatalError("init() has not been implemented")
    }
}
