//
//  StringExtension.swift
//  HBSwiftKit
//
//  Created by hubin.h@wingto.cn on 2020/12/26.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias StringExtension = String

//MARK: - main class
extension StringExtension {

    /// string to date
    /// - Parameters:
    ///   - identifier: 时区
    ///   - dateFormat: 格式
    /// - Returns: Date?
    func toDate(identifier: String = "zh_CN", dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
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

//MARK: - private mothods
extension StringExtension {
    
}

//MARK: - call backs
extension StringExtension {
    
}

//MARK: - delegate or data source
extension StringExtension {
    
}

//MARK: - other classes
