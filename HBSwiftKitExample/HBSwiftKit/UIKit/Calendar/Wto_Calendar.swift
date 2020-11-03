//
//  Wto_Calendar.swift
//  WingToSmart
//
//  Created by hubin.h@wingto.cn on 2020/6/15.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods

fileprivate let SCREEN_WIDTH = UIScreen.main.bounds.width
// 以6s为准的缩放比例
fileprivate let Scale_Width = UIScreen.main.bounds.width / 375
fileprivate func W_Scale(_ x:CGFloat) -> CGFloat {
    return Scale_Width * x
}


//MARK: - main class
open class Wto_Calendar: UIView {

    fileprivate var date = Date() // 默认当天
    fileprivate var isCurrentMonth: Bool = false // 是否当月
    fileprivate var currentMonthTotalDays: Int = 0 //当月的总天数
    fileprivate var firstDayIsWeekInMonth: Int = 0 //每月的一号对于的周几
    fileprivate var lastSelectedItemIndex: IndexPath? //获取最后一次选中的索引
    fileprivate let today: String = String(Wto_CalendarUtils.day(Date()))  //当天几号
    
    /// 当前标记点数组 Array<String>  yyyy-MM-dd, 得匹配日期那一天
    var originPointArray = Array<String>() {
        didSet {
            calendarCollectionView.reloadData()
        }
    }
    
    /// 回调所选日期
    var callBackSelectedDay: ((_ selectedDay: String) -> ())?
    
    /// 回调前一个或者后一个月的日期
    var callBackSelectedMonth: ((_ selectedMonth: String) -> ())?
    
    /// 当前选中的日期, 默认为当天
    var selectedDay: String = Wto_CalendarUtils.stringFromDate(date: Date(), format: "yyyy-MM-dd")
    
    /// 日历控件头部   75 + 40
    private lazy var calendarHeadView: UIView = {
        let calendarHeadView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 64 + 40))
        return calendarHeadView
    }()
    
    /// 日历控件title  64
    fileprivate lazy var dateLabel: UILabel = {
        let labelWidth: CGFloat = 200.0
        let originX: CGFloat = (SCREEN_WIDTH - labelWidth) / 2.0
        let dateLabel = UILabel(frame: CGRect(x: originX, y: 10, width: labelWidth, height: 54))
        dateLabel.font = UIFont.systemFont(ofSize: W_Scale(16), weight: .semibold)
        dateLabel.textAlignment = .center
        return dateLabel
    }()
        
    /// 上个月
    fileprivate lazy var lastMonthButton: UIButton = {
        let last = self.createButton(imageName: "last_month_normal", disabledImage: "last_month_enabled")
        last.frame.origin.x = W_Scale(20)
        last.addTarget(self, action: #selector(lastMonthAction), for: .touchUpInside)
        return last
    }()
    
    /// 下个月
    fileprivate lazy var nextMonthButton: UIButton = {
        let next = self.createButton(imageName: "next_month_normal", disabledImage: "next_month_enabled")
        next.frame.origin.x = SCREEN_WIDTH - next.frame.width - 20
        next.addTarget(self, action: #selector(nextMonthAction), for: .touchUpInside)
        return next
    }()

    /// 划线
    fileprivate lazy var dateBottomLine: UIView = {
        let line = UIView.init(frame: CGRect(x: 0, y: self.dateLabel.frame.maxY, width: SCREEN_WIDTH, height: 1))
        line.backgroundColor = .lightGray
        return line
    }()
    
    let margin: CGFloat = 10.0
    let paddingLeft: CGFloat = 20.0

    private lazy var weekView: UIView = {
        
        let itemWidth: CGFloat = CGFloat(SCREEN_WIDTH - paddingLeft * 2 - margin * 6) / 7
        let weekView = UIView(frame: CGRect(x: paddingLeft, y: self.dateLabel.frame.maxY, width: SCREEN_WIDTH - paddingLeft * 2, height: 40))
        var weekArray = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        var originX: CGFloat = 0.0
        for weekStr in weekArray {
            let week = UILabel()
            week.frame = CGRect(x: originX, y: 10, width: itemWidth, height: 20)
            week.text = weekStr
            week.textColor = .black
            week.font = UIFont.systemFont(ofSize: W_Scale(12), weight: .medium)
            week.textAlignment = .center
            weekView.addSubview(week)
            originX = week.frame.maxX + margin
        }
        return weekView
    }()

    /// 日历瀑布流  215- 270
    fileprivate lazy var calendarCollectionView: UICollectionView = {
        
        let collectionH = W_Scale(215)
        let itemWidth: CGFloat = CGFloat((collectionH - 4 * margin) / 5)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        //layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        let vWidth: CGFloat = SCREEN_WIDTH - paddingLeft * 2
        let tempRect = CGRect(x: paddingLeft, y: self.calendarHeadView.frame.maxY, width: vWidth, height: collectionH)
        let calendarCollectionView = UICollectionView(frame: tempRect, collectionViewLayout: layout)
        calendarCollectionView.backgroundColor = UIColor.white
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(CalendarItem.self, forCellWithReuseIdentifier: NSStringFromClass(CalendarItem.self))
        return calendarCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .white
        
        self.initCalendar()

        self.addSubview(calendarHeadView)
        calendarHeadView.addSubview(dateLabel)
        calendarHeadView.addSubview(lastMonthButton)
        calendarHeadView.addSubview(nextMonthButton)
        calendarHeadView.addSubview(dateBottomLine)
        calendarHeadView.addSubview(weekView)
        
        self.addSubview(calendarCollectionView)
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: W_Scale(330)))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension Wto_Calendar {
    
    /// last next month button
    private func createButton(imageName: String, disabledImage: String) -> UIButton {
        let button = UIButton(type: .custom)
        let originY: CGFloat = (self.dateLabel.frame.height - W_Scale(28)) / 2 + 10
        button.frame = CGRect(x: 0, y: originY, width: W_Scale(28), height: W_Scale(28))
        button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        button.setBackgroundImage(UIImage(named: imageName), for: .highlighted)
        button.setBackgroundImage(UIImage(named: disabledImage), for: .disabled)
        return button
    }
    
    
    /// 初始化日历
    func initCalendar() {
        
        //当前月份的总天数
        self.currentMonthTotalDays = Wto_CalendarUtils.daysInCurrMonth(date: date)
        
        //当前月份第一天是周几
        self.firstDayIsWeekInMonth = Wto_CalendarUtils.firstDayIsWeekInMonth(date: date)
        
        /// 当前月子串
        let dateStr = Wto_CalendarUtils.stringFromDate(date: date, format: "yyyy-MM")
       
        // 是否当月
        let nowDate: String = Wto_CalendarUtils.stringFromDate(date: Date(), format: "yyyy-MM")
        self.isCurrentMonth = nowDate == dateStr
        
        ///FIXME: 限制当前月不能查看下个月
        self.nextMonthButton.isEnabled = !self.isCurrentMonth
        
        //重置日历高度  2020/02   2020/08  2019/11
        let days = self.currentMonthTotalDays + self.firstDayIsWeekInMonth
        let rowCount: Int = (days % 7 == 0) ? (days / 7) : ((days / 7) + 1)
        
        let collectionH = W_Scale(215)
        let itemWidth: CGFloat = CGFloat((collectionH - 4 * margin) / 5)
        let kitHeight: CGFloat = itemWidth * CGFloat(rowCount) + CGFloat(rowCount) * margin
        calendarCollectionView.frame.size.height = kitHeight
        
        // 更新整个日历控件高度
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: W_Scale(104 + 10) + kitHeight)

        /// 展示富文本 当前月标红
        let newDateStr = dateStr.replacingOccurrences(of: "-", with: "·")
        let attributedString = NSMutableAttributedString.init(string: newDateStr)
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: W_Scale(16), weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black], range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: W_Scale(16), weight: .semibold), NSAttributedString.Key.foregroundColor: self.isCurrentMonth ? UIColor.red : UIColor.black], range: NSRange(location: attributedString.length - 2, length: 2))
        self.dateLabel.attributedText = attributedString
    }
}

//MARK: - call backs
extension Wto_Calendar {
    
    @objc func lastMonthAction() {
        //print("lastMonthAction--")
        
        self.date = Wto_CalendarUtils.lastMonth(date)
        self.initCalendar()
        calendarCollectionView.reloadData()
        
        callBackSelectedMonth?(Wto_CalendarUtils.stringFromDate(date: self.date, format: "yyyy-MM"))
    }
    
    @objc func nextMonthAction() {
        //print("nextMonthAction--")
        
        self.date = Wto_CalendarUtils.nextMonth(date)
        self.initCalendar()
        calendarCollectionView.reloadData()
        
        callBackSelectedMonth?(Wto_CalendarUtils.stringFromDate(date: self.date, format: "yyyy-MM"))
    }
}

//MARK: - delegate or data source
extension Wto_Calendar: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let days = Wto_CalendarUtils.daysInCurrMonth(date: date) + Wto_CalendarUtils.firstDayIsWeekInMonth(date: date)
        return days
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let item = collectionView.getRecycleCell(indexPath, CalendarItem.self)
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CalendarItem.self), for: indexPath) as! CalendarItem
        
        item.clearDaysLabelStyle()
                       
        var day = 0
        let index = indexPath.row
        
        if index < self.firstDayIsWeekInMonth {
            item.daysLabel.text = ""
        } else {
            day = index - self.firstDayIsWeekInMonth + 1
            item.daysLabel.text = String(day)
            
            ///FIXME: 匹配日期格式(yyyy-MM-dd)数组
            let dateStr = Wto_CalendarUtils.stringFromDate(date: date, format: "yyyy-MM")
            let current_date = dateStr + String(format: "-%02d", day)

//            let newdate = Wto_CalendarUtils.dateFromString(dateStr: current_date)
//            let newdateStr = Wto_CalendarUtils.stringFromDate(date: newdate, format: "yyyy-MM-dd")
            //print(current_date)
            
            if originPointArray.contains(current_date) {
                item.isPointShow = true
            }
            
            if isCurrentMonth {
                //当天
                if item.daysLabel.text == today {
                    item.isSelectedItem = true
                    self.lastSelectedItemIndex = indexPath
                } else {
                    item.isSelectedItem = false
                }
                
                ///FIXME: 限制当月当天以后的日期置灰，不可点击
                if day > Int(today)! {
                    item.isDisable = true
                }
            }
        }

        return item
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! CalendarItem
        
        /// 是否已经选中
        //FIXME: 允许选中可重复点击, 再次选中当天修改
//        guard !currentCell.isSelectedItem else {
//            return
//        }
        
        /// 是否有值
        let itemText: String = currentCell.daysLabel.text!
        guard !itemText.isEmpty else {
            return
        }
        
        /// FIXME: 限制当月当天以后的日期置灰，不可点击
        let currDay = indexPath.row - self.firstDayIsWeekInMonth + 1
        //print("###\(currDay)")
        
        if self.isCurrentMonth && currDay > Int(today)! {
            return
        }
        
        /// 获取上一次选中的item
        let preCell = collectionView.cellForItem(at: self.lastSelectedItemIndex!) as! CalendarItem
        preCell.isSelectedItem = false
        
        /// 即使当天日期没选择也标记
        if isCurrentMonth && preCell.daysLabel.text == today {
            preCell.markToday = true
        }
        
        // 获取当前选中的item
        currentCell.isSelectedItem = true
        self.lastSelectedItemIndex = indexPath
        
        /// 打印当前选中日期
        //print("@@@\(selectedDay)")
        let dateStr = Wto_CalendarUtils.stringFromDate(date: date, format: "yyyy-MM")
        let currDay_dd = NSString(format: "%02d", currDay) as String
        
        selectedDay = dateStr + "-\(currDay_dd)"
        //print(dateStr + "-\(currDay)")
        self.callBackSelectedDay?(self.selectedDay)
    }
}

//MARK: - others
/// calendarItem
class CalendarItem: UICollectionViewCell {
    
    let collectionH = W_Scale(215)
    let margin: CGFloat = 10.0
    let labelWH = W_Scale(30)
    lazy var daysLabel: UILabel = {
        
        let itemWH: CGFloat = CGFloat((collectionH - 4 * margin) / 5)
        let padding: CGFloat = (itemWH - labelWH)/2.0
        let daysLabel = UILabel(frame: CGRect(x: padding, y: padding, width: labelWH, height: labelWH))
        daysLabel.textAlignment = .center
        daysLabel.font = UIFont.systemFont(ofSize: W_Scale(16), weight: .medium)
        daysLabel.layer.cornerRadius = labelWH / 2
        daysLabel.layer.masksToBounds = true
        daysLabel.layer.shouldRasterize = true
        daysLabel.isUserInteractionEnabled = true
        return daysLabel
    }()
    
    private lazy var pointLayer: CALayer = {
        let point = CALayer()
        point.backgroundColor = UIColor.red.cgColor
        var originX: CGFloat = (self.daysLabel.frame.width - 5) / 2.0
        point.frame = CGRect(x: originX, y: self.daysLabel.frame.height - 5, width: 5, height: 5)
        point.cornerRadius = point.bounds.width / 2
        point.masksToBounds = true
        return point
    }()

    var isPointShow: Bool = false {
        didSet {
            if self.isPointShow {
                self.daysLabel.layer.addSublayer(self.pointLayer)
            } else {
                self.pointLayer.removeFromSuperlayer()
            }
        }
    }
    
    var isSelectedItem: Bool = false {
        didSet {
            if isSelectedItem {
                self.daysLabel.backgroundColor = .red
                self.daysLabel.textColor = UIColor.white
            } else {
                self.daysLabel.backgroundColor = UIColor.white
                self.daysLabel.textColor = .black
            }
        }
    }
    
    // 是否禁用
    var isDisable: Bool = false {
        didSet {
            if isDisable {
                self.daysLabel.textColor = .lightGray
            }
        }
    }
    
    /// 标记当天日期
    var markToday: Bool = false {
        didSet {
            self.daysLabel.textColor = .red
        }
    }
    
    
    // 清除现有日期label上的所有样式
    func clearDaysLabelStyle() {
        daysLabel.text = ""
        daysLabel.backgroundColor = UIColor.white
        daysLabel.textColor = .black
        pointLayer.removeFromSuperlayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(daysLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 日历相关工具类
class Wto_CalendarUtils: NSObject {
    
    /// Date转换String
    ///
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 格式
    /// - Returns: 字符串日期
    class func stringFromDate(date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter.init()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = format
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    
    /// String转换Date
    /// - Parameters:
    ///   - dateStr: 字符串日期
    ///   - format: 格式
    /// - Returns: 日期
    class func dateFromString(dateStr: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter.init()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = format
        let date = formatter.date(from: dateStr) ?? Date()
        return date
    }

    
    /// 上个月
    ///
    /// - Parameter date: 当前日期
    /// - Returns: 上月日期
    class func lastMonth(_ date: Date) -> Date {
        var dateCom = DateComponents()
        dateCom.month = -1
        let newDate = (Calendar.current as NSCalendar).date(byAdding: dateCom, to: date, options: NSCalendar.Options.matchStrictly)
        return newDate!
    }
    
    /// 下个月
    ///
    /// - Parameter date: 当前日期
    /// - Returns: 下个月日期
    class func nextMonth(_ date: Date) -> Date {
        var dateCom = DateComponents()
        let abc = 1
        dateCom.month = +abc
        let newDate = (Calendar.current as NSCalendar).date(byAdding: dateCom, to: date, options: NSCalendar.Options.matchStrictly)
        return newDate!
    }
    
    /// 当月的天数
    ///
    /// - Parameter date: 日期
    /// - Returns: 天数
    class func daysInCurrMonth(date: Date) -> Int {
        let days: NSRange = (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date)
        return days.length
    }
    
    /// 当前月份的第一天是周几
    ///
    /// - Parameter date: 当前日期
    /// - Returns: 周几
    class func firstDayIsWeekInMonth(date: Date) -> Int {
        var calender = Calendar.current
        calender.firstWeekday = 1
        var com = (calender as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: date)
        com.day = 1
        let firstDay = calender.date(from: com)
        let firstWeek = (calender as NSCalendar).ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfMonth, for: firstDay!)
        return firstWeek - 1
    }
    
    /// 当前月份的几号
    ///
    /// - Parameter date: 当前日期
    /// - Returns: 几号
    class func day(_ date: Date) -> Int {
        let com = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: date)
        return com.day!
    }
    
    /// 当前月份
    ///
    /// - Parameter date: 当前日期
    /// - Returns: 几月
    class func month(_ date: Date) -> Int {
        let com = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: date)
        return com.month!
    }
    
    /// 当前星期
    ///
    /// - Parameter date: 当前日期
    /// - Returns: 星期几
    class func week(_ date: Date) -> Int {
        let com = (Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.weekday], from: date)
        return com.weekday!
    }
    
    
    /// 返回中文 星期几
    /// - Parameter week: 日历获取星期下标[1,2,3,4,5,6,7] -> [星期天, 星期一, ... 星期六]
    /// - Returns: 星期几
    class func week_Zh_CN(_ week: Int) -> String {
        
        if week > 8 || week < 1 {
            return "没有对应星期"
        }
        
        return ["星期天", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"][week - 1]
    }
    
    
    /// 返回中文 月份
    /// - Parameter month: 月份下标
    /// - Returns: 几月
    class func month_Zh_CN(_ month: Int) -> String {
        
        if month > 12 || month < 1 {
            return "没有对应月份"
        }
        
        return ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"][month - 1]
    }
}
