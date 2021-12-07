//
//  Extension+PickerView.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/11/16.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

//MARK: - global var and methods
extension UIPickerView {

    /// 适配iOS14的选中灰色背景, 排除分割线; layoutSubviews()/ show()
    public func hideHighlightBgColor() {
        if #available(iOS 14.0, *) {
            let selectViews = self.subviews.filter({ $0.subviews.count == 0 })
            guard selectViews.count > 0 else { return }
            selectViews.filter({ $0.bounds.size.height > 1 }).forEach({ $0.backgroundColor = .clear })
        }
    }
}
