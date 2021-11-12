//
//  HSVPickerView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/11/11.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit
import WebKit
import Kingfisher
import ObjectMapper

///// - Parameter param: {"hue": 0-360, "saturation": 0-254}
//struct InputColor {
//    var hue: Int
//    var saturation: Int
//}
//
///// - Parameter param: {"hue":305,"saturation":140,"isTouchEnd":true,"rgba":[255,0,233.75,0.5526608614492055]}
//struct OutputColor {
//    var hue: Int
//    var saturation: Int
//    var isTouchEnd: Bool
//    var rgba: [Float]
//}

class InputColor: Mappable {
    required init?(map: Map) { }
    func mapping(map: Map) {
        hue <- map["hue"]
        saturation <- map["saturation"]
    }
    var hue: Int?
    var saturation: Int?

    init() {}
    convenience init(hue: Int, saturation: Int) {
        self.init()
        self.hue = hue
        self.saturation = saturation
    }
}

class OutputColor: Mappable {
    required init?(map: Map) { }
    func mapping(map: Map) {
        hue <- map["hue"]
        saturation <- map["saturation"]
        isTouchEnd <- map["isTouchEnd"]
        rgba <- map["rgba"]
    }
    var hue: Int?
    var saturation: Int?
    var isTouchEnd: Bool?
    var rgba: [Float]?

    init() {}
    convenience init(hue: Int, saturation: Int, isTouchEnd: Bool? = true, rgba: [Float]? = nil) {
        self.init()
        self.hue = hue
        self.saturation = saturation
        self.isTouchEnd = isTouchEnd
        self.rgba = rgba
    }
}

// MARK: - global var and methods
protocol HSVPickerViewDelegate: AnyObject {
    func hsvColorResult(color: OutputColor, duration: Int)
}

// MARK: - main class
class HSVPickerView: UIView {

    weak var delegate: HSVPickerViewDelegate?

    // 设置默认渐变时间, 默认1
    var defaultDuration: Int? {
        didSet {
            timeView.value = defaultDuration ?? 1
        }
    }
    var defaultHsv: InputColor?

    private var setTime: Int = 1
    private var colorParam: OutputColor?

    lazy var toolView: CMToolView = {
        let _toolView = CMToolView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        _toolView.delegate = self
        return _toolView
    }()

    lazy var timeView: DurationView = {
        let timeView = DurationView.init(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.width, height: 55))
        timeView.delegate = self
        return timeView
    }()

    lazy var wkConfig: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration.init()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        let script = WKUserScript.init(source: "WINGTO_NATIVE.js", injectionTime: .atDocumentStart, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        let js_source = "document.documentElement.style.webkitTouchCallout='none';" + "document.documentElement.style.webkitUserSelect='none';"
        let userScript = WKUserScript.init(source: js_source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(userScript)
        return config
    }()

    lazy var wkWebView: WKWebView = {
        let _wkWebView = WKWebView.init(frame: CGRect(x: 0, y: self.timeView.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width - self.timeView.frame.maxY), configuration: wkConfig)
        _wkWebView.navigationDelegate = self
        _wkWebView.scrollView.bounces = false
        _wkWebView.scrollView.showsHorizontalScrollIndicator = false
        _wkWebView.scrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            _wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        return _wkWebView
    }()

    /// 点击空白处是否可以取消, 默认 false
    var isTapMaskHide: Bool = false

    var maskingView = UIView()
    var contentView = UIView()
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override init(frame: CGRect) {
        super.init(frame: UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds)
        blurEffectView.effect = UIBlurEffect(style: .light)
        if #available(iOS 10, *) {
            blurEffectView.effect = UIBlurEffect(style: .prominent)
            if #available(iOS 13, *) {
                blurEffectView.effect = UIBlurEffect(style: .systemMaterialLight)
            }
        }
        addSubview(maskingView)
        maskingView.frame = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
        maskingView.backgroundColor = UIColor.init(white: 0, alpha: 0.2) // 同系统蒙层
        maskingView.addSubview(contentView)
        maskingView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(maskTapAction(_:))))

        contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - UIScreen.main.bounds.width - kBottomSafeHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + kBottomSafeHeight)
        contentView.addSubview(blurEffectView)
        contentView.backgroundColor = .white
        contentView.addSubview(toolView)
        contentView.addSubview(timeView)
        contentView.addSubview(wkWebView)

        // renderColorWheel("http://192.168.2.70:8080/hsvColorPicker.html?platform=ios")
        renderColorWheel()
        addMethod(name: "WINGTO_NATIVE")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeMethod(name: "WINGTO_NATIVE")
    }
}

// MARK: - private mothods
extension HSVPickerView: WKScriptMessageHandler {

    // Native invoke Js
    func evaluateJs(jsCode: String, completeBlock: ((_ result: Any?, _ error: Error?) -> Void)?) {
        self.wkWebView.evaluateJavaScript(jsCode) { (result, error) in
            completeBlock?(result, error)
        }
    }

    // Js invoke Native
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // print("message==>", message.body, message.name)
        guard let msg = message.body as? String, let dict = msg.data(using: .utf8)?.toDict() else { return }
        guard let methodname = dict["method"] as? String else { return }
        var selectorName = methodname
        var param: [String: Any]?
        if let value = dict["data"] as? [String: Any] {
            selectorName = "\(methodname):"
            param = value
        }
        // print("method=> \(selectorName), param =>\(param?.toJSONString() ?? "")")
        let selector = NSSelectorFromString(selectorName)
        if self.responds(to: selector) {
            self.perform(selector, with: param)
        }
    }

    // MARK: -
    func addMethod(name: String) {
        self.wkWebView.configuration.userContentController.add(self, name: name)
    }

    func removeMethod(name: String) {
        self.wkWebView.configuration.userContentController.removeScriptMessageHandler(forName: name)
    }

    // MARK: -
    // local load
    func renderColorWheel() {
        // html?platform=ios https://blog.csdn.net/lrbtony/article/details/114373443
        // NSURL *htmlURL = [NSURL URLWithString:@"#/vuepath" relativeToURL:baseURL]; https://www.jianshu.com/p/42b254dd2a96
        guard let htmlpath = Bundle.main.path(forResource: "hsvColorPicker", ofType: "html", inDirectory: "resource") else { return }
        let baseUrl = URL(fileURLWithPath: htmlpath)
        // let lastUrl = URL(fileURLWithPath: "?platform=ios", relativeTo: baseUrl)
        // 本地html追加参数 https://stackoverflow.com/questions/8286099/how-to-pass-arguments-to-fileurl
        let lastUrl = URL(string: "file://\(baseUrl.path)?platform=ios")
        wkWebView.load(URLRequest(url: lastUrl!))
    }

    @objc func onJsReady() {
        DDLogDebug("onJsReady----")
        //self.setColor(param: ["hue": 0, "saturation": 254])
        self.setColor(param: defaultHsv?.toJSON() ?? InputColor(hue: 0, saturation: 0).toJSON())
    }

    /// 设置默认颜色
    /// - Parameter param: {"hue": 0-360, "saturation": 0-254}
    func setColor(param: [String: Any]) {
        self.evaluateJs(jsCode: "WINGTO_H5.onSetHsvColor('\(param.toJSONString() ?? "")')") { result, error in
            print("result:\(result ?? ""), error:\(error?.localizedDescription ?? "")")
        }
    }

    /// 回调颜色更新
    /// - Parameter param: {"hue":305,"saturation":140,"isTouchEnd":true,"rgba":[255,0,233.75,0.5526608614492055]}
    @objc func onHsvColorPicker(_ param: [String: Any]) {
        DDLogDebug("onHsvColorPicker.\(param.toJSONString() ?? "")")
        colorParam = Mapper<OutputColor>().map(JSON: param)
    }
}

// MARK: - call backs
extension HSVPickerView {

    public func show() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
            self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + kBottomSafeHeight)
            UIView.animate(withDuration: 0.3) {
                self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - UIScreen.main.bounds.width - kBottomSafeHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + kBottomSafeHeight)
            }
        }
    }

    public func hide() {
        DispatchQueue.main.async {
            self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - UIScreen.main.bounds.width - kBottomSafeHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + kBottomSafeHeight)
            UIView.animate(withDuration: 0.3) {
                self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + kBottomSafeHeight)
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }

    @objc func maskTapAction(_ tap: UITapGestureRecognizer) {
        let tap_point = tap.location(in: self)
        let isincontent = self.contentView.frame.contains(tap_point)
        // 无操作键可点击蒙层移除, 点不在contentView上
        if self.isTapMaskHide && isincontent == false {
            hide()
        }
    }
}

// MARK: - delegate or data source
extension HSVPickerView: CMToolViewDelegate, DurationViewDelegate {

    func cancelAction() {
        hide()
    }

    func confirAction() {
        hide()
        delegate?.hsvColorResult(color: colorParam ?? OutputColor(hue: 0, saturation: 0), duration: setTime)
    }

    func resultAction(duration: Int) {
        setTime = duration
    }
}

// MARK: - delegate or data source
extension HSVPickerView: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStart render color wheel")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish render color wheel")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail; error:\(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation; error:\(error.localizedDescription)")
    }
}

// MARK: - CMToolView
protocol CMToolViewDelegate: AnyObject {
    func cancelAction()
    func confirAction()
}

class CMToolView: UIView {

    weak var delegate: CMToolViewDelegate?
    lazy var cancelBtn: UIButton = {
        let _cancelBtn = UIButton.init(type: .custom)
        _cancelBtn.frame = CGRect(x: 10, y: 0, width: 60, height: self.bounds.height)
        _cancelBtn.setTitle("取消", for: .normal)
        _cancelBtn.setTitleColor(.lightGray, for: .normal)
        _cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return _cancelBtn
    }()

    lazy var confirBtn: UIButton = {
        let _confirBtn = UIButton.init(type: .custom)
        _confirBtn.frame = CGRect(x: self.bounds.width - 70, y: 0, width: 60, height: self.bounds.height)
        _confirBtn.setTitle("确认", for: .normal)
        _confirBtn.setTitleColor(.systemBlue, for: .normal)
        _confirBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _confirBtn.addTarget(self, action: #selector(confirAction), for: .touchUpInside)
        return _confirBtn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(cancelBtn)
        addSubview(confirBtn)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //
    @objc func cancelAction() {
        delegate?.cancelAction()
    }

    @objc func confirAction() {
        delegate?.confirAction()
    }
}

// MARK: - DurationView
protocol DurationViewDelegate: AnyObject {
    func resultAction(duration: Int)
}

class DurationView: UIView {

    var value: Int? {
        didSet {
            if let duration = value {
                valueLabel.text = "\(duration)s"
            }
        }
    }

    weak var delegate: DurationViewDelegate?

    lazy var titleLabel: UILabel = {
        let _titleLabel = UILabel.init(frame: CGRect(x: 20, y: 0, width: 80, height: self.bounds.height))
        _titleLabel.text = "渐变时间"
        _titleLabel.font = UIFont.systemFont(ofSize: 16)
        return _titleLabel
    }()

    lazy var topLineView: UIView = {
        let _topLineView = UIView.init(frame: CGRect(x: 20, y: 0, width: self.bounds.width - 20, height: 1))
        _topLineView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        return _topLineView
    }()

    lazy var bottomLineView: UIView = {
        let _bottomLineView = UIView.init(frame: CGRect(x: 20, y: self.bounds.height - 1, width: self.bounds.width - 20, height: 1))
        _bottomLineView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        return _bottomLineView
    }()

    lazy var borderView: UIView = {
        let _borderView = UIView.init(frame: CGRect(x: self.bounds.width - 115, y: 11, width: 100, height: 33))
        _borderView.setRoundCorners(borderColor: UIColor(hexStr: "#979797", alpha: 0.3), borderWidth: 0.5)
        return _borderView
    }()

    // 100 *32
    lazy var minBtn: UIButton = {
        let _minBtn = UIButton.init(type: .custom)
        _minBtn.frame = CGRect(x: 0, y: 0, width: borderView.bounds.height, height: borderView.bounds.height)
        _minBtn.setTitle("-", for: .normal)
        _minBtn.setTitleColor(.black, for: .normal)
        _minBtn.setTitleColor(.lightGray, for: .disabled)
        _minBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _minBtn.addTarget(self, action: #selector(minAction), for: .touchUpInside)
        return _minBtn
    }()

    lazy var addBtn: UIButton = {
        let _addBtn = UIButton.init(type: .custom)
        _addBtn.frame = CGRect(x: borderView.bounds.width - borderView.bounds.height, y: 0, width: borderView.bounds.height, height: borderView.bounds.height)
        _addBtn.setTitle("+", for: .normal)
        _addBtn.setTitleColor(.black, for: .normal)
        _addBtn.setTitleColor(.lightGray, for: .disabled)
        _addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        return _addBtn
    }()

    lazy var valueLabel: UILabel = {
        let _valueLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: borderView.bounds.height, height: borderView.bounds.height))
        _valueLabel.centerX = borderView.bounds.width/2
        _valueLabel.text = "1s"
        _valueLabel.textColor = .black
        _valueLabel.textAlignment = .center
        _valueLabel.font = UIFont.systemFont(ofSize: 16)
        return _valueLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(topLineView)
        addSubview(bottomLineView)
        addSubview(borderView)
        borderView.addSubview(minBtn)
        borderView.addSubview(addBtn)
        borderView.addSubview(valueLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //
    @objc func minAction() {
        guard let value = valueLabel.text?.components(separatedBy: "s").first, let num = Int(value), num > 0 else { return }
        minBtn.isEnabled = ((num - 1) > 0)
        addBtn.isEnabled = ((num - 1) < 10)
        valueLabel.text = "\(num - 1)s"
        delegate?.resultAction(duration: num - 1)
    }

    @objc func addAction() {
        guard let value = valueLabel.text?.components(separatedBy: "s").first, let num = Int(value), num < 10 else { return }
        minBtn.isEnabled = ((num + 1) > 0)
        addBtn.isEnabled = ((num + 1) < 10)
        valueLabel.text = "\(num + 1)s"
        delegate?.resultAction(duration: num + 1)
    }
}
