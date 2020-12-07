//
//  Wto_AlertView.swift
//  WingToSmart
//
//  Created by hubin.h@wingto.cn on 2020/7/31.
//  Copyright © 2020 WingTo. All rights reserved.

/**
     // 1
     Wto_AlertView.init(title: "温馨提示", message: "确定要执行此操作确定要执行此操作确定要执行此操作确定要执行此操作吗?", actions: nil, tapAction: nil).show()
     
     // 2
     let actions = ["取消", "确定"] //[String]() //["取消", "确定", "保存"] //["取消", "确定", "保存", "重置", "提交"]
     let alert = Wto_AlertView.init(title: "温馨提示", message: "确定要执行此操作确定要执行此操作确定要执行此操作吗?", actions: actions) { (index, title) in
         print("index:\(index) title - \(title)")
     }
     alert.setActionTextColor(0, .gray)
     alert.show()
     
     // 3
     let alert = Wto_AlertView.init(title: "温馨提示", message: "确定要执行此操作确定要执行此操作确定要执行此操作吗?")
     alert.addAction("取消") {
         print("addAction- 取消")
     }
     
     alert.addAction("确定") {
         print("addAction- 确定")
     }
     
     alert.addAction("保存") {
         print("addAction- 保存")
     }
     alert.show()
     
     // 4
     let alert = Wto_AlertView.init(title: "温馨提示", message: "确定要执行此操作吗?", actions: ["取消11", "确定11"]) { (index, action) in
         print("actions - \(action)")
     }
     
     alert.addAction("取消") {
         print("addAction- 取消")
     }
     
     alert.addAction("确定") {
         print("addAction- 确定")
     }
     
     alert.addAction("保存") {
         print("addAction- 保存")
     }
     alert.show()
 */
import UIKit
import Foundation

//MARK: - global var and methods
// 以6s为准的缩放比例
fileprivate let Scale_Width = UIScreen.main.bounds.width / 375
fileprivate func W_Scale(_ x:CGFloat) -> CGFloat {
    return Scale_Width * x
}

/// 颜色重绘成图片
fileprivate func imageWithColor(_ color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

/// 正确设置标签行间距 默认 9
fileprivate func setLabelLineSpacing(label: UILabel, lineSpacing: CGFloat = 9, _ alignment: NSTextAlignment = .center) -> [NSAttributedString.Key : Any]? {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing - (label.font.lineHeight - label.font.pointSize)
    paragraphStyle.alignment = alignment
    let attributes = [NSAttributedString.Key.font: label.font, NSAttributedString.Key.paragraphStyle: paragraphStyle]
    return attributes as [NSAttributedString.Key : Any]
}


//MARK: - main class
public class Wto_AlertView: UIView {
    
    var allActions = [Wto_Action]()
    var tapAction: ((_ index: Int, _ title: String) -> ())?
    
    var maskingView = UIView()
    var contentView = UIView() //UIToolBar() iOS12有问题; UIVisualEffectView不能做容器
    var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    var titleLabel = UILabel()
    var messageScroll = UIScrollView()
    var messageLabel = UILabel()
    var actionsView = UIView()

    fileprivate let max_alert_height = UIScreen.main.bounds.height/2
    fileprivate let alert_width = W_Scale(270)  // 同系统宽度
    fileprivate let action_height = W_Scale(44) // 同系统高度
    fileprivate let line_height: CGFloat = 0.5  // 同系统分割线 0.33, 不能小于0.5,否则不显示
    fileprivate let msg_LineSpacing: CGFloat = 7.5  // 消息行间距

    fileprivate let kpadding = W_Scale(15)
    fileprivate let s_kpadding = W_Scale(5) // 标题与内容间距

    fileprivate var t_height: CGFloat = 0  // title 总高度
    fileprivate var m_height: CGFloat = 0  // message 总高度
    fileprivate var a_height: CGFloat = 0  // actions 总高度(底部可交互按钮)
    fileprivate var alert_height: CGFloat = 0 // content 总高度
    fileprivate var mmin_height: CGFloat = 0  // message 可视高度

    override init(frame: CGRect) {
        super.init(frame: UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds)
        
        addSubview(maskingView)
        maskingView.frame = UIApplication.shared.keyWindow?.bounds ?? UIScreen.main.bounds
        maskingView.backgroundColor = UIColor.init(white: 0, alpha: 0.2) // 同系统蒙层
        
        maskingView.addSubview(contentView)
        maskingView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(maskTapAction(_:))))
        
        contentView.frame = CGRect(x: 0, y: 0, width: alert_width, height: alert_height)
        contentView.center = self.center
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 15.0
        
        contentView.addSubview(blurEffectView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageScroll)
        contentView.addSubview(actionsView)
        messageScroll.addSubview(messageLabel)

        contentView.backgroundColor = .white

        titleLabel.font = UIFont.systemFont(ofSize: W_Scale(16), weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byCharWrapping
        
        messageLabel.font = UIFont.systemFont(ofSize: W_Scale(14))
        messageLabel.textAlignment = .center
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byCharWrapping
    }
    
    func setup(title: String?, message: String?, actions: [String]?) {
        assert(!((title == nil || title == "") && (message == nil || message == "")), "标题和正文不能同时为空")
        assert(!(actions?.count ?? 0 > 5), "交互按钮不能超过5个")
        
        if let t_title = title, t_title != "" {
            let rect = NSString(string: t_title).boundingRect(with: CGSize(width: alert_width - 2 * kpadding, height: CGFloat(Int.max)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: titleLabel.font ?? UIFont.systemFont(ofSize: W_Scale(16), weight: .medium)], context: nil)
            t_height = rect.size.height
        }
        
        if let t_msg = message, t_msg != "" {
            // 设置行间距
            let attributes = setLabelLineSpacing(label: messageLabel, lineSpacing: msg_LineSpacing)
            let rect = NSString(string: t_msg).boundingRect(with: CGSize(width: alert_width - 2 * kpadding, height: CGFloat(Int.max)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            m_height = rect.size.height
            mmin_height = m_height
        }

        if let a_count = actions?.count, a_count > 0 {
            allActions.removeAll()
            for title in actions ?? [] {
                //allActions.append(Wto_Action.init(title, nil, nil))
                allActions.append(Wto_Action.init(title, nil, (() -> ())?.init(nilLiteral: ())))
            }
            a_height = a_count <= 2 ? action_height: action_height * CGFloat(a_count)
        }
        
        alert_height = (t_height + kpadding) + (m_height + s_kpadding) + (a_height + kpadding)
        // 限制高度
        if alert_height > max_alert_height {
            mmin_height = max_alert_height - ((t_height + kpadding) + (a_height + kpadding) + s_kpadding)
            alert_height = max_alert_height
        }
        
        titleLabel.frame = CGRect(x: kpadding, y: kpadding, width: alert_width - 2 * kpadding, height: t_height)
        messageScroll.frame = CGRect(x: kpadding, y: kpadding + t_height + s_kpadding, width: alert_width - 2 * kpadding, height: mmin_height)
        messageLabel.frame = CGRect(x: 0, y: 0, width: messageScroll.frame.width, height: m_height)
        actionsView.frame = CGRect(x: 0, y: messageScroll.frame.maxY + kpadding, width: alert_width, height: a_height)
        contentView.frame = CGRect(x: 0, y: 0, width: alert_width, height: alert_height)
        contentView.center = self.center
        blurEffectView.frame = contentView.bounds
        messageScroll.contentSize = CGSize(width: 0, height: m_height)
        
        titleLabel.text = title
        //messageLabel.text = message
        messageLabel.attributedText = NSAttributedString(string: message ?? "", attributes: setLabelLineSpacing(label: messageLabel, lineSpacing: msg_LineSpacing))

        if let a_count = actions?.count, a_count > 0 {
            actionSetup()
        }
    }
    
    func actionSetup() {
        // 清空底部视图
        _ = actionsView.subviews.map({ $0.removeFromSuperview() })
        
        let a_count = allActions.count
        let btn_width = a_count <= 2 ? ((alert_width - CGFloat(a_count - 1) * line_height) / CGFloat(a_count)) : alert_width
        
        var h_line_maxY: CGFloat = 0
        for index in 0..<a_count {
            // 横线 排除2个按钮时 到第二个的情况
            if !(a_count == 2 && index == 1) {
                let h_line = UIView.init(frame: CGRect(x: 0, y: action_height * CGFloat(index), width: alert_width, height: line_height))
                actionsView.addSubview(h_line)
                h_line.backgroundColor = UIColor(white: 0, alpha: 0.2)
                h_line_maxY = h_line.frame.origin.y + line_height
            }
            
            let minx = a_count <= 2 ? btn_width * CGFloat(index): 0
            let button = UIButton.init(type: .system)
            button.frame = CGRect(x: minx, y: h_line_maxY, width: btn_width, height: action_height)
            actionsView.addSubview(button)
            button.setTitle(allActions[index].title, for: .normal)
            button.setTitleColor(allActions[index].color, for: .normal)
            button.setBackgroundImage(imageWithColor(.lightGray), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: W_Scale(17))
            button.addTarget(self, action: #selector(btnTapAction(_:)), for: .touchUpInside)
            button.tag = 1000 + index
            
            // 竖线 仅个数为2才有
            if a_count == 2 && index < a_count - 1 {
                let v_line = UIView.init(frame: CGRect(x: button.frame.maxX, y: 0, width: line_height, height: action_height))
                actionsView.addSubview(v_line)
                v_line.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
        }
    }
    
    public convenience init(title: String?, message: String?) {
        self.init(frame: CGRect.zero)
        setup(title: title, message: message, actions: nil)
    }
    
    public convenience init(title: String?, message: String?, actions: [String]?, tapAction: ((_ index: Int, _ title: String) -> ())? ) {
        self.init(frame: CGRect.zero)
        setup(title: title, message: message, actions: actions)
        self.tapAction = tapAction
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: other classes
public class Wto_Action {
    
    var title: String?
    var color: UIColor?
    var tapAction: (() -> ())?
    
    init() {
    }
    
    convenience init(_ title: String?, _ color: UIColor?, _ tapAction: (() -> ())?) {
        self.init()

        self.title = title
        self.color = color
        self.tapAction = tapAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension Wto_AlertView {
    
    public func show() {
        DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.keyWindow
            keyWindow?.addSubview(self)
            self.scaleAnimate()
        }
    }
    
    public func hide() {
        self.removeFromSuperview()
    }
    
    /// 给actions内特定下标按钮设置背景色
    public func setActionTextColor(_ index: Int, _ color: UIColor) {
        guard allActions.count > 0 else { return }
        for i in 0..<allActions.count {
            if index == i {
                let tmp_btn = self.contentView.viewWithTag(1000 + i) as? UIButton
                tmp_btn?.setTitleColor(color, for: .normal)
                break
            }
        }
    }
    
    /// 添加按钮事件闭包
    public func addAction(_ title: String, _ color: UIColor = .systemBlue, tapAction: (() -> ())? ) {
        allActions.append(Wto_Action.init(title, color, tapAction))
        a_height = allActions.count <= 2 ? action_height: action_height * CGFloat(allActions.count)
        alert_height = (t_height + kpadding) + (m_height + s_kpadding) + (a_height + kpadding)
                
        contentView.frame = CGRect(x: 0, y: 0, width: alert_width, height: alert_height)
        contentView.center = self.center
        blurEffectView.frame = contentView.bounds
        actionsView.frame = CGRect(x: 0, y: messageScroll.frame.maxY + kpadding, width: alert_width, height: a_height)

        actionSetup()        
    }
    
    // 模拟系统弹框动画
    func scaleAnimate() {
        let animateKeyframes = CAKeyframeAnimation(keyPath: "transform")
        animateKeyframes.duration = 0.3
        animateKeyframes.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
                                   NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
                                   NSValue(caTransform3D: CATransform3DIdentity)]
        animateKeyframes.keyTimes = [0.0, 0.7, 1.0]
        animateKeyframes.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut),
                                            CAMediaTimingFunction(name: .easeInEaseOut),
                                            CAMediaTimingFunction(name: .easeInEaseOut)]
        self.contentView.layer.add(animateKeyframes, forKey: nil)
    }
}

//MARK: - call backs
extension Wto_AlertView {

    @objc func btnTapAction(_ sender: UIButton) {
        //print("tapAction--\(sender.titleLabel?.text ?? "")")
        self.allActions[sender.tag - 1000].tapAction?()
        self.tapAction?(sender.tag - 1000, (sender.titleLabel?.text ?? ""))
        hide()
    }
    
    @objc func maskTapAction(_ tap: UITapGestureRecognizer) {
        let tap_point = tap.location(in: self)
        let isincontent = self.contentView.frame.contains(tap_point)
        //print("isoutside_content\(isincontent ? "yes": "no")")
        // 无操作键可点击蒙层移除, 点不在contentView上
        if allActions.count == 0 && isincontent == false {
            hide()
        }
    }
}

