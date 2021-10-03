//
//  Extension+String.swift
//  HBSwiftKit
//
//  Created by hubin.h@wingto.cn on 2020/12/26.
//  Copyright © 2020 云图数字 All rights reserved.
//  https://github.com/SwifterSwift/SwifterSwift

//单元测试 ✅
import Foundation
import CoreFoundation
import CommonCrypto

//MARK: - global var and methods
fileprivate typealias Extension_String = String
//public typealias NSExtension_String = NSString

//MARK: - main class
extension Extension_String {
    
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
    
    //MARK: - 中文转拼音
    // 参考：https://blog.csdn.net/yao1500/article/details/106032904
    /// 中文转拼音
    /// - Parameter withTone: 是否带音调, 默认不带音调
    /// - Returns: 拼音字符串
    public func toPinyin(withTone: Bool = false) -> String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        if !withTone {
            CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        }
       return String(mutableString)
    }
    
    /// 提取拼音首字母
    /// - Returns: 字符串
    public func toPYHead() -> String {
        let pinyinArray = self.toPinyin().components(separatedBy: " ")
        let initials = pinyinArray.compactMap { String(format: "%c", $0.cString(using:.utf8)![0]) }
        let firstCharJoin = initials.joined().uppercased()
        return firstCharJoin
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

    /// 计算文本段落的尺寸(默认字号17, 行距5)
    /// - Parameters:
    ///   - maxSize: 最大尺寸
    ///   - attributes: 属性
    ///   - font: 字号. 仅attributes =nil时生效
    ///   - lineSpacing: 行距. 仅attributes =nil时生效
    /// - Returns: 预计尺寸
    public func estimatedSize(maxSize: CGSize, attributes: [NSAttributedString.Key : Any]? = nil, font: UIFont = UIFont.systemFont(ofSize: 17), lineSpacing: CGFloat = 5) -> CGSize {
        guard let attributes = attributes else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing - (font.lineHeight - font.pointSize)
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byCharWrapping
            let attributes_def = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            return NSString(string: self).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes_def, context: nil).size
        }
        return NSString(string: self).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
    
    /// SwifterSwift: Check if string contains one or more emojis.
    ///
    ///        "Hello 😀".containEmoji -> true
    ///
    var containEmoji: Bool {
        // http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E6...0x1F1FF, // Regional country flags
                 0x2600...0x26FF, // Misc symbols
                 0x2700...0x27BF, // Dingbats
                 0xE0020...0xE007F, // Tags
                 0xFE00...0xFE0F, // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 127_000...127_600, // Various asian characters
                 65024...65039, // Variation selector
                 9100...9300, // Misc items
                 8400...8447: // Combining Diacritical Marks for Symbols
                return true
            default:
                continue
            }
        }
        return false
    }
    
    //MARK: - Encoded/ Decoded
    /// SwifterSwift: Readable string from a URL string.
    ///
    ///        "it's%20easy%20to%20decode%20strings".urlDecoded -> "it's easy to decode strings"
    ///
    var urlDecoded: String {
        return removingPercentEncoding ?? self
    }
    
    /// SwifterSwift: URL escaped string.
    ///
    ///        "it's easy to encode strings".urlEncoded -> "it's%20easy%20to%20encode%20strings"
    ///
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    /// SHA256加密
    /// import CommonCrypto
    /// SHA 是 Secure Hash Algorithm 的缩写，即安全哈希算法。
    /// SHA256 也成为 SHA2，它是从SHA1进化而来，目前没有发现SHA256被破坏，但随着计算机计算能力越来越强大，它肯定会被破坏，所以SHA3已经在路上了。
    func sha256() -> String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    //MARK: - NSRange usage
    /// 截取NSRange范围的子字符串
    func subString(with range: NSRange) -> String {
        let text = self as NSString
        let subStr = text.substring(with: range) as String
        return subStr
    }
    
    /// 获取子字符串的范围NSRange
    /// - Parameter subString: <#subString description#>
    /// - Returns: <#description#>
    func nsRange(of subString: String) -> NSRange {
        let text = self as NSString
        return text.range(of: subString)
    }
}

extension Extension_String {
    
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
