//
//  TitleSegment.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/3/2.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
fileprivate let kpadding: CGFloat = 2.0
fileprivate let ShowOutstandingFontMaxSize: CGFloat = 16.0
fileprivate let ShowOutstandingFontMinSize: CGFloat = 14.0

/// 事件回调
protocol TitleSegmentDelegate: class {
    func titleSegmentTapAction(title: String?, index: Int)
}

//MARK: - main class
class TitleSegment: UIView {

    /// 切换样式
    enum ShowStyle {
        case line   // 底部划线滑动
        case color  // 更换文字颜色
        case all    // 包含上述样式
    }
    
    /// 回调选中下标及标题
    var callBackTapTitleBlock: ((_ title: String?, _ index: Int) -> ())?
    weak var delegate: TitleSegmentDelegate?
    /// 数据源
    fileprivate var titles = [String]()
    
    ///** 风格样式 默认 Line */
    var style: ShowStyle = .line
    ///** 是否突出显示 (fontsize大小改变) 默认NO */
    var isShowOutstanding: Bool = false
    ///** 下划线长度, 默认按钮的1/2 */
    var indexLineWidth: CGFloat = 0
    /// 下划线高度
    var indexLineHeight: CGFloat = 1.5
    ///** 正常文字颜色 默认 gray */
    var normalColor: UIColor = .systemGray
    ///** 选中文字颜色 默认 blue */
    var selectColor: UIColor = .systemBlue
    ///** 中间分隔线颜色 默认gray */
    var separateLineColor: UIColor = .gray
    ///** 中间分隔线高度 默认1/3 */
    var separateLineHeight: CGFloat?
    ///** 底部分隔线颜色 默认gray */
    var bottomLineColor: UIColor = .groupTableViewBackground
    ///** 视图背景颜色 默认white */
    var titleViewColor: UIColor = .white {
        didSet {
            self.backgroundColor = titleViewColor
        }
    }
    ///** 下划线颜色 默认blue */
    var indexLineColor: UIColor = .systemBlue {
        didSet {
            indexView.backgroundColor = indexLineColor
        }
    }
    ///** 是否需要分割线 默认NO */
    var isNeedSeparateLine: Bool = false {
        didSet {
            if isNeedSeparateLine {
                for view in self.subviews {
                    guard let tapBtn = view as? UIButton else { return }
                    let index = tapBtn.tag - 1000
                    let lineHeight = separateLineHeight ?? (self.bounds.size.height / 4)
                    let minY = tapBtn.frame.minY + (tapBtn.bounds.size.height - lineHeight)/2
                    if index != titles.count - 1 {
                        let separateLine = UIView.init(frame: CGRect(x: tapBtn.frame.origin.x + tapBtn.frame.size.width, y: minY, width: kpadding/2, height: lineHeight))
                        separateLine.backgroundColor = separateLineColor
                        addSubview(separateLine)
                    }
                }
            }
        }
    }
    ///** 是否底部划线 默认NO */
    var isNeedBottomLine: Bool = false {
        didSet {
            if isNeedBottomLine {
                let bottomLine = UIView.init(frame: CGRect(x: 0, y: self.bounds.size.height - 1, width: self.bounds.size.width, height: 1))
                bottomLine.backgroundColor = bottomLineColor
                addSubview(bottomLine)
            }
        }
    }
    ///** 是否边框划线 默认NO */
    //var isNeedBorderLine: Bool = false

    /// 下标label
    lazy var indexView: UIView = {
        let indexView = UIView.init(frame: CGRect(x: 0, y: self.bounds.size.height - indexLineHeight, width: indexLineWidth, height: indexLineHeight))
        indexView.backgroundColor = indexLineColor
        return indexView
    }()
    
    convenience init(frame: CGRect, showStyle: TitleSegment.ShowStyle, titles: [String], indexLineWidth: CGFloat? = nil, isShowOutstanding: Bool = false) {
        self.init(frame: frame)
        self.style = showStyle
        self.titles = titles
        self.indexLineWidth = indexLineWidth ?? self.bounds.width/CGFloat(titles.count)/2
        self.isShowOutstanding = isShowOutstanding
        
        let count = titles.count
        let btnWidth = (count > 1) ? (self.bounds.size.width - CGFloat(count - 1) * kpadding)/CGFloat(count): self.bounds.size.width
        var assagnBtnRect = CGRect.zero
        for i in 0..<titles.count {
            let titleBtn = UIButton.init(type: .custom)
            let btnMinX = count > 1 ? (btnWidth + kpadding) * CGFloat(i) : btnWidth * CGFloat(i)
            addSubview(titleBtn)
            titleBtn.frame = CGRect(x: btnMinX, y: 2 * kpadding, width: btnWidth, height: self.bounds.size.height - 4 * kpadding)
            titleBtn.tag = 1000 + i
            titleBtn.isSelected = false
            titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: ShowOutstandingFontMinSize)
            titleBtn.setTitle(titles[i], for: .normal)
            titleBtn.setTitleColor(normalColor, for: .normal)
            if showStyle != .line {
                titleBtn.setTitleColor(selectColor, for: .selected)
            }
            titleBtn.addTarget(self, action: #selector(tapAction(_:)), for: .touchUpInside)
            // 设置下划线初始位置
            if i == 0 {
                assagnBtnRect = titleBtn.frame
                titleBtn.isSelected = true
                if isShowOutstanding {
                    titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: ShowOutstandingFontMaxSize)
                }
            }
        }
        
        if count > 1 && (showStyle == .line || showStyle == .all) {
            addSubview(indexView)
            var indexLabelFrame: CGRect = assagnBtnRect
            indexLabelFrame.origin.y   += (assagnBtnRect.size.height - self.indexLineHeight - kpadding)
            indexLabelFrame.origin.x   += (assagnBtnRect.size.width - self.indexLineWidth) / 2
            indexLabelFrame.size.width  = self.indexLineWidth
            indexLabelFrame.size.height = self.indexLineHeight
            indexView.frame = indexLabelFrame
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension TitleSegment {
    
    fileprivate func updateIndexLine(with tapBtn: UIButton) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            var indexViewFrame = self!.indexView.frame
            indexViewFrame.origin.x = tapBtn.frame.minX + (tapBtn.bounds.size.width - self!.indexLineWidth)/2
            self?.indexView.frame = indexViewFrame
        }
    }
    
    fileprivate func updateTapBtnColor(with tapBtn: UIButton) {
        for i in 0..<titles.count {
            let tag = 1000 + i
            if let btn = self.viewWithTag(tag) as? UIButton {
                btn.isSelected = false
                btn.titleLabel?.font = UIFont.systemFont(ofSize: ShowOutstandingFontMinSize)
            }
        }
        tapBtn.isSelected = true
        if isShowOutstanding {
            tapBtn.titleLabel?.font = UIFont.systemFont(ofSize: ShowOutstandingFontMaxSize)
        }
    }
    
    /// 指定默认选中的下标
    func setTargetIndex(with index: Int) {
        guard index < 0 || index > titles.count - 1 else { return }
        guard let defaultTapBtn = self.viewWithTag(1000 + index) as? UIButton else { return }
        if style == .line {
            updateIndexLine(with: defaultTapBtn)
        } else if style == .color {
            updateTapBtnColor(with: defaultTapBtn)
        } else { // all
            updateIndexLine(with: defaultTapBtn)
            updateTapBtnColor(with: defaultTapBtn)
        }
    }
}

//MARK: - call backs
extension TitleSegment {
    
    @objc func tapAction(_ sender: UIButton) {
        if style == .line {
            updateIndexLine(with: sender)
        } else if style == .color {
            updateTapBtnColor(with: sender)
        } else { // all
            updateIndexLine(with: sender)
            updateTapBtnColor(with: sender)
        }
        callBackTapTitleBlock?(sender.titleLabel?.text, sender.tag - 1000)
        delegate?.titleSegmentTapAction(title: sender.titleLabel?.text, index: sender.tag - 1000)
    }
}

//MARK: - delegate or data source
extension TitleSegment {
    
}

//MARK: - other classes
