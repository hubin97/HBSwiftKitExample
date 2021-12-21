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

    /// 转指定格式字符串 (注意: 时区为系统时区)
    /// - Parameter format: 格式: yyyy-MM-dd HH:mm:ss / yyyy-MM-dd ...
    /// - Returns: 字符串
    public func format(with format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = format
        dateFomatter.timeZone = TimeZone.current
        return dateFomatter.string(from: self)
    }

    /// date to string
    /// - Parameters:
    ///   - identifier: 指定时区
    ///   - dateFormat: 格式
    /// - Returns: String
    public func toString(identifier: String = "zh_CN", dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: identifier)
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}

//MARK: - call backs
extension Extension_Date {
    
}

//MARK: - delegate or data source
extension Extension_Date {
    
}

//MARK: - other classes
