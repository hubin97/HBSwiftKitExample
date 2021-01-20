//
//  Date+Extension.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/11.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias Date_Extension = Date

//MARK: - main class
extension Date_Extension {
    
    //static let components: Set<Calendar.Component> = Calendar.Component.year, Calendar.Component.month, Calendar.Component.day
    //(Calendar.Component.year | Calendar.Component.month | Calendar.Component.day | Calendar.Component.weekOfMonth |  Calendar.Component.hour | Calendar.Component.minute | Calendar.Component.second | Calendar.Component.weekday)

    // 跟随用户所选日历变动
    static let calendar = Calendar.autoupdatingCurrent

    var year: Int {
        Date_Extension.calendar.component(.year, from: self)
    }
    
    var month: Int {
        Date_Extension.calendar.component(.month, from: self)
    }

    var day: Int {
        Date_Extension.calendar.component(.day, from: self)
    }
    
    /// date to string
    /// - Parameters:
    ///   - identifier: 时区
    ///   - dateFormat: 格式
    /// - Returns: String
    func toString(identifier: String = "zh_CN", dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: identifier)
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}

//MARK: - private mothods
extension Date_Extension {
    
}

//MARK: - call backs
extension Date_Extension {
    
}

//MARK: - delegate or data source
extension Date_Extension {
    
}

//MARK: - other classes
