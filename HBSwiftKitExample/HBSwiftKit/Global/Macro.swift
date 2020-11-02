//
//  Macro.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/6.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation


/// 屏幕宽高
public let kScreenWidth  = UIScreen.main.bounds.size.width
public let kScreenHeight = UIScreen.main.bounds.size.height

/// 判断是否是iPhone X系列
// FIXME:注意 此处SceneDelegate, 如果适配iOS13以下换成AppDelegate
//public func isiPhoneX() ->Bool {
//    if #available(iOS 11.0, *) {
//        return (UIApplication.shared.delegate as? AppDelegate)?.window?.safeAreaInsets.bottom ?? CGFloat(0) > CGFloat(0)
//    } else {
//        return false
//
//    }
//}

/// 判断是否是iPhone X系列
public let isIPhoneX = (UIApplication.shared.statusBarFrame.size.height == 44.0) ? true: false

/// 默认导航栏高度
public let kNavBarHeight: CGFloat = 44.0

/// 顶部安全区域高度
public let kTopSafeHeight: CGFloat = isIPhoneX ? 44.0 : 0

/// 底部安全区域高度
public let kBottomSafeHeight: CGFloat = isIPhoneX ? 34.0 : 0

/// 状态栏高度
public let kStatusBarHeight: CGFloat = isIPhoneX ? 44.0 : 20.0

/// 状态栏和导航栏总高度
public let kNavBarAndSafeHeight: CGFloat = isIPhoneX ? 88.0 : 64.0

/// tabbar和底部安全区域总高度
public let kTabBarAndSafeHeight: CGFloat = isIPhoneX ? 83.0 : 49.0

