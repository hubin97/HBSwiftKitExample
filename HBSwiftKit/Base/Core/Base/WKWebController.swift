//
//  WKWebController.swift
//  Momcozy
//
//  Created by hubin.h on 2023/11/13.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import UIKit
import WebKit

// MARK: - global var and methods

// MARK: - main class
open class WKWebController: ViewController, WKWebScriptMsgHandleAble {

    // 退出web容器返回回调
    public var exitWebBlock: (() -> Void)?
    
    //
    public var wkMethodName: String?
    public var wkReceiveDataBlock: WKReceiveBlock?
    
    /// 是否使用web页标题 `仅控制首次加载, 若是页面重定向或者页面跳转, 标题跟随web页变更`
    private var useWebTitle: Bool = true

    private var urlPath: String? {
        didSet {
            if let urlPath = urlPath {
                // print("HTML_PATH>> \(urlPath)")
                self.loadWeb(urlPath: urlPath)
            }
        }
    }
    
    /// 特定配置
    public lazy var wkConfig: WKWebViewConfiguration = {
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
    @objc // !!!!: 必要的
    public lazy var wkWebView: WKWebView = {
        let wkWebView = WKWebView.init(frame: CGRect(x: 0, y: kNavBarAndSafeHeight, width: kScreenW, height: kScreenH - kNavBarAndSafeHeight), configuration: self.wkConfig)
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
    public var progressViewTintColor: UIColor? {
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
    
    var titleObervation: NSKeyValueObservation?
    var progressObervation: NSKeyValueObservation?

    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        _backButton.setImage(UIImage.bundleImage(named: "icon_back")?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return _backButton
    }()
    
    lazy var closeButton: UIButton = {
        let _closeButton = UIButton(type: .custom)
        _closeButton.frame = CGRect(x: view.isRTL ? 0: 44, y: 0, width: 44, height: 44)
        _closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: view.isRTL ? 0: -10, bottom: 0, right: view.isRTL ? -10: 0)
        _closeButton.setImage(UIImage.bundleImage(named: "icon_close")?.adaptRTL, for: .normal)
        _closeButton.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        return _closeButton
    }()
  
    lazy var naviLeftView: UIView = {
        let _naviLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 88, height: 44))
        _naviLeftView.addSubview(self.backButton)
        _naviLeftView.addSubview(self.closeButton)
        return _naviLeftView
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.naviBar.setLeftView(self.backButton)
        self.view.addSubview(self.wkWebView)
        self.view.addSubview(self.progressView)
        
        self.view.backgroundColor = .white
        self.wkWebView.navigationDelegate = self
        self.progressViewHeight = 1
        self.progressViewTintColor = .systemBlue
        
        self.addObserver()

//        self.wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
//        self.wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
//        self.wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 白屏问题处理
        if self.wkWebView.title == nil {
            self.wkWebView.reload()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.titleObervation = nil
        self.titleObervation?.invalidate()
        self.progressObervation = nil
        self.progressObervation?.invalidate()

        self.wkWebView.navigationDelegate = nil
        self.wkWebView.uiDelegate = nil
    }
    
    @objc open func backAction(_ sender: UIButton) {
        if self.wkWebView.canGoBack {
            self.wkWebView.goBack()
            // 规避毒瘤页面无法返回的问题 (始终返回 canGoBack:true)
            self.updateBackForwardState()
        } else {
            super.backAction()
            self.exitWebBlock?()
        }
    }
    
    @objc open func closeAction(_ sender: UIButton) {
        super.backAction()
        self.exitWebBlock?()
    }
    
    open override func popGestureAction() {
        self.exitWebBlock?()
    }
    
    // 如果返回历史记录不为空, 则显示关闭按钮
    // https://www.facebook.com/groups/momcozyusercenter?utm_source=user+center&utm_medium=app&utm_campaign=app-banner&Language=zh-CN
    func updateBackForwardState() {
        let isLast = self.wkWebView.backForwardList.backList.isEmpty
        if !view.isRTL {
            self.naviBar.setLeftView(isLast ? self.backButton: self.naviLeftView)
        }
    }
}

// MARK: - private mothods
extension WKWebController {
    
    func addObserver() {
        self.progressObervation = self.observe(\.wkWebView.estimatedProgress, options: [.old, .new]) {[weak self] (_, change) in
            let newValue: Float = Float(change.newValue ?? 0)
            let oldValue: Float = Float(change.oldValue ?? 0)
            guard let ws = self, newValue > oldValue && newValue > 0.1 else { return }
            print("newValue>>\(newValue)")
            ws.progressView.isHidden = false
            ws.progressView.setProgress(newValue, animated: true)
            if newValue >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut) {
                    ws.progressView.isHidden = true
                } completion: { finish in
                    if finish {
                        ws.progressView.setProgress(0.0, animated: false)
                    }
                }
            }
        }
        
        self.titleObervation = self.observe(\.wkWebView.title, options: [.old, .new], changeHandler: {[weak self] (_, change) in
            guard let ws = self, let title = change.newValue else { return }
            print("Title changed: \(title ?? "")")
            if ws.useWebTitle {
                ws.naviBar.title = title
            }
        })
    }

    /// 加载网页 本地 或是 远端
    public func loadWeb(urlPath: String, isLocalHtml: Bool = false, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeout: TimeInterval = 20.0) {
        print("LOAD_HTML_PATH>> \(urlPath)")
        if isLocalHtml {
            let mainpath = URL(fileURLWithPath: Bundle.main.bundlePath)
            guard let htmlpath = Bundle.main.path(forResource: urlPath, ofType: nil) else { return }
            guard let html = try? String.init(contentsOfFile: htmlpath, encoding: .utf8) else { return }
            wkWebView.loadHTMLString(html, baseURL: mainpath)
        } else {
            if let url = URL(string: urlPath) {
                wkWebView.load(URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout))
            }
        }
    }
    
    public func setUrlPath(_ urlPath: String) {
        self.urlPath = urlPath
    }
    
    public func setTitle(_ title: String?) {
        if let title = title {
            self.useWebTitle = false
            self.naviBar.title = title
        }
    }
}

// MARK: - call backs
extension WKWebController: UIScrollViewDelegate {
    
    // 调整webview滚动速率
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.decelerationRate = .normal //.fast 惯性变小
        //print("wkWebView#scrollViewWillBeginDragging--")
    }
}

// MARK: - WKWebScriptMsgHandleAble
extension WKWebController {
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let methodName = self.wkMethodName, methodName.isEmpty == false && methodName == message.name else { return }
        if let jsHandleBlcok = self.wkReceiveDataBlock {
            jsHandleBlcok(methodName, message.body)
        } else {
            // 自定义默认反射
            guard let msg = message.body as? String, let dict = msg.data?.dict else { return }
            guard let method = dict["method"] as? String else { return }
            var selectorName = method
            var param: [String: Any]?
            if let value = dict["data"] as? [String: Any] {
                selectorName = "\(method):"
                param = value
            }
            print("method=> \(selectorName), param =>\(param?.string ?? "")")
            let selector = NSSelectorFromString(selectorName)
            if self.responds(to:selector) {
                self.perform(selector, with: param)
            }
        }
    }
}

// MARK: - delegate or data source
extension WKWebController: WKUIDelegate, WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.useWebTitle {
            self.naviBar.title = webView.title
        }
        self.updateBackForwardState()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progressView.isHidden = true
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webView:didFailProvisionalNavigation: \(error.localizedDescription)")
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

// MARK: - WKWebScriptMsgHandleAble
public protocol WKWebScriptMsgHandleAble: WKScriptMessageHandler {
    
    typealias WKReceiveBlock = ((_ action: String, _ param: Any) -> Void)
    
    /// Web容器
    var wkWebView: WKWebView { get set }
    /// 特定配置
    var wkConfig: WKWebViewConfiguration { get set }
    
    /// 指定需要监听的脚本方法名
    var wkMethodName: String? { get set }
    /// 实现方法监听, 通过Block回调
    var wkReceiveDataBlock: WKReceiveBlock? { get set }
}

extension WKWebScriptMsgHandleAble {

    /// JS注入回调
    /// - Parameters:
    ///   - jsCode: js代码字符串
    ///   - completeBlock: 回调
    /// - Returns: block
    public func evaluateJs(jsCode: String, completeBlock: ((_ result: Any?, _ error: Error?) -> Void)?) {
        self.wkWebView.evaluateJavaScript(jsCode) { (result, error) in
            completeBlock?(result, error)
        }
    }
    
    /// 建议只注册一个标识, 通过配置的参数体区分调用即可
    public func addMethod(name: String) {
        self.wkMethodName = name
        self.wkConfig.userContentController.add(self, name: name)
    }
    
    /// 回调到外部 message.body可以固定格式: {"action":"xxx","param":{}}
    public func addMethod(name: String, completeBlock: ((_ action: String, _ param: Any) -> Void)?) {
        self.wkReceiveDataBlock = completeBlock
        self.addMethod(name: name)
    }
    
    public func removeMethod(name: String) {
        self.wkConfig.userContentController.removeScriptMessageHandler(forName: name)
    }
    
    public func removeAllMethods() {
        self.wkConfig.userContentController.removeAllUserScripts()
    }
}
