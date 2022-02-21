//
//  LightAttrPickerView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/11/11.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit
import WebKit
import Kingfisher
import ObjectMapper
import CocoaLumberjack

// MARK: - Models
class XYColor: Mappable {
    required init?(map: Map) { }
    func mapping(map: Map) {
        curXY <- map["curXY"]
        isTouchEnd <- map["isTouchEnd"]
        rgba <- map["rgba"]
    }
    var curXY: String?  // XYColor(curXY: "22056 22256")
    var isTouchEnd: Bool?
    var rgba: [CGFloat]?

    init() {}
    convenience init(curXY: String?, isTouchEnd: Bool? = nil, rgba: [CGFloat]? = nil) {
        self.init()
        self.curXY = curXY
        self.isTouchEnd = isTouchEnd
        self.rgba = rgba
    }
}

class HsvColor: Mappable {
    required init?(map: Map) { }
    func mapping(map: Map) {
        hue <- map["hue"]
        saturation <- map["saturation"]
        isTouchEnd <- map["isTouchEnd"]
        rgba <- map["rgba"]
    }
    var hue: Int?  // 角度 0~360
    var saturation: Int? // 饱和 0~254
    var isTouchEnd: Bool?
    var rgba: [CGFloat]?

    init() {}
    convenience init(hue: Int, saturation: Int, isTouchEnd: Bool? = nil, rgba: [CGFloat]? = nil) {
        self.init()
        self.hue = hue
        self.saturation = saturation
        self.isTouchEnd = isTouchEnd
        self.rgba = rgba
    }
}

class DPTemp: Mappable {
    required init?(map: Map) { }
    func mapping(map: Map) {
        colorType <- map["colorType"]
        color <- map["color"]
        templature <- map["templature"]
        isTouchEnd <- map["isTouchEnd"]
        rgb <- map["rgb"]
    }
    var colorType: Int?  // 区分上下限 0:默认2700~6500 1: 榜威灯2000~6500
    var color: String?
    var templature: Int?
    var isTouchEnd: Bool?
    var rgb: [CGFloat]?

    init() {}
    convenience init(colorType: Int? = nil, color: String? = nil, templature: Int, isTouchEnd: Bool? = nil, rgb: [CGFloat]? = nil) {
        self.init()
        self.colorType = colorType
        self.color = color
        self.templature = templature
        self.isTouchEnd = isTouchEnd
        self.rgb = rgb
    }
}

// MARK: - global var and methods
protocol LightPickerViewDelegate: AnyObject {
    func xyColorResult(duration: Int?, color: XYColor)
    func hsvColorResult(duration: Int?, color: HsvColor)
    func colorTempResult(duration: Int?, temp: DPTemp)
    func brightResult(duration: Int?, bright: Int?)
}

extension LightPickerViewDelegate {
    func xyColorResult(duration: Int?, color: XYColor) {}
    func hsvColorResult(duration: Int?, color: HsvColor) {}
    func colorTempResult(duration: Int?, temp: DPTemp) {}
    func brightResult(duration: Int?, bright: Int?) {}
}

// MARK: - main class
class LightAttrPickerView: UIView {

    /// 可选样式 xy色值/ hsv色值/ 色温/ 亮度
    enum ModeType {
        case xy
        case hsv
        case temp
        case brightness
    }

    var callBackXy: ((_ duration: Int?, _ color: XYColor) -> Void)?
    var callBackHsv: ((_ duration: Int?, _ color: HsvColor) -> Void)?
    var callBackTemp: ((_ duration: Int?, _ temp: DPTemp) -> Void)?
    var callBackBright: ((_ duration: Int?, _ bright: Int?) -> Void)?

    weak var delegate: LightPickerViewDelegate?

    var modeType = ModeType.brightness

    /// 点击空白处是否可以取消, 默认 false
    var isTapMaskHide: Bool = false

    private var contentHeight: CGFloat = 0
    /// 设置默认渐变时间, 默认1
    private var transitionTime: Int = 1
    /// hsv色值模型
    private var hsvColorParam: HsvColor?
    private var xyColorParam: XYColor?
    /// 色温模型
    private var tempParam: DPTemp?
    /// 初始值
    private let initXYColor = XYColor(curXY: "22056 22256")
    private let initHSVColor = HsvColor(hue: 0, saturation: 0)
    private let initTemp = DPTemp(color: "0xFCDBC0", templature: 4600)

    private var selectedIndex: Int = 0
    /// 设置默认亮度值
    var brightness: String? {
        didSet {
            guard brightness != nil else { return }
            for index in 0..<(self.pickerDatas.count) where self.pickerDatas[index] == self.brightness {
                self.selectedIndex = index
                self.dataPicker.selectRow(index, inComponent: 0, animated: false)
                self.dataPicker.reloadAllComponents()
                break
            }
        }
    }

    /// 亮度数据源
    var pickerDatas = [String]() {
        didSet {
            self.dataPicker.reloadAllComponents()
            self.pickerView(self.dataPicker, didSelectRow: 0, inComponent: 0)
        }
    }

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

    /// hsv
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

    /// brightness
    lazy var dataPicker: UIPickerView = {
        let height = kScaleW(240)
        let y = self.timeView.frame.maxY + (contentView.bounds.height - kBottomSafeHeight - self.timeView.frame.maxY - height)/2
        let _datePicker = UIPickerView.init(frame: CGRect(x: 0, y: y, width: contentView.bounds.width, height: height))
        _datePicker.dataSource = self
        _datePicker.delegate = self
        return _datePicker
    }()

    ///
    lazy var maskingView: UIView = {
        let _maskingView = UIView.init(frame: UIScreen.main.bounds)
        _maskingView.backgroundColor = UIColor.init(white: 0, alpha: 0.2) // 同系统蒙层
        _maskingView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(maskTapAction(_:))))
        return _maskingView
    }()

    lazy var contentView: UIView = {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - UIScreen.main.bounds.width - kBottomSafeHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width + kBottomSafeHeight)
        let _contentView = UIView.init(frame: frame)
        _contentView.backgroundColor = .white
        return _contentView
    }()

    lazy var blurEffectView: UIView = {
        let _blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        _blurEffectView.effect = UIBlurEffect(style: .light)
        if #available(iOS 10, *) {
            _blurEffectView.effect = UIBlurEffect(style: .prominent)
            if #available(iOS 13, *) {
                _blurEffectView.effect = UIBlurEffect(style: .systemMaterialLight)
            }
        }
        return _blurEffectView
    }()

    private override init(frame: CGRect) {
        super.init(frame: UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds)
        addSubview(maskingView)
        maskingView.addSubview(contentView)
        contentView.addSubview(blurEffectView)
        contentView.addSubview(toolView)
        contentView.addSubview(timeView)
    }

    /// picker 初始化
    /// - Parameters:
    ///   - mode: 展示样式
    ///   - hasTimeView: 是否有过渡时间栏
    ///   - duration: 时间
    ///   - brightness: 默认亮度
    ///   - brightnessValues: 所有亮度值
    ///   - tempValue: 默认色温模型
    ///   - xyColor: 默认xy颜色模型
    ///   - hsvColor: 默认hsv颜色模型
    private convenience init(mode: ModeType, hasTimeView: Bool = true, duration: Int = 1, brightness: String? = nil, brightnessValues: [String]? = nil, tempValue: DPTemp? = nil, xyColor: XYColor? = nil, hsvColor: HsvColor? = nil) {
        self.init()
        self.modeType = mode
        self.transitionTime = duration
        self.brightness = brightness
        self.pickerDatas = brightnessValues ?? []
        self.xyColorParam = xyColor
        self.hsvColorParam = hsvColor
        self.tempParam = tempValue
        self.timeView.value = duration
        self.contentHeight = self.contentView.frame.height
        if !hasTimeView {
            self.contentHeight -= self.timeView.frame.height
            self.timeView.bounds = CGRect.zero
            self.timeView.isHidden = true
        }
        if mode == .brightness {
            self.contentHeight -= kScaleW(30)
            let height = kScaleW(240)
            let y = self.timeView.frame.maxY + (self.contentHeight - kBottomSafeHeight - self.timeView.frame.maxY - height)/2
            self.dataPicker.frame = CGRect(x: 0, y: y, width: contentView.bounds.width, height: height)
        } else {
            let y = self.toolView.frame.height + self.timeView.frame.height
            let h = self.contentHeight - kBottomSafeHeight - y
            self.wkWebView.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: h)
        }
        self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.contentHeight, width: UIScreen.main.bounds.width, height: self.contentHeight)
        self.contentHeight = self.contentView.frame.height

        if mode == .xy || mode == .hsv {
            self.contentView.addSubview(wkWebView)
            self.addMethod(name: "WINGTO_NATIVE")
            self.renderColorValueWheel()
        } else if mode == .temp {
            self.contentView.addSubview(wkWebView)
            self.addMethod(name: "WINGTO_NATIVE")
            self.renderTempValueWheel()
        } else if mode == .brightness {
            self.contentView.addSubview(dataPicker)
        }
    }

    /// 亮度筛选框
    convenience init(brightness: String, brightnessValues: [String], duration: Int = 1, hasTimeView: Bool = true) {
        self.init(mode: .brightness, hasTimeView: hasTimeView, duration: duration, brightness: brightness, brightnessValues: brightnessValues)
    }

    /// 色温筛选框
    convenience init(tempValue: DPTemp, duration: Int = 1, hasTimeView: Bool = true) {
        self.init(mode: .temp, hasTimeView: hasTimeView, duration: duration, tempValue: tempValue)
    }

    /// xy颜色筛选框
    convenience init(xyColor: XYColor, duration: Int = 1, hasTimeView: Bool = true) {
        self.init(mode: .xy, hasTimeView: hasTimeView, duration: duration, xyColor: xyColor)
    }

    /// hsv颜色筛选框
    convenience init(hsvColor: HsvColor, duration: Int = 1, hasTimeView: Bool = true) {
        self.init(mode: .hsv, hasTimeView: hasTimeView, duration: duration, hsvColor: hsvColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if modeType == .xy || modeType == .hsv || modeType == .temp {
            removeMethod(name: "WINGTO_NATIVE")
        }
    }
}

// MARK: - private mothods
extension LightAttrPickerView: WKScriptMessageHandler {

    // Native invoke Js
    func evaluateJs(jsCode: String, completeBlock: ((_ result: Any?, _ error: Error?) -> Void)?) {
        self.wkWebView.evaluateJavaScript(jsCode) { (result, error) in
            completeBlock?(result, error)
        }
    }

    // Js invoke Native
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // print("message==>", message.body, message.name)
        guard message.name == "WINGTO_NATIVE" else { return }
        guard let msg = message.body as? String, let dict = msg.data?.dict else { return }
        //guard let msg = message.body as? String, let dict = msg.data(using: .utf8)?.dict else { return }
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
    func renderColorValueWheel() {
        let source = modeType == .xy ? "index": "hsvColorPicker"
        let dirname = modeType == .xy ? "src_xy": "src_hsv"
        guard let htmlpath = Bundle.main.path(forResource: source, ofType: "html", inDirectory: dirname) else { return }
        let baseUrl = URL(fileURLWithPath: htmlpath)
        // 本地html追加参数 https://stackoverflow.com/questions/8286099/how-to-pass-arguments-to-fileurl
        if let lastUrl = URL(string: "file://\(baseUrl.path.urlEncoded)?platform=ios") {
            wkWebView.load(URLRequest(url: lastUrl))
        }
    }

    func renderTempValueWheel() {
        guard let htmlpath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "src_temp") else { return }
        let baseUrl = URL(fileURLWithPath: htmlpath)
        if let lastUrl = URL(string: "file://\(baseUrl.path.urlEncoded)?platform=ios") {
            wkWebView.load(URLRequest(url: lastUrl))
        }
    }

    @objc func onJsReady() {
        DDLogDebug("onJsReady----")
        if modeType == .xy {
            self.setXYColor(param: xyColorParam?.toJSON() ?? initXYColor.toJSON())
        } else if modeType == .hsv {
            self.setHsvColor(param: hsvColorParam?.toJSON() ?? initHSVColor.toJSON())
        } else if modeType == .temp {
            self.setTemp(param: tempParam?.toJSON() ?? initTemp.toJSON())
        }
    }

    /// 设置默认XY颜色
    /// - Parameter param: {"curXY": "35895 29406"}
    func setXYColor(param: [String: Any]) {
        self.evaluateJs(jsCode: "WINGTO_H5.onSetXyColor('\(param.string ?? "")')") { result, error in
            print("result:\(result ?? ""), error:\(error?.localizedDescription ?? "")")
        }
    }

    /// 设置默认HSV颜色
    /// - Parameter param: {"hue": 0-360, "saturation": 0-254}
    func setHsvColor(param: [String: Any]) {
        self.evaluateJs(jsCode: "WINGTO_H5.onSetHsvColor('\(param.string ?? "")')") { result, error in
            print("result:\(result ?? ""), error:\(error?.localizedDescription ?? "")")
        }
    }

    /// 回调XY颜色更新
    /// - Parameter param:
    @objc func onXyColorPicker(_ param: [String: Any]) {
        xyColorParam = Mapper<XYColor>().map(JSON: param)
    }

    /// 回调HSV颜色更新
    /// - Parameter param: {"hue":305,"saturation":140,"isTouchEnd":true,"rgba":[255,0,233.75,0.5526608614492055]}
    @objc func onHsvColorPicker(_ param: [String: Any]) {
        //DDLogDebug("onHsvColorPicker.\(param.toJSONString() ?? "")")
        hsvColorParam = Mapper<HsvColor>().map(JSON: param)
    }

    /// 设置默认色温
    /// - Parameter param: {colorType?: number, templature?: number}
    func setTemp(param: [String: Any]) {
        self.evaluateJs(jsCode: "WINGTO_H5.onSetTempColor('\(param.string ?? "")')") { result, error in
            print("result:\(result ?? ""), error:\(error?.localizedDescription ?? "")")
        }
    }

    /// 回调色温更新
    /// - Parameter param: {isTouchEnd: boolean; color: string, templature: number, rgb: Array<number> }
    @objc func onTempColorPicker(_ param: [String: Any]) {
        tempParam = Mapper<DPTemp>().map(JSON: param)
    }
}

// MARK: - delegate or data source
extension LightAttrPickerView: CMToolViewDelegate, DurationViewDelegate {

    func cancelAction() {
        hide()
    }

    func confirAction() {
        hide()
        switch modeType {
        case .brightness:
            callBackBright?(transitionTime, Int(pickerDatas[selectedIndex]))
            delegate?.brightResult(duration: transitionTime, bright: Int(pickerDatas[selectedIndex]))
        case .temp:
            callBackTemp?(transitionTime, tempParam ?? initTemp)
            delegate?.colorTempResult(duration: transitionTime, temp: tempParam ?? initTemp)
        case .hsv:
            callBackHsv?(transitionTime, hsvColorParam ?? initHSVColor)
            delegate?.hsvColorResult(duration: transitionTime, color: hsvColorParam ?? initHSVColor)
        case .xy:
            callBackXy?(transitionTime, xyColorParam ?? initXYColor)
            delegate?.xyColorResult(duration: transitionTime, color: xyColorParam ?? initXYColor)
        }
    }

    func resultAction(duration: Int) {
        transitionTime = duration
    }
}

// MARK: - WKNavigationDelegate
extension LightAttrPickerView: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStart render wheel")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish render wheel")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail; error:\(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation; error:\(error.localizedDescription)")
    }
}

// MARK: - call backs
extension LightAttrPickerView {

    public func show() {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
            self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: self.contentHeight)
            UIView.animate(withDuration: 0.3) {
                self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.contentHeight, width: UIScreen.main.bounds.width, height: self.contentHeight)
            }
        }
    }

    public func hide() {
        DispatchQueue.main.async {
            self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.contentHeight, width: UIScreen.main.bounds.width, height: self.contentHeight)
            UIView.animate(withDuration: 0.3) {
                self.contentView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: self.contentHeight)
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

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension LightAttrPickerView: UIPickerViewDataSource, UIPickerViewDelegate {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.dataPicker.hideHighlightBgColor()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerDatas.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        pickerView.reloadAllComponents()
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.font = UIFont.systemFont(ofSize: kScaleW(22))
            label!.textAlignment = .center
        }
        if row == selectedIndex {
            label?.attributedText = self.slectedBackAttributeString("\(self.pickerDatas[row]) %", value: self.pickerDatas[row])
        } else {
            label?.text = "\(self.pickerDatas[row])"
        }
        return label!
    }

    func slectedBackAttributeString(_ str: String, value: String) -> NSAttributedString {
        let range = str.range(of: "\(value)")
        let attribute = NSMutableAttributedString.init(string: str)
        if range != nil {
            attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: kScaleW(12)), range: NSRange.init(location: 0, length: str.count))
            attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: kScaleW(24), weight: .medium), range: str.toNSRange(range!))
        }
        return attribute
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 55
    }
}
