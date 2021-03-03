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
    /// 全角转半角
    /// - Returns: 半角字符串
    public func fullwidthToHalfwidth() -> String {
        let srcStr = self.replacingOccurrences(of: "。", with: ".")
        let cfstr = NSMutableString(string: srcStr) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstr))
        CFStringTransform(cfstr, &range, kCFStringTransformFullwidthHalfwidth, false)
        return cfstr as String
    }
    
    /// 半角转全角
    /// - Returns: 全角字符串
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

extension String_Extension {
    
    //MARK: - 扩展下标取值方法
    ///    var str = "ABCDEFG"
    ///    let tmp = str[2, 5]
    ///    print("tmp:\(tmp)")
    ///    // Prints "tmp:CDEFG"
    ///
    ///    let tmp2 = str[2, 7]
    ///    print("tmp2:\(tmp2)")
    ///    // Prints "tmp2:subscript out of bounds !!!"
    ///
    ///    str[2, 4] = "cdef"
    ///    print("str:\(str)")
    ///    // Prints  "str:ABcdefG"
    ///
    ///    str[2, 7] = "cdefghijk"
    ///    print("str:\(str)")
    ///    // Prints "str:ABcdefghijk"
    public subscript(start: Int, length: Int) -> String {
        get {
            guard start >= 0 && start + length <= self.count else {
                return "subscript out of bounds !!!"
            }
            var subStr = ""
            for (idx, item) in self.enumerated() {
                if idx >= start && idx <= start + length {
                    subStr += "\(item)"
                }
            }
            return subStr
        }
        set {
            var s = ""
            var e = ""
            for (idx, item) in self.enumerated() {
                if(idx < start) {
                    s += "\(item)"
                } else if(idx >= start + length) {
                    e += "\(item)"
                }
            }
            self = s + newValue + e
        }
    }
    
    ///    var str = "ABCDEFG"
    ///    let tmp = str[0]
    ///    print("tmp:\(tmp)")
    ///    // Prints tmp:A
    ///
    ///    let tmp2 = str[5]
    ///    print("tmp2:\(tmp2)")
    ///    // Prints tmp2:F
    ///
    ///    str[5] = "*"
    ///    print("str:\(str)")
    ///    // Prints str:ABCDE*G
    ///
    ///    str[1] = "###"
    ///    print("str:\(str)")
    ///    // Prints str:A###CDE*G
    public subscript(index: Int) -> String {
        get {
            guard index <= self.count else {
                return "subscript out of bounds !!!"
            }
            var tmp = ""
            for (idx, item) in self.enumerated() {
                if idx == index {
                    tmp = "\(item)"
                    break
                }
            }
            return tmp
        }
        set {
            var tmp = ""
            for (idx, item) in self.enumerated() {
                if idx == index {
                    tmp += newValue
                }else{
                    tmp += "\(item)"
                }
            }
            self = tmp
        }
    }
}
