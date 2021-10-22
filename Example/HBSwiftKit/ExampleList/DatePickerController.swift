//
//  DatePickerController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/11.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

// MARK: - global var and methods

// MARK: - main class
class DatePickerController: BaseViewController {

    lazy var datePicker: MTDatePicker = {
        let datePicker = MTDatePicker.init(frame: CGRect(x: 15, y: kScreenH - kBottomSafeHeight - 250 - kNavBarAndSafeHeight, width: kScreenW - 30, height: 250))
        datePicker.datePickerMode = .year_week
        // datePicker.isSelectDecs = true
        datePicker.showiOS14SelectedBgColor = false
        return datePicker
    }()

    override func setupUi() {
        super.setupUi()

        self.title = "日期选择器"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneDateAction))

        view.addSubview(datePicker)
        datePicker.center = view.center

        datePicker.reloadAllComponents()
        datePicker.setRoundCorners(borderColor: .brown, borderWidth: 2, raddi: 5, isDotted: true)

        // "乘积C的第m行第n列的元素等于矩阵A的第m行的元素与矩阵B的第n列对应元素乘积之和。"
        let textlabel = UILabel.init(text: "乘积C的第m行第n列的元素等于矩阵A的第m行的元素与矩阵B的第n列对应元素乘积之和。", textColor: .orange, lineBreakMode: .byCharWrapping, numberLines: 0, lineSpacing: 10)
        view.addSubview(textlabel)
        textlabel.frame = CGRect(x: 15, y: 10, width: kScreenW - 30, height: 75)
        textlabel.setRoundCorners()

        let w = textlabel.estimatedWidth(maxHeight: 30)
        print("w:\(w)")

        let h = textlabel.estimatedHeight(maxWidth: kScreenW - 30)
        print("h:\(h)")

        /// 渐变色
        let colorView = UIView.init(frame: CGRect(x: 50, y: 100, width: 100, height: 100))
        view.addSubview(colorView)
        colorView.setGradientColor(colors: [.red, .yellow, .blue], locations: [NSNumber(value: 0), NSNumber(value: 0.7), NSNumber(value: 0.97)], direction: .LeftTop_to_RightBottom)
    }
}

// MARK: - private mothods
extension DatePickerController {

}

// MARK: - call backs
extension DatePickerController {

    @objc func doneDateAction() {

        let dateIndex = datePicker.dateIndex
        print("\(dateIndex.year), \(dateIndex.month), \(dateIndex.day), \(dateIndex.week)")
        print("\(datePicker.weekdates(year: dateIndex.year)[dateIndex.weekIndex])")
    }
}

// MARK: - delegate or data source
extension DatePickerController {

}

// MARK: - other classes
