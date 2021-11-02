//
//  TagsOptionView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/5/26.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods
public protocol TagsOptionViewDelegate: class {
    func tagsOpResult(_ tagMetas: [TagsMeta]?)
}

//MARK: - main class
fileprivate func WScale(_ x: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.size.width/375 * x
}
open class TagsOptionView: UIView {

    weak var delegate: TagsOptionViewDelegate?
    fileprivate var tapAction: ((_ tagMetas: [TagsMeta]?) -> ())?
    fileprivate let alert_width: CGFloat = WScale(335) // 系统宽度 270
    fileprivate let action_height: CGFloat = 44 // 系统高度 44
    fileprivate let max_alert_height = UIScreen.main.bounds.height * 2/3
    fileprivate var alert_height: CGFloat = 0 // content 总高度
    fileprivate var mmin_height: CGFloat = 0  // message 可视高度
    fileprivate var t_height: CGFloat = 0  // title 总高度
    fileprivate var a_height: CGFloat = 0  // actions 总高度(底部可交互按钮)
    fileprivate var m_height: CGFloat = 0  // message 总高度
    fileprivate let tagBase: Int = 2000  // tag基准

    public var kpadding: CGFloat = 20 //
    /// 同系统分割线 0.33, 不能小于0.5,否则不显示
    public var line_height: CGFloat = 0.5
    /// 消息体行间距
    public var msg_LineSpacing: CGFloat = 7.5

    /// 点击空白处是否可以取消, 默认 false
    public var isTapMaskHide: Bool = false
    /// 是否需要刷新选中状态, 默认 true
    public var isNeedUpdateTagState: Bool = true
    /// 是否需要展示右上角角标, 默认不展示
    public var isNeedTopRightMark: Bool = false {
        didSet {
            markImgView.isHidden = !isNeedTopRightMark
        }
    }

    public var maskingView = UIView()
    public var contentView = UIView()
    public var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    public var titleLabel = UILabel()
    public var markImgView = UIImageView.init(image: UIImage(named: "fast_up"))
    public var messageScroll = UIScrollView()
    public var actionsView = UIView()
    public var tags: [TagsMeta]? {
        didSet {
            tags?.enumerated().forEach({ (idx, meta) in
                meta.tag = tagBase + idx
            })
        }
    }
    fileprivate var actionTitle: String?
    fileprivate var isMultiple: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds)
        blurEffectView.effect = UIBlurEffect(style: .light)
        if #available(iOS 10, *) {
            blurEffectView.effect = UIBlurEffect(style: .prominent)
            if #available(iOS 13, *) {
                blurEffectView.effect = UIBlurEffect(style: .systemMaterialLight)
            }
        }
        contentView.addSubview(blurEffectView)

        addSubview(maskingView)
        maskingView.frame = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
        maskingView.backgroundColor = UIColor.init(white: 0, alpha: 0.2) // 同系统蒙层
        maskingView.addSubview(contentView)
        maskingView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(maskTapAction(_:))))
        
        contentView.frame = CGRect(x: 0, y: 0, width: alert_width, height: alert_height)
        contentView.center = self.center
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 15.0
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(markImgView)
        contentView.addSubview(messageScroll)
        contentView.addSubview(actionsView)

        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byCharWrapping
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension TagsOptionView {
    
    /// 标签组样式
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - isMultiple: 是否多选
    ///   - options: 可以标签组 [TagsMeta]?
    ///   - optionNormalBgColor: 标签正常背景色
    ///   - optionSelectBgColor: 标签选中背景色
    ///   - optionNormalTextColor: 标签正常字体色
    ///   - optionSelectTextColor: 标签选中字体色
    ///   - optionFont: 标签字体大小
    ///   - optionMinWidth: 标签最小宽度
    ///   - optionMaxHeight: 标签最大高度
    ///   - actionTitle: 确认键标题
    ///   - actionTitleColor: 确认键字体色
    ///   - tapAction: 最终事件回调
    /// - Returns: self
    public convenience init(title: String?, isMultiple: Bool = false, options: [TagsMeta]?, columns: Int = 4, optionNormalBgColor: UIColor = .lightGray, optionSelectBgColor: UIColor = .blue, optionNormalTextColor: UIColor = .black, optionSelectTextColor: UIColor = .white, optionFont: UIFont = UIFont.systemFont(ofSize: 15), optionMinWidth: CGFloat = 30, optionMaxHeight: CGFloat = 40, actionTitle: String?, actionTitleColor: UIColor = .systemBlue, tapAction: ((_ tagMetas: [TagsMeta]?) -> ())? ) {
        self.init(frame: CGRect.zero)
        self.tapAction = tapAction
        setup(title: title, isMultiple: isMultiple, options: options, columns: columns, optionNormalBgColor: optionNormalBgColor, optionSelectBgColor: optionSelectBgColor, optionNormalTextColor: optionNormalTextColor, optionSelectTextColor: optionSelectTextColor, optionFont: optionFont, optionMinWidth: optionMinWidth, optionMaxHeight: optionMaxHeight, actionTitle: actionTitle, actionTitleColor: actionTitleColor)
    }
    
    func setup(title: String?, isMultiple: Bool, options: [TagsMeta]?, columns: Int, optionNormalBgColor: UIColor, optionSelectBgColor: UIColor, optionNormalTextColor: UIColor, optionSelectTextColor: UIColor, optionFont: UIFont, optionMinWidth: CGFloat, optionMaxHeight: CGFloat, actionTitle: String?, actionTitleColor: UIColor) {
        assert(!(title == nil || title == ""), "标题不能为空")
        assert(!(title == nil && isMultiple == true), "多选时标题不能为空")
        self.actionTitle = actionTitle
        self.tags = options
        self.isMultiple = isMultiple
        
        if let t_title = title, t_title != "" {
            let rect = NSString(string: t_title).boundingRect(with: CGSize(width: alert_width - kpadding, height: CGFloat(Int.max)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: titleLabel.font ?? UIFont.systemFont(ofSize: 16, weight: .medium)], context: nil)
            t_height = rect.size.height
        }
        
        /// tags flow 高度估算
        var total_height: CGFloat = 0
        if let t_option = options, t_option.count > 0 {
            let limit_width = alert_width - kpadding

            if let _ = t_option.first?.iconn, columns > 0 {
                let item_width = (limit_width - CGFloat(columns + 1) * kpadding)/CGFloat(columns)
                let item_height = item_width
                for idx in 0..<t_option.count {
                    let row = idx / columns
                    let index = idx - row * columns
                    let op = t_option[idx]
                    let btn = TagIconBtn.init(type: .custom)
                    messageScroll.addSubview(btn)
                    btn.frame = CGRect(x: kpadding/2 + (item_width + kpadding) * CGFloat(index), y: kpadding/2 + (item_height + kpadding) * CGFloat(row), width: item_width, height: item_height)
                    btn.setTitle(op.title, for: .normal)
                    btn.setTitleColor(optionNormalTextColor, for: .normal)
                    btn.setTitleColor(optionSelectTextColor, for: .selected)
                    btn.setTitleColor(optionSelectTextColor, for: .highlighted)
                    btn.setImage(UIImage(named: op.iconn ?? ""), for: .normal)
                    btn.setImage(UIImage(named: op.iconh ?? ""), for: .selected)
                    btn.setImage(UIImage(named: op.iconh ?? ""), for: .highlighted)
                    btn.titleLabel?.font = optionFont
                    btn.addTarget(self, action: #selector(tagAction), for: .touchUpInside)
                    btn.titleLabel?.lineBreakMode = .byTruncatingTail
                    btn.titleLabel?.textAlignment = .center
                    btn.tag = tagBase + idx
                    btn.isSelected = op.isSelected
                    op.tag = btn.tag
                }
                let total_row = t_option.count % columns == 0 ? (t_option.count / columns): (t_option.count / columns) + 1
                total_height = kpadding + (item_height + kpadding) * CGFloat(total_row)
                mmin_height = max(optionMaxHeight, min(300, total_height))
                m_height = mmin_height//total_height
            } else {
                var item_width: CGFloat = 0
                total_height = kpadding/2
                for idx in 0..<t_option.count {
                    let op = t_option[idx]
                    let btn = UIButton.init(type: .custom)
                    messageScroll.addSubview(btn)
                    btn.setTitle(op.title, for: .normal)
                    btn.setTitleColor(optionNormalTextColor, for: .normal)
                    btn.setBackgroundImage(UIImage(color: optionNormalBgColor), for: .normal)
                    btn.setTitleColor(optionSelectTextColor, for: .selected)
                    btn.setBackgroundImage(UIImage(color: optionSelectBgColor), for: .selected)
                    btn.setTitleColor(optionSelectTextColor, for: .highlighted)
                    btn.setBackgroundImage(UIImage(color: optionSelectBgColor), for: .highlighted)
                    btn.titleLabel?.font = optionFont
                    btn.addTarget(self, action: #selector(tagAction), for: .touchUpInside)
                    btn.titleLabel?.lineBreakMode = .byTruncatingTail
                    btn.tag = tagBase + idx
                    btn.layer.masksToBounds = true
                    btn.layer.cornerRadius = 5
                    btn.isSelected = op.isSelected
                    op.tag = btn.tag
                    
                    let rect = NSString(string: op.title ?? "").boundingRect(with: CGSize(width: limit_width, height: optionMaxHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: optionFont], context: nil)
                    let text_width = max(rect.size.width + kpadding/2, optionMinWidth)
                    if item_width + text_width + kpadding > limit_width {
                        item_width = 0
                        total_height += (optionMaxHeight + kpadding/2)
                    }
                    btn.frame = CGRect(x: item_width, y: total_height, width: text_width, height: optionMaxHeight)
                    item_width += text_width + kpadding/2  // itemspace
                }
                total_height += optionMaxHeight
                mmin_height = max(optionMaxHeight, min(300, total_height))
                m_height = mmin_height//total_height
            }
        }

        if let actionTitle = actionTitle, !actionTitle.isEmpty {
            a_height = action_height
        }
        
        alert_height = (t_height + kpadding) + (m_height + kpadding) + (a_height + kpadding)
        // 限制高度
        if alert_height > max_alert_height {
            mmin_height = max_alert_height - ((t_height + kpadding) + (a_height + kpadding) + kpadding)
            alert_height = max_alert_height
        }
        
        titleLabel.frame = CGRect(x: kpadding + kpadding/2, y: kpadding, width: alert_width - 3 * kpadding, height: t_height)
        markImgView.frame = CGRect(x: alert_width - 2 * kpadding + 10, y: kpadding, width: 15, height: 15)
        messageScroll.frame = CGRect(x: kpadding, y: kpadding + t_height + kpadding, width: alert_width - 2 * kpadding, height: mmin_height)
        actionsView.frame = CGRect(x: 0, y: messageScroll.frame.maxY + kpadding, width: alert_width, height: a_height)
        contentView.frame = CGRect(x: 0, y: 0, width: alert_width, height: alert_height)
        contentView.center = self.center
        blurEffectView.frame = contentView.bounds
        messageScroll.contentSize = CGSize(width: 0, height: total_height)
        
        titleLabel.text = title
        markImgView.isHidden = true

        if let actionTitle = actionTitle, !actionTitle.isEmpty {
            let button = UIButton.init(type: .system)
            button.frame = actionsView.bounds
            actionsView.addSubview(button)
            button.setTitle(actionTitle, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.setBackgroundImage(UIImage(color: .lightGray), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.addTarget(self, action: #selector(btnTapAction(_:)), for: .touchUpInside)
            
            let lineView = UIView.init(frame: CGRect(x: 0, y: 0, width: actionsView.bounds.size.width, height: line_height))
            actionsView.addSubview(lineView)
            lineView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }
    }
        
    @objc func btnTapAction(_ sender: UIButton) {
        hide()
        let ops = self.tags?.filter({ $0.isSelected == true })
        self.tapAction?(ops)
        self.delegate?.tagsOpResult(ops)
    }
    
    @objc func tagAction(_ sender: UIButton) {
        //print("\(sender.titleLabel?.text ?? ""), tag:\(sender.tag)")
        if self.isMultiple == true {
            sender.isSelected = !sender.isSelected
        } else {
            messageScroll.subviews.forEach { (view) in
                if let btn = view as? UIButton {
                    btn.isSelected = false
                }
            }
            sender.isSelected = true
        }
        
        // 同步数据源
        let selTags = messageScroll.subviews.filter({ $0.isKind(of: UIButton.self) })
            .map({ $0 as! UIButton }).filter({ $0.isSelected == true }).map({ $0.tag })
        //let tag = sender.tag
        self.tags?.forEach({ $0.isSelected = false })
        self.tags?.filter({ selTags.contains($0.tag ?? 0) }).forEach({ $0.isSelected = true })
        if self.actionTitle == nil || actionTitle?.isEmpty == true {
            hide()
            let ops = self.tags?.filter({ $0.isSelected == true })
            self.tapAction?(ops)
            self.delegate?.tagsOpResult(ops)
        }
    }
    
    // 同步数据源
    func updateTagState() {
        if let selTags = self.tags?.filter({ $0.isSelected == true }).map({ $0.tag ?? 0 }) {
            messageScroll.subviews
                .filter({ $0.isKind(of: UIButton.self) }).map({ $0 as! UIButton })
                .forEach({ $0.isSelected = selTags.contains($0.tag) })
        }
    }
}

//MARK: - call backs
extension TagsOptionView {
    
    /// show
    ///
    /// let ff = sender.convert(sender.bounds, to: UIApplication.shared.keyWindow)
    /// - Parameter originFrame: 不传默认为nil, 以UIApplication.shared.keyWindow为参考计算frame
    public func show(originFrame: CGRect? = nil, isLinkOrigin: Bool = false) {
        DispatchQueue.main.async {
            if self.isNeedUpdateTagState {
                self.updateTagState()
            }
            UIApplication.shared.keyWindow?.addSubview(self)
            guard let originFrame = originFrame else {
                self.systemAnimate()
                return
            }
            
            /// 取给定的起始frame拉伸到目标frame
            let targetFrame = self.contentView.frame
            self.contentView.frame = originFrame
            UIView.animate(withDuration: 0.3) {
                if isLinkOrigin {
                    let minY = originFrame.origin.y
                    if minY + targetFrame.size.height > UIScreen.main.bounds.size.height - kTabBarHeight {
                        self.contentView.frame = targetFrame
                    } else {
                        self.contentView.frame = CGRect(x: targetFrame.origin.x, y: originFrame.origin.y, width: targetFrame.size.width, height: targetFrame.size.height)
                    }
                } else {
                    self.contentView.frame = targetFrame
                }
            }
        }
    }
    
    public func hide() {
        self.removeFromSuperview()
    }
    
    @objc func maskTapAction(_ tap: UITapGestureRecognizer) {
        let tap_point = tap.location(in: self)
        let isincontent = self.contentView.frame.contains(tap_point)
        // 无操作键可点击蒙层移除, 点不在contentView上
        if ((self.actionTitle == nil || self.isTapMaskHide) && isincontent == false) {
            hide()
        }
    }
    
    // 模拟系统弹框动画
    func systemAnimate() {
        let animateKeyframes = CAKeyframeAnimation(keyPath: "transform")
        animateKeyframes.duration = 0.3
        animateKeyframes.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
                                   NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
                                   NSValue(caTransform3D: CATransform3DIdentity)]
        animateKeyframes.keyTimes = [0.0, 0.7, 1.0]
        animateKeyframes.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        self.contentView.layer.add(animateKeyframes, forKey: nil)
    }
}

//MARK: - delegate or data source
extension TagsOptionView {
    
}

//MARK: - other classes
open class TagIconBtn: UIButton {
    
    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var imageRect = contentRect
        imageRect.size.width = contentRect.size.width/2
        imageRect.size.height = imageRect.size.width
        imageRect.origin.x = contentRect.size.width/4
        imageRect.origin.y = contentRect.size.width/8
        return imageRect
    }
    
    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = contentRect
        titleRect.origin.y = contentRect.size.width * 3/4
        titleRect.size.height = contentRect.size.height - titleRect.origin.y
        return titleRect
    }
}

open class TagsMeta {
    public var title: String?
    public var iconn: String?
    public var iconh: String?
    public var param: Any?
    public var isSelected: Bool = false
    public var tag: Int?
    public convenience init(title: String?, iconn: String? = nil, iconh: String? = nil, param: Any?, isSelected: Bool = false, tag: Int? = nil) {
        self.init()
        self.iconn = iconn
        self.iconh = iconh
        self.title = title
        self.param = param
        self.isSelected = isSelected
        self.tag = tag
    }
}
