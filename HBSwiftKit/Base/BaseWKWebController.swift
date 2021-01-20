//
//  BaseWKWebController.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2020/12/4.
//  Copyright © 2020 Hubin_Huang All rights reserved.

import Foundation
import WebKit

//MARK: - global var and methods
//1. 加载区分本地/远端的url
//2. 监听加载进度,可定制
//3. JS交互规格标准
//4. 代理回调处理???

//MARK: - main class
open class BaseWKWebController: BaseViewController {

    /// 指定远端地址
    public var remoteUrl: String?
    /// 指定本地地址
    public var localPath: String?

    /// 特定配置
    public lazy var wkConfig: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration.init()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        //config.preferences.allowsContentJavaScript = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        let js_source = "document.documentElement.style.webkitTouchCallout='none';" + "document.documentElement.style.webkitUserSelect='none';"
        let userScript = WKUserScript.init(source: js_source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(userScript)
        return config
    }()
    
    /// 容器
    public lazy var wkWebView: WKWebView = {
        let wkWebView = WKWebView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - kNavBarAndSafeHeight), configuration: self.wkConfig)
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        return wkWebView
    }()
    
    open override func setupUi() {
        super.setupUi()
        view.addSubview(self.wkWebView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 远端
        if let remoteUrl = remoteUrl {
            wkWebView.load(URLRequest(url: URL(string: remoteUrl)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0))
        }
        
        // 本地
        if let localPath = localPath {
            let mainpath = URL.init(fileURLWithPath: Bundle.main.bundlePath)
            guard let htmlpath = Bundle.main.path(forResource: localPath, ofType: nil) else { return }
            guard let html = try? String.init(contentsOfFile: htmlpath, encoding: .utf8) else { return }
            wkWebView.loadHTMLString(html, baseURL: mainpath)
        }
    }
}

//MARK: - private mothods
extension BaseWKWebController {
    
}

//MARK: - call backs
extension BaseWKWebController {
    
}

//MARK: - delegate or data source
extension BaseWKWebController: WKUIDelegate, WKNavigationDelegate {
 
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webView#didStart--\(webView.title ?? "")")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView#didFinish--\(webView.title ?? "")")
        self.title = webView.title
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webView#didFail--")
    }
}

//MARK: - other classes
