//
//  iToast.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2022/7/7.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import Toast_Swift

public final class iToast {
    
    /// iToast (Toast_Swift封装接口)
    /// - Parameters:
    ///   - content: 文本
    ///   - title: 标题
    ///   - image: 图标
    ///   - imageSize: 图标尺寸
    ///   - duration: 持续时间, 默认  2s
    ///   - position: 显示位置, 默认中间
    ///   - completion: 点击回调
    public static func makeToast(_ content: String, title: String? = nil, image: UIImage? = nil, imageSize: CGSize? = nil, duration: TimeInterval = 1.0, position: ToastPosition = .center, completion: ((_ didTap: Bool) -> Void)? = nil) {
        var style = ToastStyle()
        style.backgroundColor = .darkGray
        style.cornerRadius = 5
        if let image = image {
            style.imageSize = imageSize ?? image.size
        }
        let minDuration = max(Double(content.count) * 0.06 + 0.5, duration)
        DispatchQueue.main.async {
            kAppKeyWindow?.makeToast(content, duration: minDuration, position: position, title: title, image: image, style: style, completion: completion)
        }
    }
}
