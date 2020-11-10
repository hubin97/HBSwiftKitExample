//
//  DateExtension.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/11.
//  Copyright © 2020 WingTo. All rights reserved.

import Foundation

//MARK: - global var and methods
public typealias DateExtension = Date

//MARK: - main class
extension DateExtension {
    
    //static let components: Set<Calendar.Component> = Calendar.Component.year, Calendar.Component.month, Calendar.Component.day
    //(Calendar.Component.year | Calendar.Component.month | Calendar.Component.day | Calendar.Component.weekOfMonth |  Calendar.Component.hour | Calendar.Component.minute | Calendar.Component.second | Calendar.Component.weekday)

    // 跟随用户所选日历变动
    static let calendar = Calendar.autoupdatingCurrent
    
    var year: Int {
        DateExtension.calendar.component(.year, from: self)
    }
    
    var month: Int {
        DateExtension.calendar.component(.month, from: self)
    }

    var day: Int {
        DateExtension.calendar.component(.day, from: self)
    }
}

//MARK: - private mothods
extension DateExtension {
    
}

//MARK: - call backs
extension DateExtension {
    
}

//MARK: - delegate or data source
extension DateExtension {
    
}

//MARK: - other classes
