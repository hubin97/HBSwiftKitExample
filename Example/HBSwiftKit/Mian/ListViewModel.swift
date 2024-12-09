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
    let items: [DemoRowModel] = [DemoRowModel(title: "照片浏览器", dclass: ImageBrowerController()),
                                 DemoRowModel(title: "日历选择器", dclass: CalendarController()),
                                 DemoRowModel(title: "日期选择器", dclass: DatePickerController()),
                                 DemoRowModel(title: "数字选择器", dclass: NumberPickerController()),
                                 DemoRowModel(title: "蓝牙测试页", dclass: BlueToothController()),
                                 DemoRowModel(title: "标题轮播页", dclass: EasyAdScrollController()),
                                 DemoRowModel(title: "地图定位页", dclass: MapLocationController()),
                                 DemoRowModel(title: "视频剪辑页", dclass: VideoTestController()),
                                 DemoRowModel(title: "视频播放页", dclass: VideoPlayController()),
                                 DemoRowModel(title: "MQTT", dclass: MQTTTestController()),
                                 DemoRowModel(title: "Podcast", dclass: PodCastListController()),
                                ]
    
}

// MARK: - other classes
class DemoRowModel {

    var title: String?
    var `class`: ViewController?

    init() {
    }

    convenience init(title: String?, dclass: ViewController?) {
        self.init()
        self.title = title
        self.class = dclass
    }
}
