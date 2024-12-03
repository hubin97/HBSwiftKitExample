//
//  SmartCommonDataPicker.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2021/12/10.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit
//import LuteBase

extension UIPickerView {
    /// 适配iOS14的选中灰色背景, 排除分割线; layoutSubviews()/ show()
    public func hideHighlightBgColor() {
        if #available(iOS 14.0, *) {
            let selectViews = self.subviews.filter({ $0.subviews.count == 0 })
            guard selectViews.count > 0 else { return }
            selectViews.filter({ $0.bounds.size.height > 1 }).forEach({ $0.backgroundColor = .clear })
        }
    }
}

/// 获取主窗口
private let kGlobalKeyWindow: UIWindow? = {
    if #available(iOS 13, *) {
        //UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    } else {
        return UIApplication.shared.keyWindow
    }
}()

typealias SCDataPicker = SmartCommonDataPicker
typealias SCDataPickerDelegate = SmartDataPickerDelegate

/// 通用数据选择器
protocol SmartDataPickerDelegate: AnyObject {
    func pickerResult(picker: SmartCommonDataPicker, flag: Any?,  _ index: Int, _ value: String, _ unit: String?)
}

// MARK: -
class SmartCommonDataPicker: UIView {

    weak var delegate: SmartDataPickerDelegate?
    var callBack: ((_ index: Int, _ value: String, _ unit: String?) -> Void)?
    /// 在多个弹框时, 可以用来区分(title, indexpath)
    var flag: Any?
    var unit: String?
    var selectedIndex: Int?
    var initalValue: String? {
        didSet {
            guard initalValue != nil else { return }
            for index in 0..<(self.data.count) where self.data[index] == self.initalValue {
                self.dataPicker?.selectRow(index, inComponent: 0, animated: false)
                self.selectedIndex = index
                self.dataPicker?.reloadAllComponents()
                break
            }
        }
    }

    var data = [String]() {
        didSet {
            self.dataPicker?.reloadAllComponents()
            self.pickerView(self.dataPicker!, didSelectRow: 0, inComponent: 0)
        }
    }

    var dataPicker: UIPickerView?
    let bgView = UIView()
    override init(frame: CGRect) {
        super.init(frame: kGlobalKeyWindow?.bounds ?? CGRect.zero)
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(bgView)
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 60))
        let left = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 40))
        let right = UIButton(frame: CGRect(x: self.width - 50 - 10, y: 10, width: 50, height: 40))
        left.setTitle("取消", for: .normal)
        right.setTitle("确认", for: .normal)
        left.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        right.addTarget(self, action: #selector(comfire), for: .touchUpInside)
        left.setTitleColor(.lightGray, for: .normal)
        right.setTitleColor(.blue, for: .normal)
        bgView.addSubview(topView)
        topView.addSubview(left)
        topView.addSubview(right)

        self.dataPicker = UIPickerView.init(frame: CGRect(x: 0, y: topView.maxY, width: kScreenW, height: kScaleW(240)))
        self.dataPicker?.delegate = self
        bgView.addSubview(self.dataPicker!)
        self.bgView.frame = CGRect(x: 0, y: frame.height, width: kScreenW, height: self.dataPicker!.maxY)
        bgView.backgroundColor = .white
    }

    convenience init(_ tmpUnit: String?, tmpCallBack: @escaping ((_ index: Int, _ value: String, _ unit: String?) -> Void)) {
        self.init(frame: CGRect.zero)
        unit = tmpUnit
        callBack = tmpCallBack
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.dataPicker?.hideHighlightBgColor()
    }
}

// MARK: - call backs
extension SmartCommonDataPicker {

    @objc func comfire() {
        callBack?(selectedIndex ?? 0, self.data[(selectedIndex ?? 0)], self.unit)
        delegate?.pickerResult(picker: self, flag: flag, selectedIndex ?? 0, self.data[(selectedIndex ?? 0)], self.unit)
        self.hidden()
    }

    @objc func cancel() {
        self.hidden()
    }

    func show() {
        self.dataPicker?.hideHighlightBgColor()
        kGlobalKeyWindow?.addSubview(self)
        self.bgView.frame = CGRect(x: 0, y: self.height, width: kScreenW, height: self.bgView.height)
        UIView.animate(withDuration: 0.3) {
            self.bgView.frame = CGRect(x: 0, y: self.height - self.bgView.height, width: kScreenW, height: self.bgView.height)
        }
    }

    func hidden() {
        UIView.animate(withDuration: 0.3) {
            self.bgView.frame = CGRect(x: 0, y: self.height, width: kScreenW, height: self.bgView.height)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - delegate or data source
extension SmartCommonDataPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
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
            label?.attributedText = self.slectedBackAttributeString("\(self.data[row]) \(self.unit ?? "")", value: self.data[row])
        } else {
            label?.text = "\(self.data[row])"
        }
        return label!
    }

    // 12
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
