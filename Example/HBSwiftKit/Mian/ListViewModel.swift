//
//  ListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
// MARK: - global var and methods

// MARK: - main class
class ListViewModel: ViewModel {
    
    enum RowType: Int, CaseIterable {
        case imageBrower = 0
        case calendar
        case datePicker
        case numberPicker
        case blueTooth
        case easyAdScroll
        case mapLocation
        case videoTest
        case mqtt
        case mediaList
        case routerTest

        var title: String {
            switch self {
            case .imageBrower:
                return "图片浏览器"
            case .calendar:
                return "日历"
            case .datePicker:
                return "日期选择器"
            case .numberPicker:
                return "数字选择器"
            case .blueTooth:
                return "蓝牙"
            case .easyAdScroll:
                return "广告轮播"
            case .mapLocation:
                return "地图定位"
            case .videoTest:
                return "视频测试"
            case .mediaList:
                return "媒体列表"
            case .mqtt:
                return "MQTT"
            case .routerTest:
                return "路由测试"
            }
        }
    }
    
    let items: [RowType] = RowType.allCases
}
