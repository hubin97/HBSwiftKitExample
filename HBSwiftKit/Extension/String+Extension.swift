//
//  String+Extension.swift
//  HBSwiftKit
//
//  Created by hubin.h@wingto.cn on 2020/12/26.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import CoreFoundation

//MARK: - global var and methods
public typealias String_Extension = String
//public typealias NSString_Extension = NSString

//MARK: - main class
extension String_Extension {
    
    //MARK: - 全半角转换
    /** 测试代码段
     let string1 = "ａｂｃｄｅｆｇ，。"
     let string2 = "abcdefg,."
     let str1 = string1.fullwidthToHalfwidth()
     let str2 = string2.halfwidthToFullwidth()
     print("str1:\(str1)\nstr2:\(str2)")
     */
    /// Fullwidth to Halfwidth
    public func fullwidthToHalfwidth() -> String {
        let srcStr = self.replacingOccurrences(of: "。", with: ".")
        let cfstr = NSMutableString(string: srcStr) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &range, kCFStringTransformFullwidthHalfwidth, false)
        return cfstr as String
    }
    
    /// Halfwidth to Fullwidth  
    public func halfwidthToFullwidth() -> String {
        let srcStr = self.replacingOccurrences(of: ".", with: "。")
        let cfstr = NSMutableString(string: srcStr) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &range, kCFStringTransformFullwidthHalfwidth, true)
        return cfstr as String
    }
    
    //MARK: - 字符转日期
    /// string to date
    /// - Parameters:
    ///   - identifier: 时区
    ///   - dateFormat: 格式
    /// - Returns: Date?
    public func toDate(identifier: String = "zh_CN", dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: identifier)
        formatter.dateFormat = dateFormat
        guard let date = formatter.date(from: self) else {
            print("toDate转换失败, 取当前时间")
            return formatter.date(from: formatter.string(from: Date()))!
        }
        return date
    }
}
