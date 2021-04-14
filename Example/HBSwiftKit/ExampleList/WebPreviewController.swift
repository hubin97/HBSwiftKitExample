//
//  WebPreviewController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/4.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation

//MARK: - global var and methods

//MARK: - main class
class WebPreviewController: BaseWKWebController {

    override func setupUi() {
        super.setupUi()
        self.title = "Web Preview"
        //self.remoteUrl = "https://www.baidu.com" //"https://space.bilibili.com/325538782"
        self.remoteUrl = "http://172.16.1.139/smarthome/ythomesdk-ios" //"http://192.168.2.70:8080" // //
        //self.localPath = "jstest.html"
        self.progressViewBackColor = .systemBlue
        self.progressViewTintColor = .red
        self.addMethod(name: "ScanAction") {[weak self] (methodname, content) in
            print("methodname:\(methodname), content:\(content)")
            //self?.evaluateJs(jsCode: "1111", completeBlock: nil)
        }
    }
}

//MARK: - private mothods
extension WebPreviewController {
    
}

//MARK: - call backs
extension WebPreviewController {
    
}

//MARK: - delegate or data source
extension WebPreviewController {
    
}

//MARK: - other classes
