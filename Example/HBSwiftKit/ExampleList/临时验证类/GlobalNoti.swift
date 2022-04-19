//
//  GlobalNoti.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

class GlobalNoti: NSObject {

    var globalNotiBlock: ((_ noti: Notification) -> Void)?

    func register(name: NSNotification.Name?, object: Any? = nil, receiveNoti: ((_ noti: Notification) -> Void)?) {
        self.globalNotiBlock = receiveNoti
        NotificationCenter.default.addObserver(self, selector: #selector(notiHandle(_:)), name: name, object: object)
    }

    static func post(name: NSNotification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }

    func remove(name: NSNotification.Name, object: Any? = nil) {
        NotificationCenter.default.removeObserver(self, name: name, object: object)
    }

    @objc func notiHandle(_ noti: Notification) {
        self.globalNotiBlock?(noti)
    }
}
