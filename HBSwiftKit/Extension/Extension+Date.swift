//
//  Extension+Date.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/11.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation

//MARK: - global var and methods
fileprivate typealias Extension_Date = Date

//MARK: - main class
extension Extension_Date {
    
    //static let components: Set<Calendar.Component> = Calendar.Component.year, Calendar.Component.month, Calendar.Component.day
    //(Calendar.Component.year | Calendar.Component.month | Calendar.Component.day | Calendar.Component.weekOfMonth |  Calendar.Component.hour | Calendar.Component.minute | Calendar.Component.second | Calendar.Component.weekday)

    // 跟随用户所选日历变动
    public static let calendar = Calendar.autoupdatingCurrent

    public var year: Int {
        Extension_Date.calendar.component(.year, from: self)
    }
    
    public var month: Int {
        Extension_Date.calendar.component(.month, from: self)
    }

    public var day: Int {
        Extension_Date.calendar.component(.day, from: self)
    }
}

//MARK: - private mothods
extension Extension_Date {

    /// 获取当前 秒级 时间戳
    public var timeStamp: Int {
        return Int(self.timeIntervalSince1970)
    }

    /// 获取当前 毫秒级 时间戳 - 13位
    public var milliStamp: Int {
        return Int(CLongLong(round(self.timeIntervalSince1970 * 1000)))
    }

    /// 转指定格式字符串 (注意: 时区地区跟随系统)
    /// - Parameter format: 格式: yyyy-MM-dd HH:mm:ss / yyyy-MM-dd ...
    /// - Returns: 字符串
    public func format(with format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = format
        dateFomatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFomatter.string(from: self)
    }

    /// 转指定格式字符串 `(注意此方法不常用)`
    ///    “GMT”：格林威治标准时间
    ///    “Asia/Shanghai”：北京时间  东8区
    ///    “America/New_York”：纽约时间  西5区
    ///    “Europe/London”：伦敦时间   0
    ///    “Australia/Sydney”：悉尼时间
    /// - Parameters:
    ///   - format: 格式
    ///   - identifier: 指定时区标识,
    /// - Returns: String
    public func format(with format: String = "yyyy-MM-dd HH:mm:ss", identifier: String) -> String {
        let dateFomatter = DateFormatter()
        dateFomatter.timeZone = TimeZone.init(identifier: identifier)
        dateFomatter.dateFormat = format
        return dateFomatter.string(from: self)
    }
}

//MARK: - call backs
extension Extension_Date {
    
}

//MARK: - delegate or data source
extension Extension_Date {
    
}

//MARK: - other classes
