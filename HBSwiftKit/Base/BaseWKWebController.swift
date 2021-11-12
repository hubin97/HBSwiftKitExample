//
//  BaseWKWebController.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2020/12/4.
//  Copyright © 2020 Hubin_Huang All rights reserved.

import Foundation
import WebKit
import CocoaLumberjack

//MARK: - global var and methods
//1. 加载区分本地/远端的url ✅
//2. 监听加载进度,可定制 ✅
//3. JS交互规格标准 ✅
//4. 代理回调处理 ✅
//5. 缓存机制 ?
//

//#1. 若需要支持http,主工程必要ATS配置, 详情参考 https://onevcat.com/2016/06/ios-10-ats/
/**
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     <key>NSAllowsArbitraryLoadsInWebContent</key>
     <true/>
     <key>NSAllowsArbitraryLoadsForMedia</key>
     <true/>
 </dict>
 </plist>
 */

//#2. 白屏问题参考 WKWebView 那些坑 https://mp.weixin.qq.com/s/rhYKLIbXOsUJC_n6dt9UfA?

//#3. Protocol Extensions and Objective-C
/**
 https://www.jianshu.com/p/7fe0b4f8520d
 https://www.jianshu.com/p/cfe7da01880d
 https://stackoverflow.com/questions/39487168/non-objc-method-does-not-satisfy-optional-requirement-of-objc-protocol
 */

//fileprivate typealias MethodName = String
//MARK: - main class
open class BaseWKWebController: BaseViewController, WKWebScriptMsgHandleAble {

    /// 特定配置
    open lazy var wkConfig: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration.init()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        //config.preferences.allowsContentJavaScript = true
        //config.preferences.javaScriptCanOpenWindowsAutomatically = false
        let js_source = "document.documentElement.style.webkitTouchCallout='none';" + "document.documentElement.style.webkitUserSelect='none';"
        let userScript = WKUserScript.init(source: js_source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(userScript)
        return config
    }()
    
    /// 容器
    open lazy var wkWebView: WKWebView = {
        let wkWebView = WKWebView.init(frame: CGRect(x: 0, y: kTopSafeHeight, width: self.view.bounds.width, height: self.view.bounds.height - kTopSafeHeight - kBottomSafeHeight), configuration: self.wkConfig)
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        if #available(iOS 11.0, *) {
            wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return wkWebView
    }()
    
    // ----
    /// 是否显示进度条
    public var showProgress: Bool = true
    /// 进度条背景色
    public var progressViewBackColor: UIColor? {
        didSet {
            progressView.trackTintColor = progressViewBackColor
        }
    }
    /// 进度条填充色
    public var progressViewTintColor: UIColor?  {
        didSet {
            progressView.tintColor = progressViewTintColor
        }
    }
    /// 进度条高度
    public var progressViewHeight: CGFloat? {
        didSet {
            if let height = progressViewHeight {
                let rate = height/progressView.frame.size.height
                progressView.transform = CGAffineTransform.init(scaleX: 1.0, y: rate)
            }
        }
    }
    
    fileprivate lazy var progressView: UIProgressView = {
        ///UIProgressView的高度设置无效, 且 iOS14高度还有变化
        let _progressView = UIProgressView.init(frame: CGRect(x: 0, y: 0, width: self.wkWebView.frame.width, height: 1))
        _progressView.progressViewStyle = .bar
        _progressView.tintColor = .systemBlue
        _progressView.backgroundColor = .lightGray
        _progressView.isHidden = true
        return _progressView
    }()
    
    open override func setupUi() {
        super.setupUi()
        view.addSubview(self.wkWebView)
        view.addSubview(self.progressView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showProgress {
            self.progressView.isHidden = false
            self.wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 白屏问题处理
        if wkWebView.title == nil {
            wkWebView.reload()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if showProgress {
            wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        if let methodName = self.scriptMsgName, methodName.isEmpty == false {
            self.removeMethod(name: methodName)
        }
        ///
        wkWebView.navigationDelegate = nil
        wkWebView.uiDelegate = nil
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
extension BaseWKWebController {}

//MARK: - call backs
extension BaseWKWebController {}

//MARK: - delegate or data source
//MARK: - WKUIDelegate, WKNavigationDelegate
extension BaseWKWebController: WKUIDelegate, WKNavigationDelegate {
    
    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = webView.title
    }

    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progressView.isHidden = true
    }

    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    open func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

extension BaseWKWebController: UIScrollViewDelegate {

    // 调整webview滚动速率
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = .normal //.fast 惯性变小
        //print("wkWebView#scrollViewWillBeginDragging--")
    }
}

//MARK: - WKWebScriptMsgHandleAble
extension BaseWKWebController {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let methodName = self.scriptMsgName, methodName.isEmpty == false else { return }
        if methodName == message.name {
            if let jsHandleBlcok = self.scriptMsgHandleBlock {
                jsHandleBlcok(methodName, message.body)
            } else {
                // 自定义默认反射
                guard let msg = message.body as? String, let dict = msg.data(using: .utf8)?.toDict() else { return }
                guard let method = dict["method"] as? String else { return }
                var selectorName = method
                var param: [String: Any]?
                if let value = dict["data"] as? [String: Any] {
                    selectorName = "\(method):"
                    param = value
                }
                print("method=> \(selectorName), param =>\(param?.toJSONString() ?? "")")
                let selector = NSSelectorFromString(selectorName)
                if self.responds(to:selector) {
                    self.perform(selector, with: param)
                }
            }
        }
    }
}

//MARK: - WKWebScriptMsgHandleAble
public protocol WKWebScriptMsgHandleAble: WKScriptMessageHandler {

    /// Web容器
    var wkWebView: WKWebView { get set }
    /// 特定配置
    var wkConfig: WKWebViewConfiguration { get set }
    /// 加载方式
    func load(urlPath: String, isLocalHtml: Bool, cachePolicy: NSURLRequest.CachePolicy, timeout: TimeInterval)
}

private var scriptMsgNameKey = "scriptMsgNameKey"
private var scriptMsgHandleBlockKey = "scriptMsgHandleBlockKey"
extension WKWebScriptMsgHandleAble {

    /// 指定需要监听的脚本方法名
    var scriptMsgName: String? {
        get {
            return objc_getAssociatedObject(self, &scriptMsgNameKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &scriptMsgNameKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    /// 实现方法监听, 通过Block回调
    var scriptMsgHandleBlock: ((_ action: String, _ param: Any) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &scriptMsgHandleBlockKey) as? ((String, Any) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &scriptMsgHandleBlockKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    /// 加载网页 本地 或是 远端
    public func load(urlPath: String, isLocalHtml: Bool = false, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeout: TimeInterval = 20.0) {
        if isLocalHtml {
            let mainpath = URL.init(fileURLWithPath: Bundle.main.bundlePath)
            guard let htmlpath = Bundle.main.path(forResource: urlPath, ofType: nil) else { return }
            guard let html = try? String.init(contentsOfFile: htmlpath, encoding: .utf8) else { return }
            wkWebView.loadHTMLString(html, baseURL: mainpath)
        } else {
            if let url = URL(string: urlPath) {
                wkWebView.load(URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout))
            }
        }
    }

    /// 消息处理 插入代理 @objc(userContentController:didReceiveScriptMessage:)
//    public func jscriptMsgHandle(message: WKScriptMessage) {
//        print("scriptName:\(message.name)")
//        guard let methodName = self.scriptMsgName, methodName.isEmpty == false else { return }
//        if methodName == message.name {
//            self.scriptMsgHandleBlock?(methodName, message.body)
//        }
//    }
    
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
    
    /// 建议只注册一个标识, 通过配置的参数体区分调用即可
    public func addMethod(name: String) {
        self.scriptMsgName = name
        self.wkConfig.userContentController.add(self, name: name)
    }
    
    /// 回调到外部 message.body可以固定格式: {"action":"xxx","param":{}}
    public func addMethod(name: String, completeBlock: ((_ action: String, _ param: Any) -> ())?) {
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

//https://www.jianshu.com/p/7fe0b4f8520d
//https://stackoverflow.com/questions/39487168/non-objc-method-does-not-satisfy-optional-requirement-of-objc-protocol
//extension WKWebScriptMsgHandleAble where Self: NSObject {
//
//    @objc(userContentController:didReceiveScriptMessage:)
//    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        print("scriptName:\(message.name)")
//        //print("content:\(message.body)")
//        guard let methodName = self.scriptMsgName, methodName.isEmpty == false else { return }
//        if methodName == message.name {
//            //self.scriptMsgHandle(name: methodName, param: message.body)
//            self.scriptMsgHandleBlock?(methodName, message.body)
//        }
//    }
//}
