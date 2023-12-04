//
//  LTDatePicker.swift
//  Momcozy
//
//  Created by hubin.h on 2023/11/27.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
//import LuteBase

// MARK: - global var and methods
extension UIDatePicker {
    
    // #warning("与UIPickerView不同, 待处理")
    /// 适配iOS14的选中灰色背景, 排除分割线; layoutSubviews()/ show()
    ///
    public func hideHighlightBgColor() {
        if #available(iOS 14.0, *) {
            // _UIPickerHighlightView
            guard let highlightView = self.subviews.last?.subviews.filter({ $0.subviews.count == 0 }).first else { return }
            highlightView.backgroundColor = .clear
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

/// 通用数据选择器
protocol LTDatePickerDelegate: AnyObject {
    func pickerResult(picker: LTDatePicker, flag: Any?, date: Date)
}

// MARK: - main class
class LTDatePicker: UIView {
    
    weak var delegate: LTDatePickerDelegate?
    var callBack: ((_ date: Date) -> Void)?
    /// 在多个弹框时, 可以用来区分(title, indexpath)
    var flag: Any?

    lazy var toolView: UIView = {
        let _toolView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 60))
        let left = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 40))
        let right = UIButton(frame: CGRect(x: self.width - 50 - 10, y: 10, width: 50, height: 40))
        left.setTitle("取消", for: .normal)
        right.setTitle("确认", for: .normal)
        left.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        right.addTarget(self, action: #selector(comfire), for: .touchUpInside)
        left.setTitleColor(.lightGray, for: .normal)
        right.setTitleColor(.blue, for: .normal)
        _toolView.addSubview(left)
        _toolView.addSubview(right)
        return _toolView
    }()
    
    lazy var datePicker: UIDatePicker = {
        // UIDatePicker 默认宽高 320 *215
        let _datePicker = UIDatePicker(frame: CGRect(x: (kScreenW - 320)/2, y: toolView.maxY, width: kScreenW, height: 215))
        if #available(iOS 13.4, *) {
            _datePicker.preferredDatePickerStyle = .wheels
        }
        return _datePicker
    }()
    
    lazy var bgView: UIView = {
        let _bgView = UIView(frame: CGRect(x: 0, y: frame.height, width: kScreenW, height: self.datePicker.maxY))
        _bgView.backgroundColor = .white
        return _bgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: kGlobalKeyWindow?.bounds ?? CGRect.zero)
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        addSubview(bgView)
        bgView.addSubview(toolView)
        bgView.addSubview(datePicker)
    }

    convenience init(_ mode: UIDatePicker.Mode, tmpCallBack: ((_ date: Date) -> Void)? = nil) {
        self.init(frame: CGRect.zero)
        self.callBack = tmpCallBack
        self.datePicker.datePickerMode = mode
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.datePicker.hideHighlightBgColor()
    }
}

// MARK: - private mothods
extension LTDatePicker { 
}

// MARK: - call backs
extension LTDatePicker {
    
    @objc func comfire() {
        self.callBack?(self.datePicker.date)
        self.delegate?.pickerResult(picker: self, flag: flag, date: self.datePicker.date)
        self.hidden()
    }

    @objc func cancel() {
        self.hidden()
    }

    func show() {
        self.datePicker.hideHighlightBgColor()
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
extension LTDatePicker { 
}

// MARK: - other classes
