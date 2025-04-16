//
//  Extension+Color.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/3/8.
//  Copyright © 2020 Wingto. All rights reserved.

//单元测试 ✅
import Foundation

//MARK: - global var and methods
fileprivate typealias Extension_Color = UIColor

//public func RGBA(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
//    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
//}
//
//public func RGB(_ r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
//    return RGBA(r: r, g: g, b: b, a: 1)
//}
//
///// 不推荐此方式, 建议使用扩展中的便捷初始化方法
//public func HEXA(hexValue: Int, a: CGFloat) -> UIColor {
//    return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0,green: ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(hexValue & 0xFF)) / 255.0,alpha: a)
//}
//
//public func HEX(hexValue: Int) -> UIColor {
//    return HEXA(hexValue: hexValue, a: 1.0)
//}

//MARK: - main class

//MARK: - private mothods
extension Extension_Color {

    /// 获取随机色
    public static var random: UIColor {
        return UIColor(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
    }

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
        } else if hexString.hasPrefix("0x") || hexString.hasPrefix("0X") {
            scanner.scanLocation = 2
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
extension Extension_Color {
    
}

//MARK: - delegate or data source
extension Extension_Color {
    
}

//MARK: - other classes
