//
//  Macro.swift
//  IOTC
//
//  Created by Hubin_Huang on 2020/5/6.
//  Copyright © 2020 Hubin_Huang. All rights reserved.
//

import UIKit
import Foundation

//MARK: - Lay out
/// 屏幕宽高
public let kScreenWidth  = UIScreen.main.bounds.size.width
public let kScreenHeight = UIScreen.main.bounds.size.height

/// 默认导航栏高度
public let kNavBarHeight: CGFloat = 44.0

/// 状态栏高度 iPhone X (44.0) / iPhone 11 (48.0) / 20.0
public let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height

/// 是否有前刘海  (iPhone X系统 iOS 11+)
public let kIsHaveBangs = kStatusBarHeight > 20.0 ? true: false
//@available(iOS 11.0, *)
//public let kIsHaveBangs = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0) > 0.0 ? true: false

/// 顶部安全区域高度
public let kTopSafeHeight: CGFloat = kIsHaveBangs ? kStatusBarHeight : 0

/// 底部安全区域高度
public let kBottomSafeHeight: CGFloat = kIsHaveBangs ? 34: 0.0

/// 状态栏和导航栏总高度
public let kNavBarAndSafeHeight: CGFloat = kStatusBarHeight + kNavBarHeight

/// tabbar和底部安全区域总高度
public let kTabBarAndSafeHeight: CGFloat = kBottomSafeHeight + 49.0

//MARK: - Info
/// 系统版本
public let kSystemVersion = Float(UIDevice.current.systemVersion) ?? 0.0
public let kiOS9Later  = (kSystemVersion >= 9)
public let kiOS10Later = (kSystemVersion >= 10)
public let kiOS11Later = (kSystemVersion >= 11)
public let kiOS12Later = (kSystemVersion >= 12)
public let kiOS13Later = (kSystemVersion >= 13)
public let kiOS14Later = (kSystemVersion >= 14)
