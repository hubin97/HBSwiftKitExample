//
//  CalendarUtils.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/29.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
extension Date {

    // MARK: -
    /// 当前月份总天数
    var daysInMonth: Int {
        return Calendar.autoupdatingCurrent.range(of: .day, in: .month, for: self)!.count
    }
    
    /// 当前月份的`1号是周几`
    var firstWeekday: Int {
        var components = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .weekday], from: self)
        components.day = 1
        return Calendar.autoupdatingCurrent.date(from: components)!.week
    }

    /// 获取当前周的所有日期, 从周日开始
    var datesOfWeek: [Date] {
        let calendar = Calendar.autoupdatingCurrent
        let weekday = calendar.dateComponents([.weekday], from: self).weekday!
        let startOfWeek = calendar.date(byAdding: .day, value: 1 - weekday, to: self)!
        return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
    
    /// 获取当前月份的所有日期
    var datesOfMonth: [Date] {
        let calendar = Calendar.autoupdatingCurrent
        let days = calendar.range(of: .day, in: .month, for: self)!.count
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.day = 1
        let startOfMonth = calendar.date(from: components)!
        return (0..<days).map { calendar.date(byAdding: .day, value: $0, to: startOfMonth)! }
    }
    
    // MARK: -
    /// 当前月的第一天
    var firstDayOfMonth: Date {
        let calendar = Calendar.current
        // 获取该日期的年、月
        let components = calendar.dateComponents([.year, .month], from: self)
        // 创建新的日期，设置为该月的第一天
        return calendar.date(from: DateComponents(year: components.year, month: components.month, day: 1))!
    }
    
    /// 当前月的最后一天
    var lastDayOfMonth: Date {
        let calendar = Calendar.current
        // 获取该日期的年、月
        let components = calendar.dateComponents([.year, .month], from: self)
        // 创建新的日期，设置为该月的最后一天
        return calendar.date(from: DateComponents(year: components.year, month: components.month! + 1, day: 0))!
    }
    
    /// 下个月第一天
    var firstDayOfNextMonth: Date {
        let calendar = Calendar.current
        // 获取该日期的年、月
        let components = calendar.dateComponents([.year, .month], from: self)
        // 创建新的日期，设置为下个月的第一天
        return calendar.date(from: DateComponents(year: components.year, month: components.month! + 1, day: 1))!
    }
    
    /// 当前周的第一天
    var firstDayOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    /// 当前周的最后一天
    var lastDayOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(byAdding: .day, value: 6, to: calendar.date(from: components)!)!
    }
    
    /// 获取指定年份差值(相对今年)的1月1日,
    /// 如 -5 即为 2019年1月1日, 如 5 即为 2029年1月1日
    func getJanuaryFirst(offsetYears: Int) -> Date {
        // 创建一个日历实例
        let calendar = Calendar.current
        // 获取指定年份的日期
        if let targetDate = calendar.date(byAdding: .year, value: offsetYears, to: Date()) {
            // 获取目标年份
            let year = calendar.component(.year, from: targetDate)
            // 创建目标年份的1月1日
            if let targetJanuaryFirst = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) {
                return targetJanuaryFirst
            }
        }
        // 如果无法计算，返回当前日期
        return Date()
    }
}

struct CalendarData {
    
    /// 星期
//    static let weeks: [String] = [RLocalizable.string_sunday.key.localized,
//                                  RLocalizable.string_monday.key.localized,
//                                  RLocalizable.string_tuesday.key.localized,
//                                  RLocalizable.string_wednesday.key.localized,
//                                  RLocalizable.string_thursday.key.localized,
//                                  RLocalizable.string_friday.key.localized,
//                                  RLocalizable.string_saturday.key.localized]
    static let weeks: [String] = ["日", "一", "二", "三", "四", "五", "六"]

    /// 返回中文 月份
    /// - Parameter month: 月份下标
    /// - Returns: 几月
    func month_Zh_CN(_ month: Int) -> String {
        if month > 12 || month < 1 {
            return "Not Found Month"
        }
        return ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"][month - 1]
    }
}

// MARK: - CalendarMeta
class LTCalendarMeta {
    /// 注意级别依次增加, `今天的样式被选中的样式覆盖`
    enum DayState {
        /// 无状态,  标记上个月的日期
        case none
        /// 正常状态, 当前月份的日期
        case normal
        /// 今天
        case today
        /// 选中状态
        case selected
        /// 不可用状态
        case disable
    }
    
    var date: Date = Date()
    var state = DayState.normal
    var isDotShow = false

    /// 是否为当前日期
    var isToday: Bool {
        // 比较两个date是否为同一天
        return Calendar.autoupdatingCurrent.isDateInToday(date)
    }
    
    init() {}
    
    convenience init(date: Date, state: DayState, isDotShow: Bool) {
        self.init()
        self.date = date
        self.isDotShow = isDotShow
        /// 非选中时, 正常状态下, 今天的样式
        if state == .normal {
            self.state = isToday ? .today: state
        } else {
            self.state = state
        }
    }
}

/// 日历主题配置
struct LTCalendarThemeConfig {
    
    /// 文本正常颜色
    var textNormalColor: UIColor = .black
    /// 文本选中颜色
    var textSelectedColor: UIColor = .white
    /// 文本不可用颜色
    var textDisableColor: UIColor = .lightGray
    /// 背景颜色
    var itemBackgroundColor: UIColor = .white
    /// 选中背景颜色
    var selectedBackgroundColor: UIColor = .red
    /// 今天背景颜色
    var todayBackgroundColor: UIColor = .red.withAlphaComponent(0.5)
    /// 今天文本颜色
    var todayTextColor: UIColor = .red
    /// 点的颜色
    var dotColor: UIColor = .red
    
    /// 文本正常大小
    var textNormalFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// 文本选中大小
    var textSelectedFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
}
