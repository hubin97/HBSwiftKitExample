//
//  DatePickerController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/11.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

//MARK: - global var and methods

//MARK: - main class
class DatePickerController: BaseViewController {

    lazy var datePicker: Wto_DatePicker = {
        let datePicker = Wto_DatePicker.init(frame: CGRect(x: 0, y: 50, width: kScreenWidth, height: 250))
        datePicker.datePickerMode = .year_week
        //datePicker.isSelectDecs = true
        return datePicker
    }()
        
    override func setupUi() {
        super.setupUi()

        self.title = "日期选择器"
        
        view.addSubview(datePicker)
        datePicker.layer.borderColor = UIColor.red.cgColor
        datePicker.layer.borderWidth = 1
        datePicker.reloadAllComponents()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneDateAction))
    }
}

//MARK: - private mothods
extension DatePickerController {
    
}

//MARK: - call backs
extension DatePickerController {
    
    @objc func doneDateAction() {
        
        let dateIndex = datePicker.dateIndex
        print("\(dateIndex.year), \(dateIndex.month), \(dateIndex.day), \(dateIndex.week)")
        print("\(datePicker.weekdates(year: dateIndex.year)[dateIndex.weekIndex])")
    }
}

//MARK: - delegate or data source
extension DatePickerController {
    
}

//MARK: - other classes
