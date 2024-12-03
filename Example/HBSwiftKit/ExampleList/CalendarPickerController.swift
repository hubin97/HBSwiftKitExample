//
//  CalendarPickerController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/8/29.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

// MARK: - global var and methods

// MARK: - main class
class CalendarPickerController: ViewController {

    let calendar = Wto_Calendar.init()

    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "日历选择器"

        view.addSubview(calendar)
        calendar.layer.borderColor = UIColor.red.cgColor
        calendar.layer.borderWidth = 1

        // self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addDateAction))
    }
}

// MARK: - private mothods
extension CalendarPickerController {

}

// MARK: - call backs
extension CalendarPickerController {

    @objc func addDateAction() {
        // Wto_Calendar.ii
    }
}

// MARK: - delegate or data source
extension CalendarPickerController {

}

// MARK: - other classes
