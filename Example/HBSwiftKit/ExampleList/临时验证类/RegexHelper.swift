//
//  RegexHelper.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/2/25.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

///// 正则表达式匹配
//infix operator =~ : HBPrecedence
//
//precedencegroup HBPrecedence {
//    associativity: none // 结合律 无
//    higherThan: AdditionPrecedence // 优于 + 运算符
//    lowerThan: MultiplicationPrecedence // 低于 * 运算符
//}
//
//func =~ (pattern: String, input: String) -> Bool {
//    return RegexHelper(pattern).match(input: input)
//}

// MARK: - main class
struct RegexHelper {

    ///正则匹配模式
    enum Pattern: String {
        ///汉字匹配表达式
        case zh = "[\\u4E00-\\u9FA5]+"
        ///非汉字匹配表达式
        case nonZh = "[^\\u4E00-\\u9FA5]+"
        ///英文字母匹配表达式
        case alphabet = "[a-zA-Z]+"
        ///非英文字母匹配表达式
        case nonAlphabet = "[^a-zA-Z]+"
        ///数字匹配表达式
        case number = "[0-9]+"
        ///非数字匹配表达式
        case nonNumber = "[^0-9]+"
        ///浮点数匹配表达式
        case float = "[0-9.]+"
        ///非浮点数匹配表达式
        case nonFloat = "[^0-9.]+"
    }

    let regex: NSRegularExpression?
    /// 初始化
    /// - Parameter pattern: 匹配模板(RegexHelper.Pattern)
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }

    /// 不准???
    func match(input: String) -> Bool {
        if let matchs = regex?.matches(in: input, options: [], range: NSMakeRange(0, input.count)) {
            return matchs.count > 0
        }
        return false
    }

    /// 谓词
    func match(input: String, regular: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regular)
        return predicate.evaluate(with: input)
    }
}
