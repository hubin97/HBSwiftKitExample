//
//  DPAttrsPickerView+Views.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2021/12/14.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

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
                minBtn.isEnabled = duration != 0
                addBtn.isEnabled = duration != 10
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
