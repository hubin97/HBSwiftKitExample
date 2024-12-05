//
//  WebPreviewController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h@wingto.cn on 2020/12/4.
//  Copyright © 2020 云图数字 All rights reserved.

import Foundation
import WebKit

// MARK: - global var and methods

// MARK: - main class
class WebPreviewController: WKWebController {

    override func setupLayout() {
        super.setupLayout()
        self.naviBar.title = "Web Preview"

        self.progressViewBackColor = .systemBlue
        self.progressViewTintColor = .red
        self.progressViewHeight = 1
        self.wkWebView.frame = CGRect(x: 0, y: kNavBarAndSafeHeight, width: self.view.bounds.width, height: self.view.bounds.height - kNavBarAndSafeHeight - kBottomSafeHeight)
        // self.wkWebView.navigationDelegate = self
        self.addMethod(name: "WINGTO_NATIVE") {[weak self] (methodname, callback) in
            print("scriptName:\(methodname), callback:\(callback)")
            if let tmp_content = callback as? [String: String], let method = tmp_content.value(forKey: "title") as? String {
                // OC反射
                // @objc(userContentController:didReceiveScriptMessage:)
                let selector = NSSelectorFromString(method)
                if self?.responds(to: selector) == true {
                    // self?.perform(selector)
                    // self?.perform(selector, with: tmp_content.value(forKey: "content"))
                    self?.perform(selector, with: tmp_content.value(forKey: "content"), with: tmp_content.value(forKey: "content"))
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.naviBar.leftView?.isHidden = true

        // self.localPath = "jstest.html"
        //loadHTML(urlString: "jstest.html", isLocalHtml: true)
        loadWeb(urlPath: "jstest.html", isLocalHtml: true)
        //load(urlPath: "https://www.baidu.com")
    }

    // 对应方法名:  "test"
    @objc func test() {
        print("test------")
    }

    // 对应方法名:  "test:"
    @objc func test(_ param: Any) {
        print("test------\(param)")
    }

    // 对应方法名:  "test::"
    // 仅提供最多带2参数? func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>!
    @objc func test(_ param1: Any, _ param2: Any) {
        print("test------1\(param1), 2\(param2)")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
}
