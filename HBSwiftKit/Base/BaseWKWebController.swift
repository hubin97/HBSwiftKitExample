//
//  BaseWKWebController.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2020/12/4.
//  Copyright © 2020 Hubin_Huang All rights reserved.

import Foundation
import WebKit

//MARK: - global var and methods
//1. 加载区分本地/远端的url ✅
//2. 监听加载进度,可定制 ✅
//3. JS交互规格标准
//4. 代理回调处理???

//fileprivate typealias MethodName = String
//MARK: - main class
open class BaseWKWebController: BaseViewController {

    /// 指定远端地址
    public var remoteUrl: String?
    /// 指定本地地址
    public var localPath: String?
    /// 指定需要监听的脚本方法名
    public var scriptMsgName: String?
    private var scriptMsgHandleBlock: ((_ name: String, _ param: Any) -> ())?
    
    /// 是否显示进度条
    public var showProgress: Bool = true
    public var progressViewBackColor: UIColor? {
        didSet {
            progressView.trackTintColor = progressViewBackColor
        }
    }
    public var progressViewTintColor: UIColor?  {
        didSet {
            progressView.tintColor = progressViewTintColor
        }
    }

    fileprivate lazy var progressView: UIProgressView = {
        let progressView = UIProgressView.init(frame: CGRect(x: 0, y: self.wkWebView.frame.minY, width: self.wkWebView.frame.width, height: 2))
        progressView.tintColor = .systemBlue
        progressView.backgroundColor = .lightGray
        progressView.isHidden = true
        return progressView
    }()
    
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
        view.addSubview(self.progressView)
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
        if showProgress {
            self.progressView.isHidden = false
            self.wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
//        if let methodName = self.scriptMsgName, methodName.isEmpty == false {
//            self.addMethod(name: methodName)
//        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if showProgress {
            wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        if let methodName = self.scriptMsgName, methodName.isEmpty == false {
            self.removeMethod(name: methodName)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.isHidden = false
            self.progressView.setProgress(Float(self.wkWebView.estimatedProgress), animated: true)
            if self.wkWebView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.isHidden = true
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
}

//MARK: - private mothods
extension BaseWKWebController {
    
    /// JS注入回调
    /// - Parameters:
    ///   - jsCode: js代码字符串
    ///   - completeBlock: 回调
    /// - Returns: block
    public func evaluateJs(jsCode: String, completeBlock: ((_ result: Any?, _ error: Error?) -> ())?) {
        self.wkWebView.evaluateJavaScript(jsCode) { (result, error) in
            completeBlock?(result, error)
        }
    }
    
    public func addMethod(name: String) {
        self.scriptMsgName = name
        self.wkConfig.userContentController.add(self, name: name)
    }
    
    public func addMethod(name: String, completeBlock: ((_ name: String, _ param: Any) -> ())?) {
        self.scriptMsgHandleBlock = completeBlock
        self.addMethod(name: name)
    }
    
    public func removeMethod(name: String) {
        self.wkConfig.userContentController.removeScriptMessageHandler(forName: name)
    }
    
    public func removeAllMethods() {
        self.wkConfig.userContentController.removeAllUserScripts()
    }
}

//MARK: - call backs
extension BaseWKWebController {
    
    /// 回调到外部 message.body可以固定格式: {"methodname":"xxx","callback":{}}
    /// - Parameters:
    ///   - name: 指定监听方法名(scriptMsgName)
    ///   - param: message.body回调内容
    public func scriptMsgHandle(name: String, param: Any) {
        //print("scriptMsgHandle--\(param)")
        self.scriptMsgHandleBlock?(name, param)
    }
}

//MARK: - delegate or data source
//MARK: - WKUIDelegate, WKNavigationDelegate
extension BaseWKWebController: WKUIDelegate, WKNavigationDelegate {
 
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webView#didStart--\(webView.title ?? "")")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView#didFinish--\(webView.title ?? "")")
        self.navigationItem.title = webView.title
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webView#didFail--")
    }
}

//MARK: - WKScriptMessageHandler
extension BaseWKWebController: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("method name:\(message.name)")
        //print("content:\(message.body)")
        guard let methodName = self.scriptMsgName, methodName.isEmpty == false else { return }
        if methodName == message.name {
            self.scriptMsgHandle(name: methodName, param: message.body)
        }
    }
}

//MARK: - other classes
