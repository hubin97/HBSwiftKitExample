//
//  LTCalendarView.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/29.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
protocol LTCalendarViewDelegate: AnyObject {
    /// 选中的月份 `yyyy-MM`
    func calendarView(_ calendarView: LTCalendarView, didSelectMonth date: Date)
    /// 选中的日期 `yyyy-MM-dd`
    func calendarView(_ calendarView: LTCalendarView, didSelectDay date: Date)
}

// MARK: - main class
class LTCalendarView: UIView {
    
    weak var delegate: LTCalendarViewDelegate?
    
    /// 当前标记点数组 Array<String>  yyyy-MM-dd, 得匹配日期那一天
    var dotArray = [String]() {
        didSet {
            self.setupCalendar()
        }
    }
 
    /// 限制日期范围
    var limitDateRange: (Date, Date)? {
        didSet {
            self.setupCalendar()
        }
    }

    /// 限制范围外是否可滚动查看, 默认不可滚动
    var isOutLimitScrollable: Bool = false

    /// 当前月能否查看下个月
    //var isNextMonthVisible: Bool = true

    /// 主题配置
    var themeConfig: LTCalendarThemeConfig = LTCalendarThemeConfig()

    /// 参考日期, 初始默认今天
    var refDate = Date() {
        didSet {
            self.setupCalendar()
        }
    }
    
    /// 选中日期
    var selectedDate: Date = Date() {
        willSet {
            // 清空旧值, 设置新值
            if let lastIndexPath = self.calendarMetas.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate)  }).map({ IndexPath(row: $0, section: 0) }) {
                //self.calendarMetas[lastIndexPath.row].state = .normal
                self.calendarMetas[lastIndexPath.row].state = Calendar.current.isDateInToday(selectedDate) ? .today : .normal
                // 处理旧值时, 需要考虑是否是当前月份
                if !Calendar.current.isDate(selectedDate, equalTo: refDate, toGranularity: .month) {
                    self.calendarMetas[lastIndexPath.row].state = .none
                }
                
                self.calendarCollection.reloadItems(at: [lastIndexPath])
            }
        }
        didSet {
            if let indexPath = self.calendarMetas.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate)  }).map({ IndexPath(row: $0, section: 0) }) {
                self.calendarMetas[indexPath.row].state = .selected
                self.calendarCollection.reloadItems(at: [indexPath])
            }
            
            self.refDate = selectedDate
            //self.setupCalendar()
        }
    }
    
    /// 日历元数据
    private(set) var calendarMetas: [LTCalendarMeta] = []
    
    /// 星期数组:  周日 周一 周二 周三 周四 周五 周六
    private let weeks: [String] = CalendarData.weeks

    /// 边距
    private let margin: CGFloat = 10
    private let padding: CGFloat = 5
    private let itemHeight: CGFloat = 40

    /// 星期视图
    private lazy var weekView = LTSimpleWeekView(weeks: weeks, containerW: kScreenW - 2 * margin, padding: padding)
    
    // FIXME: 最少 5 行; 最多可能 6 行,  2024 - 6
//    private lazy var layout: UICollectionViewFlowLayout = {
//        let itemWidth: CGFloat = bounds.width
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: kScaleW(36), height: kScaleW(36))
//        layout.minimumLineSpacing = margin
//        layout.minimumInteritemSpacing = margin
//        return layout
//    }()
    
    /// 日历
    fileprivate lazy var calendarCollection: UICollectionView = {
        let _calendarCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        _calendarCollection.backgroundColor = UIColor.clear
        _calendarCollection.dataSource = self
        _calendarCollection.delegate = self
        _calendarCollection.registerCell(LTCalendarItem.self)
        return _calendarCollection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.backgroundColor = .white
        self.addSubview(weekView)
        self.addSubview(calendarCollection)
        
        self.weekView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(margin)
            make.height.equalTo(20)
        }
        self.calendarCollection.snp.makeConstraints { make in
            make.top.equalTo(weekView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(215)
            make.bottom.equalToSuperview()
        }
        
        self.setupCalendar()
        self.addSwipeGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension LTCalendarView {
    
    /// 日历更新
    private func setupCalendar() {
        // 清空数据
        self.calendarMetas.removeAll()
        
        // 1. 计算当月日历 绘制的 item 数量
        var itemCounts = refDate.daysInMonth + refDate.firstWeekday
        let rows = itemCounts % 7 == 0 ? itemCounts / 7 : itemCounts / 7 + 1
        itemCounts = rows * 7
        
        // 2. 计算上个月, 当月和下个月的天数
        let lastMonthDays = refDate.firstWeekday
        let currentMonthDays = refDate.daysInMonth
        let nextMonthDays = itemCounts - lastMonthDays - currentMonthDays
        
        // 3. 生成日历元数据
        // 上个月
        if lastMonthDays > 0 {
            //print("上月日期-----")
            Array(0..<lastMonthDays).reversed().forEach { offset_day in
                let dayOfLastMonth = self.refDate.lastMonth.firstDayOfMonth
                if let date = Calendar.current.date(bySetting: .day, value: dayOfLastMonth.daysInMonth - offset_day, of: dayOfLastMonth) {
                    self.calendarMetas.append(LTCalendarMeta(date: date, state: .normal, isDotShow: false))
                    //print(date.format())
                }
            }
        }
        
        // 当前月
        //print("当月日期-----")
        Array(0..<currentMonthDays).forEach { offset_day in
            let firstDayOfMonth = self.refDate.firstDayOfMonth
            if let date = Calendar.current.date(bySetting: .day, value: offset_day + 1, of: firstDayOfMonth) {
                self.calendarMetas.append(LTCalendarMeta(date: date, state: .normal, isDotShow: false))
                //print(date.format())
            }
        }
        
        // 下个月
        if nextMonthDays > 0 {
            //print("下月日期-----")
            Array(1...nextMonthDays).forEach { offset_day in
                let dayOfNextMonth = self.refDate.nextMonth.firstDayOfMonth
                if let date = Calendar.current.date(bySetting: .day, value: offset_day, of: dayOfNextMonth) {
                    self.calendarMetas.append(LTCalendarMeta(date: date, state: .normal, isDotShow: false))
                    //print(date.format())
                }
            }
        }

        // 4. 更新日历元数据状态
        self.calendarMetas.forEach { meta in
            let date = Calendar.current.startOfDay(for: meta.date)
            meta.state = Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .selected : .normal
            meta.state = Calendar.current.isDateInToday(date) ? .today : meta.state
            // 不是当前月的日期
//            if !Calendar.current.isDate(date, equalTo: refDate, toGranularity: .month) {
//                meta.state = .disable
//            }
            // 是上个月 或 是下个月
            if date < refDate.firstDayOfMonth || date > refDate.lastDayOfMonth {
                meta.state = .none
            }
            
            // 限制日期范围外的日期
            if let limitDateRange = limitDateRange {
                if date < limitDateRange.0 || date > limitDateRange.1 {
                    meta.state = .disable
                }
            }
            
            meta.isDotShow = dotArray.contains(date.format(with: "yyyy-MM-dd"))
        }
 
        self.calendarCollection.reloadData()
        
        // 更新高度 下一个事件循环周期开始时执行;
        DispatchQueue.main.async {
            self.calendarCollection.layoutIfNeeded()
            self.updateCalendarHeight()
        }
    }
    
    // 更新高度约束
    func updateCalendarHeight() {
        // 计算 gridCollection 的高度
        let height = calendarCollection.collectionViewLayout.collectionViewContentSize.height + padding
        // print("height: \(height)")
        self.calendarCollection.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}

extension LTCalendarView {
    
    /// 添加滑动手势
    func addSwipeGestureRecognizer() {
        // 创建左滑手势识别器
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        self.addGestureRecognizer(leftSwipe)
        
        // 创建右滑手势识别器
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        self.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            // 判断下月第一天是否还在范围内
            if !isOutLimitScrollable && !isInLimitRangeOfNextMonth() {
                return
            }
            self.nextMonth()
        } else if sender.direction == .right {
            // 判断上月最后一天是否还在范围内
            if !isOutLimitScrollable && !isInLimitRangeOfLastMonth() {
                return
            }
            self.lastMonth()
        }
    }
    
    /// 上月最后一天是否还在范围内
    func isInLimitRangeOfLastMonth() -> Bool {
        let lastWeekLastDay = self.calendarMetas.first?.date.lastDay ?? Date()
        if let limitDateRange = limitDateRange {
            if lastWeekLastDay < limitDateRange.0 || lastWeekLastDay > limitDateRange.1 {
                return false
            }
        }
        return true
    }
    
    /// 下周第一天是否还在范围内
    func isInLimitRangeOfNextMonth() -> Bool {
        let nextWeekFirstDay = self.calendarMetas.last?.date.nextDay ?? Date()
        if let limitDateRange = limitDateRange {
            if nextWeekFirstDay < limitDateRange.0 || nextWeekFirstDay > limitDateRange.1 {
                return false
            }
        }
        return true
    }
}

// MARK: - call backs
extension LTCalendarView {
    
    func lastMonth() {
        self.refDate = refDate.lastMonth
        self.setupCalendar()
        self.delegate?.calendarView(self, didSelectMonth: self.refDate)
    }
    
    func nextMonth() {
        self.refDate = refDate.nextMonth
        self.setupCalendar()
        self.delegate?.calendarView(self, didSelectMonth: self.refDate)
    }
    
    func scrollToToday() {
        self.refDate = Date()
        self.setupCalendar()
        self.selectedDate = Date()
        self.delegate?.calendarView(self, didSelectDay: self.refDate)
    }
    
    /// 是否是当前月份
    /// - Parameter date: 传入的日期
    /// - Returns: 是否是当前月份
    func isThisMonth(with date: Date) -> Bool {
        return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    /// 刷新日历
    func reloadCalendar() {
        self.calendarMetas.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }).map({ $0.state = .selected })
        self.calendarCollection.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LTCalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendarMetas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.getReusableCell(indexPath, LTCalendarItem.self)
        item.themeConfig = self.themeConfig
        item.configure(with: self.calendarMetas[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meta = self.calendarMetas[indexPath.row]
        
        // 不可点击, 或者已选中
        if meta.state == .disable /*|| meta.state == .none*/ || meta.state == .selected { return }

        // 点击过去时间, 但是并非当前月份时, 先切换月份到选中月
        if meta.state == .none {
            if meta.date < refDate.firstDayOfMonth {
                self.lastMonth()
            } else {
                self.nextMonth()
            }
            //return
        }
        
        self.refDate = meta.date
        self.selectedDate = meta.date
        self.delegate?.calendarView(self, didSelectDay: meta.date)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: margin, bottom: 0, right: margin)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = (collectionView.width - 2 * margin - CGFloat(weeks.count - 1) * padding) / CGFloat(weeks.count)
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
