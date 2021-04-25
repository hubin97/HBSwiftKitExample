//
//  WebPreviewController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/4.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import WebKit

//MARK: - global var and methods

//MARK: - main class
class WebPreviewController: BaseWKWebController {

    override func setupUi() {
        super.setupUi()
        self.navigationItem.title = "Web Preview"
        //self.remoteUrl = "https://www.baidu.com" //"https://space.bilibili.com/325538782"
        //self.remoteUrl = "http://172.16.1.139/smarthome/ythomesdk-ios"
        self.remoteUrl = "http://192.168.2.70:8080"

        //self.localPath = "jstest.html"
        self.progressViewBackColor = .systemBlue
        self.progressViewTintColor = .red
        //self.wkWebView.navigationDelegate = self
        self.addMethod(name: "WINGTO") {[weak self] (methodname, content) in
            print("scriptName:\(methodname), content:\(content)")
            
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
    
    //open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        
        self.evaluateJs(jsCode: "onSwithChange()", completeBlock: { (result, error) in
            print("evaluateJs#result:\(result ?? ""), error:\(error?.localizedDescription ?? "")")
        })

    }
}

//MARK: - other classes
