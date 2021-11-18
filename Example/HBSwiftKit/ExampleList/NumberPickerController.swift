//
//  NumberPickerController.swift
//  HBSwiftKitDemo
//
//  Created by hubin.h@wingto.cn on 2020/9/19.
//  Copyright © 2020 WingTo. All rights reserved.

import UIKit
import Foundation

// MARK: - global var and methods
let blurPadding: CGFloat = 50
let pickerDataSize = 1_000

private let Scale_Width = UIScreen.main.bounds.width / 375
private func W_Scale(_ x: CGFloat) -> CGFloat {
    return Scale_Width * x
}

// MARK: - main class
class NumberPickerController: BaseViewController {

    lazy var numberPicker: NumberPicker = {
        let numberPicker = NumberPicker.init(frame: CGRect(x: 20, y: 50, width: W_Scale(145), height: 75 + blurPadding), minValue: 16, maxValue: 30)
        return numberPicker
    }()

    lazy var numTextField: UITextField = {
        let textField = UITextField.init(frame: CGRect(x: 200, y: 50, width: 60, height: 30))
        textField.placeholder = "\(self.numberPicker.minValue)~\(self.numberPicker.maxValue)"
        return textField
    }()

    lazy var qureBtn: UIButton = {
        let qureBtn = UIButton.init(type: .system)
        qureBtn.frame = CGRect(x: 280, y: 50, width: 40, height: 30)
        qureBtn.setTitle("确定", for: .normal)
        qureBtn.addTarget(self, action: #selector(qureAction), for: .touchUpInside)
        return qureBtn
    }()

    lazy var addBtn: UIButton = {
        let addBtn = UIButton.init(type: .system)
        addBtn.frame = CGRect(x: 200, y: 145, width: 40, height: 30)
        addBtn.setTitle("+", for: .normal)
        addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        return addBtn
    }()

    lazy var divBtn: UIButton = {
        let divBtn = UIButton.init(type: .system)
        divBtn.frame = CGRect(x: 280, y: 145, width: 40, height: 30)
        divBtn.setTitle("-", for: .normal)
        divBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        divBtn.addTarget(self, action: #selector(divAction), for: .touchUpInside)
        return divBtn
    }()

    lazy var hNumPickerView: HorizonNumPickerView = {
        let frame = CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2.43)
        let pickerView = HorizonNumPickerView.init(frame: frame)
        return pickerView
    }()

    override func setupUi() {
        super.setupUi()

        self.title = "数字选择器"

        view.addSubview(numberPicker)
        view.addSubview(numTextField)
        view.addSubview(qureBtn)
        view.addSubview(addBtn)
        view.addSubview(divBtn)

        /// numberPicker.center = view.center

        numberPicker.layer.borderColor = UIColor.red.cgColor
        numberPicker.layer.borderWidth = 1

        numTextField.layer.borderColor = UIColor.red.cgColor
        numTextField.layer.borderWidth = 1
        qureBtn.layer.borderColor = UIColor.red.cgColor
        qureBtn.layer.borderWidth = 1

        addBtn.layer.borderColor = UIColor.red.cgColor
        addBtn.layer.borderWidth = 1
        divBtn.layer.borderColor = UIColor.red.cgColor
        divBtn.layer.borderWidth = 1

        view.addSubview(hNumPickerView)
        hNumPickerView.layer.borderColor = UIColor.red.cgColor
        hNumPickerView.layer.borderWidth = 1

        // 默认选中最小项
        hNumPickerView.selectRoll(row: 0, com: 0)
    }
}

// MARK: - private mothods
extension NumberPickerController {

}

// MARK: - call backs
extension NumberPickerController {

    @objc func qureAction() {

        if let value = Int(self.numTextField.text ?? "") {
            assert(value < self.numberPicker.maxValue && value > self.numberPicker.minValue, "输入有误")
            numberPicker.scrolToValue(value: value)
        }
    }

    @objc func addAction() {

        let value = numberPicker.value + 1
        // guard value < self.numberPicker.maxValue && value > self.numberPicker.minValue else { return }

        numberPicker.scrolToValue(value: value)
    }

    @objc func divAction() {

        let value = numberPicker.value - 1
        // guard value < self.numberPicker.maxValue && value > self.numberPicker.minValue else { return }

        numberPicker.scrolToValue(value: value)
    }
}

// MARK: - delegate or data source
extension NumberPickerController {

}

// MARK: - other classes
// MARK: 0~100以内数字选择器
class NumberPicker: UIPickerView {

    var minValue = 16
    var maxValue = 30

    var value: Int {
        let a = self.selectedRow(inComponent: 0)
        let b = self.selectedRow(inComponent: 1)
        return a * 10 + b
    }

    var pickerData: [Int] {
        return numLists(0, 9)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, minValue: Int = 16, maxValue: Int = 30) {
        self.init(frame: frame)

        self.minValue = minValue
        self.maxValue = maxValue

        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {

        self.dataSource = self
        self.delegate = self

        self.reloadAllComponents()

        ///
        let m_maxValue = pickerDataSize/2 + minValue / 10
        let m_minValue = pickerDataSize/2 + minValue % 10

        self.selectRow(m_maxValue, inComponent: 0, animated: false)
        self.selectRow(m_minValue, inComponent: 1, animated: false)
    }
}

// MARK: private methods
extension NumberPicker {

    func numLists(_ minNum: Int, _ maxNum: Int) -> [Int] {
        var nums = [Int]()
        for num in minNum...maxNum {
            nums.append(num)
        }
        return nums
    }

    func scrolToValue(value: Int) {

        let offset0 = value / 10 - self.value / 10
        let offset1 = value > self.value ? 1: -1

        self.selectRow(self.selectedRow(inComponent: 0) + offset0, inComponent: 0, animated: true)
        self.selectRow(self.selectedRow(inComponent: 1) + offset1, inComponent: 1, animated: true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hideHighlightBgColor()
    }
}

// MARK: data source /delegate
extension NumberPicker: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerDataSize
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row % pickerData.count])"
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        self.bounds.width / 2
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        self.bounds.height + blurPadding
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var label = UILabel()
        if let view = view as? UILabel {
            label = view
        }

        var frame = label.frame
        frame.origin.y += blurPadding/2
        frame.size.height -= blurPadding
        label.frame = frame

        label.font = UIFont.systemFont(ofSize: 95, weight: .medium)
        label.text = "\(pickerData[row % pickerData.count])"
        // let w = label.estimatedWidth(maxHeight: 75)
        // print("label.w:\(w)")

        label.textAlignment = component == 0 ? .right : .left
        return label
    }
}

// MARK: 横幅滑动滚轴
class HorizonNumPickerView: UIView {

    var callBackSelRowValueBlock: ((_ value: Int) -> Void)?

    var bgImgView = UIImageView()
    lazy var numPicker: UIPickerView = {
        let frame = CGRect(x: 0, y: -self.frame.size.width/10 - 50, width: self.frame.size.width, height: self.frame.size.width)
        let numPicker = UIPickerView.init(frame: frame)
        numPicker.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        numPicker.transform = numPicker.transform.rotated(by: CGFloat.pi * 3/2)
        numPicker.dataSource = self
        numPicker.delegate = self
        return numPicker
    }()

    var flagUpImgView = UIImageView()
    var flagScrolImgView = UIImageView()

    var selectedRow = 0

    var pickerData: [Int] {
        return self.numLists(16, 30)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bgImgView)
        addSubview(numPicker)
        addSubview(flagScrolImgView)
        addSubview(flagUpImgView)

        bgImgView.frame = self.bounds
        bgImgView.image = UIImage(named: "fh_bg_n")

        // flagUpImgView.frame = CGRect(x: (UIScreen.main.bounds.width - W_Scale(7))/2, y: frame.size.height - 70 - W_Scale(7), width: W_Scale(7), height: W_Scale(7))
        // flagUpImgView.image = UIImage(named: "fh_up_n")

        // flagScrolImgView.frame = CGRect(x: (UIScreen.main.bounds.width - W_Scale(40))/2, y: frame.size.height - W_Scale(40), width: W_Scale(40), height: W_Scale(40))
        // flagScrolImgView.image = UIImage(named: "fh_scrol_n")

        numPicker.reloadAllComponents()
        numPicker.selectRow(0, inComponent: 0, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numLists(_ minNum: Int, _ maxNum: Int) -> [Int] {
        var nums = [Int]()
        for num in minNum...maxNum {
            nums.append(num)
        }
        return nums
    }

    /// 手动调用选中代理方法
    func selectRoll(row: Int, com: Int) {
        self.numPicker.selectRow(row, inComponent: com, animated: false)
        self.pickerView(self.numPicker, didSelectRow: row, inComponent: com)
    }

    // 根据设备在线状态更新ui
    func updateStateUi(isOn: Bool) {

        bgImgView.image = UIImage(named: isOn ? "fh_bg_n": "fh_bg_d")
        flagUpImgView.image = UIImage(named: isOn ? "fh_up_n": "fh_up_d")
        flagScrolImgView.image = UIImage(named: isOn ? "fh_scrol_n": "fh_scrol_d")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        numPicker.hideHighlightBgColor()
    }

    /// 适配iOS14的选中灰色背景, 排除分割线; show()
//    func hideHighlightBgColor() {
//        if #available(iOS 14.0, *) {
//            let selectViews = numPicker.subviews.filter({ $0.subviews.count == 0 })
//            if selectViews.count > 0 {
//                _ = selectViews.filter({ $0.bounds.size.height > 1 }).map({ $0.backgroundColor = .clear })
//            }
//        }
//    }
}

extension HorizonNumPickerView: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        frame.width/10
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        frame.width
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        /// 隐藏分割线
        pickerView.subviews.forEach({ (subview) in
            if subview.frame.height <= 2 {
                subview.backgroundColor = .clear
            }
        })

        var label = UILabel()
        if let view = view as? UILabel {
            label = view
        }

        // label.textColor = (selectedRow == row) ? .clear: .black
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.text = "\(pickerData[row])"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi/2)
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        selectedRow = row
        pickerView.reloadComponent(component)

        print("\(pickerData[row])")
        self.callBackSelRowValueBlock?(pickerData[row])
    }
}
