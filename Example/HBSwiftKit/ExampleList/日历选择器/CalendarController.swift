//
//  CalendarController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/29.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

// MARK: - global var and methods

// MARK: - main class
class CalendarController: ViewController {

    // 主题配置
//    private let themeConfig = LTCalendarThemeConfig(
//        textNormalColor: Colors.thinBlack,
//        textSelectedColor: .white,
//        textDisableColor: Colors.thinGray,
//        itemBackgroundColor: .clear,
//        selectedBackgroundColor: Colors.main,
//        todayBackgroundColor: .clear, //Colors.main.withAlphaComponent(0.1),
//        todayTextColor: Colors.thinBlack, // Colors.main,
//        dotColor: Colors.main,
//        textNormalFont: Fonts.medium14,
//        textSelectedFont: Fonts.medium17
//    )

    private lazy var calendar: LTCalendar = {
        let _calendar = LTCalendar(displayStyle: .month)
//        _calendar.themeConfig = themeConfig
        _calendar.delegate = self
        return _calendar
    }()

    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "日历选择器"
        self.view.addSubview(calendar)
        self.calendar.layer.borderColor = UIColor.red.cgColor
        self.calendar.layer.borderWidth = 1

        self.calendar.snp.makeConstraints { make in
            make.top.equalTo(naviBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - private mothods
extension CalendarController {

}

// MARK: - call backs
extension CalendarController {

    @objc func addDateAction() {
        // Wto_Calendar.ii
    }
}

    // MARK: - LTCalendarDelegate
extension CalendarController: LTCalendarDelegate {
    
    /// 回到今天的显示规则如下:
    /// 仅当 本月或本周, 并且是当天 不显示
    ///
    func showBackToday(with date: Date) -> Bool {
        // 如果date为refDate会有问题; 如 10/31, 滑到9月, 9月小, 再滑回来10月, 10月大, 所以refDate会少一天
//        let selecteDate = self.vm.selectDateRelay.value.format(with: LocalizedUtils.dateFormat_Cloud)
//        return !(calendar.isThisMonthOrWeek(date) && Calendar.current.isDateInToday(selecteDate))
        return false
    }
    
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectMonth date: Date) {
//        self.displayStyle = style
//        self.dateView.showBackTodayButton = showBackToday(with: date)
    }
    
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectWeek date: Date) {
//        self.displayStyle = style
//        self.dateView.showBackTodayButton = showBackToday(with: date)
    }
    
    func calendar(_ style: LTCalendar.DisplayStyle, didSelectDay date: Date) {
//        self.displayStyle = style
//        self.dateView.date = date
//        
//        self.vm.selectDateRelay.accept(date.format(with: LocalizedUtils.dateFormat_Cloud))
//        self.dateView.showBackTodayButton = showBackToday(with: date)
    }
    
    func calendarDidChangeDisplayStyle(style: LTCalendar.DisplayStyle) {
//        self.displayStyle = style
//        // 判断显示的是否是本周或者本月
//        let date = style == .simple ? calendar.calendarView.refDate : calendar.detailWeekView.refDate
//        self.dateView.showBackTodayButton = showBackToday(with: date)
//        
//        // 日历展示样式变更
//        self.vm.calendarDisplayStyleRelay.accept(style)
//        
//        if style == .detail {
//            AnalyticsManager.shared.userBehavior(element: .feed_tool_calendar_expand)
//        }
    }
}
