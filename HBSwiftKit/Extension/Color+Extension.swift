//
//  Color+Extension.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/3/8.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias Color_Extension = UIColor

//MARK: - main class

//MARK: - private mothods
extension Color_Extension {
        
    /// 整型(16进制)初始化
    /// - Parameters:
    ///   - hexValue: 0xFFFFFF
    ///   - alpha: 透明度, 默认1
    public convenience init(hexValue: Int, alpha: CGFloat = 1) {
        self.init(red: ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0, green: ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(hexValue & 0xFF)) / 255.0, alpha: alpha)
    }
    
    /// 字符串初始化
    /// - Parameters:
    ///   - hexStr: #0xFFFFFF
    ///   - alpha: 透明度, 默认1
    public convenience init(hexStr: String, alpha: CGFloat = 1) {
        let hexString = hexStr.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x0000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

//MARK: - call backs
extension Color_Extension {
    
}

//MARK: - delegate or data source
extension Color_Extension {
    
}

//MARK: - other classes
