//
//  TabBarItem.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import HBSwiftKit

// 枚举定义了 TabBar 中的各个选项
enum TabBarItem: TabBarItemDataProvider {
    case home, test, web
    
    var image_n: UIImage? {
        switch self {
        case .home:
            return R.image.tabBar.home_n()
        case .test:
            return R.image.tabBar.like_n()
        case .web:
            return R.image.tabBar.web_n()
        }
    }
    
    var image_h: UIImage? {
        switch self {
        case .home:
            return R.image.tabBar.home_h()
        case .test:
            return R.image.tabBar.like_h()
        case .web:
            return R.image.tabBar.web_h()
        }
    }
    
    var title: String? {
        switch self {
        case .home:
            return "Example List"
        case .test:
            return "UIKit Test"
        case .web:
            return "Web Preview"
        }
    }
    
    var viewModel: ViewModel {
        switch self {
        case .home:
            return ListViewModel()
//        case .test:
//            return UIKitTestViewModel()
//        case .web:
//            return WebPreviewViewModel()
        default:
            return ViewModel()
        }
        return ViewModel()
    }

    // 根据枚举值返回对应的视图控制器
    func controller(with viewModel: ViewModel, navigator: Navigator) -> UIViewController {
        switch self {
        case .home:
            return NavigationController(rootVc: ListViewController(viewModel: viewModel, navigator: navigator))
        case .test:
            return NavigationController(rootVc: UIKitTestController(viewModel: viewModel, navigator: navigator))
        case .web:
            return NavigationController(rootVc: WebPreviewController(viewModel: viewModel, navigator: navigator))
        }
    }
}
