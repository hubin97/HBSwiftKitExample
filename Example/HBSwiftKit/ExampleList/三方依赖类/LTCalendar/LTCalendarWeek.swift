//
//  LTWeekView.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/30.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - LTSimpleWeekView
class LTSimpleWeekView: UIView {
    
    private let textColor: UIColor = UIColor(hexStr: "#666666")
    private let textFont: UIFont = UIFont.systemFont(ofSize: kScaleW(12), weight: .medium)
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(weeks: [String], containerW: CGFloat = kScreenW, padding: CGFloat = 0) {
        self.init()
        
        let itemW = (containerW - CGFloat(weeks.count - 1) * padding) / CGFloat(weeks.count)
        
        for (index, week) in weeks.enumerated() {
            let label = UILabel()
            label.text = week
            label.textAlignment = .center
            label.font = textFont
            label.textColor = textColor
            self.addSubview(label)
            
            label.snp.makeConstraints { (make) in
                make.width.equalTo(itemW)
                make.top.equalToSuperview()//.offset(5)
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview().offset(CGFloat(index) * (itemW + padding))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - LTDetailWeekViewDelegate
protocol LTDetailWeekViewDelegate: AnyObject {
    /// 选中的月份 `yyyy-MM`
    func weekView(_ calendarView: LTDetailWeekView, didSelectWeek date: Date)
    /// 选中的日期 `yyyy-MM-dd`
    func weekView(_ calendarView: LTDetailWeekView, didSelectDay date: Date)
}

// MARK: - LTDetailWeekView
class LTDetailWeekView: UIView {
    
    weak var delegate: LTDetailWeekViewDelegate?
    
    /// 边距
    private let margin: CGFloat = 10
    private let padding: CGFloat = 5
    private let itemHeight: CGFloat = 40

    /// 星期数组:  周日 周一 周二 周三 周四 周五 周六
    private let weeks: [String] = CalendarData.weeks

    /// 当前标记点数组 Array<String>  yyyy-MM-dd, 得匹配日期那一天
    var dotArray = [String]() {
        didSet {
            self.setupWeeks()
        }
    }
    
    /// 限制日期范围
    var limitDateRange: (Date, Date)? {
        didSet {
            self.setupWeeks()
        }
    }

    /// 限制范围外是否可滚动查看, 默认不可滚动
    var isOutLimitScrollable: Bool = false

    // MARK: UI
    /// 主题配置
    var themeConfig: LTCalendarThemeConfig = LTCalendarThemeConfig()

    /// 参考日期, 初始默认今天
    var refDate = Date() {
        didSet {
            self.setupWeeks()
        }
    }
    
    /// 选中日期
    var selectedDate: Date = Date() {
        willSet {
            // 清空旧值, 设置新值
            if let lastIndexPath = self.weekMetas.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate)  }).map({ IndexPath(row: $0, section: 0) }) {
                self.weekMetas[lastIndexPath.row].state = Calendar.current.isDateInToday(selectedDate) ? .today : .normal
                self.calendarCollection.reloadItems(at: [lastIndexPath])
            }
        }
        didSet {
            if let indexPath = self.weekMetas.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate)  }).map({ IndexPath(row: $0, section: 0) }) {
                self.weekMetas[indexPath.row].state = .selected
                self.calendarCollection.reloadItems(at: [indexPath])
            }
            
            self.refDate = selectedDate
            //self.setupWeeks()
        }
    }
    
    /// 星期数组元数据
    private(set) var weekMetas: [LTCalendarMeta] = []
    /// 星期视图
    private lazy var weekView = LTSimpleWeekView(weeks: weeks, containerW: kScreenW - 2 * margin, padding: padding)

    /// 日历
    fileprivate lazy var calendarCollection: UICollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.scrollDirection = .horizontal
        
        let _calendarCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: _layout)
        _calendarCollection.backgroundColor = UIColor.clear
        _calendarCollection.dataSource = self
        _calendarCollection.delegate = self
        _calendarCollection.registerCell(LTCalendarItem.self)
        return _calendarCollection
    }()

    private override init(frame: CGRect) {
        super.init(frame: frame)
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
            make.height.equalTo(itemHeight + padding)
            make.bottom.equalToSuperview()
        }
        
        self.setupWeeks()
        self.addSwipeGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LTDetailWeekView {

    private func setupWeeks() {
        self.weekMetas = []
        
        // 1. 获取当前星期
        let datesOfWeek = refDate.datesOfWeek
        
        // 2. 生成星期元数据
        for index in weeks.indices {
            let date = Calendar.current.startOfDay(for: datesOfWeek[index])
            // 比较日期是否在限制范围内
            var state: LTCalendarMeta.DayState = Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .selected : .normal
            if let limitDateRange = limitDateRange {
                if date < limitDateRange.0 || date > limitDateRange.1 {
                    state = .disable
                }
            }
            let isDotShow = dotArray.contains(date.format(with: LocalizedUtils.dateFormat_standard))
            let meta = LTCalendarMeta(date: date, state: state, isDotShow: isDotShow)
            self.weekMetas.append(meta)
        }
        
        self.calendarCollection.reloadData()
    }
    
    func lastWeek() {
        self.refDate = self.refDate.lastWeek
        self.setupWeeks()
        self.delegate?.weekView(self, didSelectWeek: self.refDate)
    }
    
    func nextWeek() {
        self.refDate = self.refDate.nextWeek
        self.setupWeeks()
        self.delegate?.weekView(self, didSelectWeek: self.refDate)
    }
    
    func scrollToToday() {
        self.refDate = Date()
        self.setupWeeks()
        self.selectedDate = Date()
        self.delegate?.weekView(self, didSelectDay: self.refDate)
    }
    
    /// 是否是当前周
    /// - Parameter date: 传入的日期
    /// - Returns: 是否是当前周
    func isThisWeek(with date: Date) -> Bool {
//        let datesOfWeek = Date().datesOfWeek
//        let isThisWeek = datesOfWeek.first(where: { Calendar.current.isDate($0, inSameDayAs: date) }) != nil
//        return isThisWeek
        return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekday)
    }
    
    /// 刷新日历
    func reloadCalendar() {
        self.weekMetas.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }).map({ $0.state = .selected })
        self.calendarCollection.reloadData()
    }
}

// MARK: - private mothods
extension LTDetailWeekView {
    
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
            // 判断下周第一天是否还在范围内
            if !isOutLimitScrollable && !isInLimitRangeOfNextWeek() {
                return
            }
            self.nextWeek()
        } else if sender.direction == .right {
            // 判断上周最后一天是否还在范围内
            if !isOutLimitScrollable && !isInLimitRangeOfLastWeek() {
                return
            }
            self.lastWeek()
        }
    }
    
    /// 上周最后一天是否还在范围内
    func isInLimitRangeOfLastWeek() -> Bool {
        let lastWeekLastDay = self.weekMetas.first?.date.lastDay ?? Date()
        if let limitDateRange = limitDateRange {
            if lastWeekLastDay < limitDateRange.0 || lastWeekLastDay > limitDateRange.1 {
                return false
            }
        }
        return true
    }
    
    /// 下周第一天是否还在范围内
    func isInLimitRangeOfNextWeek() -> Bool {
        let nextWeekFirstDay = self.weekMetas.last?.date.nextDay ?? Date()
        if let limitDateRange = limitDateRange {
            if nextWeekFirstDay < limitDateRange.0 || nextWeekFirstDay > limitDateRange.1 {
                return false
            }
        }
        return true
    }
    
    /// 下周第一天是否是  `相对今天的下个月`
//    func isNextMonthWeekDay() -> Bool {
//        let nextWeekFirstDay = self.weekMetas.last?.date.nextDay ?? Date()
//        if nextWeekFirstDay.year > Date().year || (nextWeekFirstDay.year == Date().year && nextWeekFirstDay.month > Date().month) {
//            return true
//        }
//        return false
//    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LTDetailWeekView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weekMetas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.getReusableCell(indexPath, LTCalendarItem.self)
        item.themeConfig = self.themeConfig
        item.configure(with: self.weekMetas[indexPath.row])
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let meta = self.weekMetas[indexPath.row]
        // 不可点击, 或者已选中
        if meta.state == .disable || meta.state == .none || meta.state == .selected { return }

        self.refDate = meta.date
        self.selectedDate = meta.date
        self.delegate?.weekView(self, didSelectDay: meta.date)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: margin, bottom: 0, right: margin)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = (collectionView.width - 2 * margin - CGFloat(weeks.count - 1) * padding) / CGFloat(weeks.count)
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
