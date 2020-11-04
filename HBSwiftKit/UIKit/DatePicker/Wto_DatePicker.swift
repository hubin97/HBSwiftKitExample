//
//  Wto_DatePicker.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/11.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods
fileprivate let minYear = 1970
fileprivate let maxYear = 2050

extension Wto_DatePicker {
    
    public enum Mode {
        /// 年
        case year
        /// 年/月
        case year_month
        /// 年/月/日
        case year_month_day
        /// 年/第几周
        case year_week
    }
}

//MARK: - main class
open class Wto_DatePicker: UIPickerView {

    /// 默认 年月日
    public var datePickerMode: Wto_DatePicker.Mode = .year_month_day {
        didSet {
            initDatePicker()
        }
    }

    /// 单位描述
    var isSelectDecs: Bool = false
    
    /// 单位符号
    var yearUnit: String  = "年"
    var monthUnit: String = "月"
    var dayUnit: String   = "日"
    var weekUnit: String  = "周"

    /// 选中栏下标
    public var dateIndex = DateIndex()
    
    // ----
    /// 年数组
    let years: [Int] = {
        var years = [Int]()
        for i in minYear...maxYear {
            years.append(i)
        }
        return years
    }()
    
    /// 月数组
    let months: [Int] = {
        var months = [Int]()
        for i in 1...12 {
            months.append(i)
        }
        return months
    }()
    
    /// 根据年月获取当月天数
    func days(year: Int, month: Int) -> [Int] {
        
        /// 是否闰年
        let isLeapYear = year % 4 == 0 ? (year % 100 == 0 ? (year % 400 == 0 ? true : false): true): false
        var maxdays = 1
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            maxdays = 31
            break
        case 4, 6, 9, 11:
            maxdays = 30
            break
        case 2:
            maxdays = isLeapYear ? 29: 28
            break
        default:
            fatalError("month error")
        }
        
        var days = [Int]()
        for i in 1...maxdays {
            days.append(i)
        }
        return days
    }
    
    /// 周数组 默认52周
    let weeks: [Int] = {
        var weeks = [Int]()
        for i in 0..<52 {
            weeks.append(i)
        }
        return weeks
    }()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone.system
        return formatter
    }()
    
    public func weekdates(year: Int) -> [String] {

        let initDate = startDayOfWeekOfYear(year: year)
        var weekdates = [String]()
        for i in 0..<weeks.count {
            let startDate = Date.init(timeInterval: TimeInterval(24 * 60 * 60 * 7 * i), since: initDate)
            let endedDate = Date.init(timeInterval: TimeInterval(24 * 60 * 60 * 6), since: startDate)
            let startYMDs = formatter.string(from: startDate).split(separator: "-")
            let endedYMDs = formatter.string(from: endedDate).split(separator: "-")
            let weekString = "第\(i + 1)\(weekUnit)(\(startYMDs[1])\(monthUnit)\(startYMDs[2])-\(endedYMDs[1])\(monthUnit)\(endedYMDs[2]))"
            weekdates.append(weekString)
        }
        return weekdates
    }
    
    /// 取得当前年的第一周的第一天
    public func startDayOfWeekOfYear(year: Int) -> Date {
           
        let date = formatter.date(from: "\(year)-01-01") ?? Date()
        let calender = NSCalendar.autoupdatingCurrent
        let com = calender.dateComponents([Calendar.Component.year, Calendar.Component.weekday, Calendar.Component.weekOfYear], from: date)

        // 设定由周一开始
        var firstday: Date = Date.init(timeInterval: -Double((com.weekday ?? 1) - 2) * 24 * 3600, since: date)
        if com.weekday == 1 { // 周日
            firstday = Date.init(timeInterval: -6 * 24 * 3600, since: date)
        }
        return firstday
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.delegate = self
        
        initDatePicker()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension Wto_DatePicker {
    
    func initDatePicker(date: Date = Date()) {
        
        self.reloadAllComponents()

        dateIndex.yearIndex = date.year - minYear
        dateIndex.monthIndex = date.month - 1
        dateIndex.dayIndex = date.day - 1
        dateIndex.weekIndex = 0
     
        switch datePickerMode {
        case .year:
            self.selectRow(dateIndex.yearIndex, inComponent: 0, animated: true)
            break
        case .year_month:
            self.selectRow(dateIndex.yearIndex, inComponent: 0, animated: true)
            self.selectRow(dateIndex.monthIndex, inComponent: 1, animated: true)
            break
        case .year_month_day:
            self.selectRow(dateIndex.yearIndex, inComponent: 0, animated: true)
            self.selectRow(dateIndex.monthIndex, inComponent: 1, animated: true)
            self.selectRow(dateIndex.dayIndex, inComponent: 2, animated: true)
            break
        case .year_week:
            self.selectRow(dateIndex.yearIndex, inComponent: 0, animated: true)
            self.selectRow(dateIndex.weekIndex, inComponent: 1, animated: true)
            break
        }
    }
}

//MARK: - call backs
extension Wto_DatePicker {
    
}

//MARK: - delegate or data source
extension Wto_DatePicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        switch datePickerMode {
        case .year:
            return 1
        case .year_month:
            return 2
        case .year_month_day:
            return 3
        case .year_week:
            return 2
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch datePickerMode {
        case .year:
            return years.count
        case .year_month:
            return component == 0 ? years.count: months.count
        case .year_month_day:
            return component == 0 ? years.count: (component == 1) ? months.count: days(year: dateIndex.yearIndex + minYear, month: dateIndex.monthIndex + 1).count
        case .year_week:
            return component == 0 ? years.count: weeks.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var str_year = "\(row + minYear)"
        var str_month = "\(row + 1)"
        var str_day = "\(row + 1)"

        str_year = !isSelectDecs ? "\(str_year)\(yearUnit)": str_year
        str_month = !isSelectDecs ? "\(str_month)\(monthUnit)": str_month
        str_day = !isSelectDecs ? "\(str_day)\(dayUnit)": str_day

        switch datePickerMode {
        case .year:
            return str_year
        case .year_month:
            return component == 0 ? str_year: str_month
        case .year_month_day:
            return component == 0 ? str_year: (component == 1) ? str_month: str_day
        case .year_week:
            if component == 0 {
                return str_year
            } else {
                return weekdates(year: dateIndex.year)[row]
            }
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch datePickerMode {
        case .year:
            dateIndex.yearIndex = row
            break
        case .year_month:
            if component == 0 {
                dateIndex.yearIndex = row
            } else {
                dateIndex.monthIndex = row
            }
            break
        case .year_month_day:
            if component == 0 || component == 1 {
                if component == 0 {
                    dateIndex.yearIndex = row
                } else {
                    dateIndex.monthIndex = row
                }
                pickerView.reloadComponent(2)
            } else {
                dateIndex.dayIndex = row
            }
            break
        case .year_week:
            if component == 0 {
                dateIndex.yearIndex = row
                pickerView.reloadComponent(1)
            } else {
                dateIndex.weekIndex = row
            }
            break
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        let width = pickerView.bounds.width
        switch datePickerMode {
        case .year:
            return width
        case .year_month:
            return width/2
        case .year_month_day:
            return width/3
        case .year_week:
            return component == 0 ? width/4: width*3/4
        }
    }
}

//MARK: - other classes
public class DateIndex {
    
    public var year: Int{
        yearIndex + minYear
    }
    
    public var month: Int{
        monthIndex + 1
    }
    
    public var day: Int{
        dayIndex + 1
    }
    
    public var week: Int{
        weekIndex + 1
    }
    
    public var yearIndex: Int
    public var monthIndex: Int
    public var dayIndex: Int
    public var weekIndex: Int
    
    init() {
        yearIndex = 0
        monthIndex = 0
        dayIndex = 0
        weekIndex = 0
    }
}
