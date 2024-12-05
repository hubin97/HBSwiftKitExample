//
//  LTCalendar.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/30.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
protocol LTCalendarDelegate: AnyObject {
    /// 选中的月份 `yyyy-MM-dd`, `date 为选中的日期, 如果没有选择, 则为当天的上月`
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectMonth date: Date)
    /// 选中的周 `yyyy-MM-dd`, `date 为选中的日期, 如果没有选择, 则为当天的上周`
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectWeek date: Date)
    /// 选中的日期 `yyyy-MM-dd`, `date 为选中的日期`
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectDay date: Date)
    /// 样式切换
    func calendarDidChangeDisplayStyle(style: LTCalendar.DisplayStyle)
}

extension LTCalendarDelegate {
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectMonth date: Date) {}
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectWeek date: Date) {}
    func calendarDidChangeDisplayStyle(style: LTCalendar.DisplayStyle) {}
}

// MARK: - main class
class LTCalendar: UIView {
    
    enum DisplayStyle {
        /// 周视图, `simple样式, 无切换`
        case week
        /// 月视图, `detail样式, 无切换`
        case month
        
        /// 简略样式, 显示当前周
        case simple
        /// 详细样式, 显示当前月
        case detail
    }

    weak var delegate: LTCalendarDelegate?
    
    /// 标记日期数组
    var dotArray = [String]() {
        didSet {
            self.detailWeekView.dotArray = dotArray
            self.calendarView.dotArray = dotArray
        }
    }
    
    /// 选中日期
    var selectedDate = Date() {
        didSet {
            self.detailWeekView.selectedDate = selectedDate
            self.calendarView.selectedDate = selectedDate
        }
    }
    
    /// 主题配置
    var themeConfig: LTCalendarThemeConfig = LTCalendarThemeConfig() {
        didSet {
            self.detailWeekView.themeConfig = themeConfig
            self.calendarView.themeConfig = themeConfig
        }
    }
    
    /// 限制最小日期为 5年前
    //private var minLimitDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
    // 改为 5年前的1月1日起
    private var minLimitDate = Date().getJanuaryFirst(offsetYears: -5)

    /// 限制最大日期为 当前日期
    private var maxLimitDate = Date()
    
    // MARK: - UI
    /// 显示样式
    var displayStyle: DisplayStyle = .simple
  
    private lazy var dropView: UIView = {
        let _dropView = UIView()
        _dropView.isUserInteractionEnabled = true
        _dropView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
        return _dropView
    }()
    
    // MARK: 简略视图
    /// 简略视图容器
    private lazy var simpleContrainer: UIView = {
        let _container = UIView()
        return _container
    }()
                       
    lazy var detailWeekView: LTDetailWeekView = {
        let _detailWeekView = LTDetailWeekView()
        _detailWeekView.delegate = self
        return _detailWeekView
    }()
    
    private lazy var simpleBottomLine = UIImageView(image: R.image.icon_calendar_arrow_down())
    
    // MARK: 详细视图
    /// 详细视图容器
    private lazy var detailContrainer: UIView = {
        let _container = UIView()
        return _container
    }()
    
    lazy var calendarView: LTCalendarView = {
        let _calendarView = LTCalendarView()
        _calendarView.delegate = self
        return _calendarView
    }()
    
    private lazy var detailBottomLine = UIImageView(image: R.image.icon_calendar_arrow_down()?.verticalFlip())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(simpleContrainer)
        self.simpleContrainer.addSubview(detailWeekView)
        self.simpleContrainer.addSubview(simpleBottomLine)

        self.addSubview(detailContrainer)
        self.detailContrainer.addSubview(calendarView)
        self.detailContrainer.addSubview(detailBottomLine)

        self.addSubview(dropView)
        
        self.dropView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        self.simpleContrainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        self.detailWeekView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
        }
        self.simpleBottomLine.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }
        self.detailContrainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        self.calendarView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
        }
        self.detailBottomLine.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    /// 初始化
    /// - Parameters:
    ///   - displayStyle: 显示样式
    ///   - limitDateRange: 限制日期范围
    convenience init(displayStyle: DisplayStyle = .simple, limitDateRange: (Date, Date)? = nil) {
        self.init()
        let defaultDateRange = (minLimitDate, maxLimitDate)
        let dateRange = limitDateRange ?? defaultDateRange
        let minDate = Calendar.current.startOfDay(for: dateRange.0)
        let maxDate = Calendar.current.startOfDay(for: dateRange.1)
        
        self.calendarView.limitDateRange = (minDate, maxDate)
        self.detailWeekView.limitDateRange = (minDate, maxDate)

        self.updateDisplayStyle(displayStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension LTCalendar {
    
    func updateDisplayStyle(_ style: DisplayStyle) {
        self.displayStyle = style
        switch style {
        case .week:
            self.simpleContrainer.isHidden = false
            self.detailContrainer.isHidden = true
            self.dropView.isHidden = true
            self.simpleBottomLine.isHidden = true
            self.detailWeekView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()//.inset(30)
            }
            self.detailContrainer.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
            self.simpleContrainer.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .month:
            self.simpleContrainer.isHidden = true
            self.detailContrainer.isHidden = false
            self.dropView.isHidden = true
            self.detailBottomLine.isHidden = true
            self.calendarView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()//.inset(30)
            }
            self.simpleContrainer.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
            self.detailContrainer.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .simple:
            self.simpleContrainer.isHidden = false
            self.detailContrainer.isHidden = true
            self.detailContrainer.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
            self.simpleContrainer.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .detail:
            self.simpleContrainer.isHidden = true
            self.detailContrainer.isHidden = false
            self.simpleContrainer.snp.remakeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
            self.detailContrainer.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 是否为当前月或者当前周
    func isThisMonthOrWeek(_ date: Date) -> Bool {
        switch displayStyle {
        case .week, .simple:
            return detailWeekView.isThisWeek(with: date)
        case .month, .detail:
            return calendarView.isThisMonth(with: date)
        }
    }
   
    // 回到今天
    func scrollToToday() {
        switch displayStyle {
        case .week, .simple:
            detailWeekView.scrollToToday()
        case .month, .detail:
            calendarView.scrollToToday()
        }
    }
}

// MARK: - call backs
extension LTCalendar { 
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        switch displayStyle {
        case .simple:
            updateDisplayStyle(.detail)
            calendarView.reloadCalendar()
        case .detail:
            updateDisplayStyle(.simple)
            detailWeekView.reloadCalendar()
        default:
            break
        }
        delegate?.calendarDidChangeDisplayStyle(style: displayStyle)
    }
}

// MARK: - LTCalendarViewDelegate
extension LTCalendar: LTCalendarViewDelegate, LTDetailWeekViewDelegate {
    
    func calendarView(_ calendarView: LTCalendarView, didSelectMonth date: Date) {
        // 月 -> 周, 需要更新选中周
        self.detailWeekView.refDate = calendarView.refDate
        delegate?.calendar(displayStyle, didSelectMonth: date)
    }
    
    func calendarView(_ calendarView: LTCalendarView, didSelectDay date: Date) {
        self.detailWeekView.selectedDate = date
        delegate?.calendar(displayStyle, didSelectDay: date)
    }

    func weekView(_ calendarView: LTDetailWeekView, didSelectWeek date: Date) {
        // 周 -> 月 考虑跨月问题
        self.calendarView.refDate = calendarView.refDate
        delegate?.calendar(displayStyle, didSelectWeek: date)
    }
    
    func weekView(_ calendarView: LTDetailWeekView, didSelectDay date: Date) {
        // 周 -> 月 考虑跨月问题
        self.calendarView.selectedDate = date
        delegate?.calendar(displayStyle, didSelectDay: date)
    }
}
