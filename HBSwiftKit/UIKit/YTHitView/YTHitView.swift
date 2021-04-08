//
//  YTHitView.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/4/8.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods

//MARK: - main class
public class YTHitView: UIView {
    
    public enum YTHitPosition {
        case top
        case center
        case bottom
        case none
    }
    
    static var hitBgImg = "topHintbg"
    static var hitWarnImg = "redWarning"
    static var hitSuccImg = "yellow_arrow"
    static var hitViewWidth: CGFloat = UIScreen.main.bounds.size.width - 20
    static var hitViewHeight: CGFloat = 65
    var duration: Int?
    
    static var hitView: YTHitView = {
        let hitView = YTHitView.init(frame: CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: -hitViewHeight, width: hitViewWidth, height: hitViewHeight))
        return hitView
    }()
    
    lazy var bgImgView: UIImageView = {
        let bgImgView = UIImageView.init(image: UIImage(named: YTHitView.hitBgImg))
        return bgImgView
    }()
    
    lazy var hitImgView: UIImageView = {
        let hitImgView = UIImageView.init(image: UIImage(named: YTHitView.hitWarnImg))
        return hitImgView
    }()
    
    lazy var msgLabel: UILabel = {
        let msgLabel = UILabel.init()
        msgLabel.textColor = .black
        msgLabel.textAlignment = .center
        msgLabel.font = UIFont.systemFont(ofSize: 17)
        msgLabel.numberOfLines = 0
        return msgLabel
    }()

    private override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgImgView)
        addSubview(hitImgView)
        addSubview(msgLabel)
        bgImgView.frame = self.bounds
        
        //self.setRoundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - call backs
extension YTHitView {
    
    public static func hitWidth(_ width: CGFloat) -> YTHitView.Type {
        YTHitView.hitViewWidth = width
        return YTHitView.self
    }
    public static func hitHeight(_ height: CGFloat) -> YTHitView.Type {
        YTHitView.hitViewHeight = height < 40 ? 40: height
        return YTHitView.self
    }
    public static func msgFont(_ fontSize: CGFloat) -> YTHitView.Type {
        YTHitView.hitView.msgLabel.font = UIFont.systemFont(ofSize: fontSize)
        return YTHitView.self
    }
    public static func textColor(_ color: UIColor) -> YTHitView.Type {
        YTHitView.hitView.msgLabel.textColor = color
        return YTHitView.self
    }
    public static func hitBackImg(_ bgImg: String) -> YTHitView.Type {
        YTHitView.hitBgImg = bgImg
        return YTHitView.self
    }
    public static func hitSuccImg(_ succImg: String) -> YTHitView.Type {
        YTHitView.hitSuccImg = succImg
        return YTHitView.self
    }
    public static func hitWarnImg(_ warnImg: String) -> YTHitView.Type {
        YTHitView.hitWarnImg = warnImg
        return YTHitView.self
    }
  
    public class func show(message: String, position: YTHitPosition = .center, noneRect: CGRect? = nil, duration: Int? = 2) {
        assert(!(position == .none && noneRect == nil), "自定义位置时必须传入noneRect")
        hitView.duration = duration
        hitView.hitImgView.isHidden = true
        //let msgWidth = hitView.msgLabel.estimatedWidth(maxHeight: hitView.bounds.size.height - 20, maxLine: 1)
        let msgWidth = NSString(string: message).boundingRect(with: CGSize(width: hitView.bounds.size.width - 20, height: hitView.bounds.size.height - 20), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: hitView.msgLabel.font ?? UIFont.systemFont(ofSize: 17)], context: nil).size.width + 1
        if msgWidth > hitView.bounds.size.width - 20 {
            hitView.msgLabel.textAlignment = .left
        } else {
            hitView.msgLabel.textAlignment = .center
        }
        hitView.msgLabel.text = message
        hitView.msgLabel.frame = CGRect(x: 10, y: 10, width: hitView.bounds.size.width - 20, height: hitView.bounds.size.height - 20)
        showAnimation(position: position, noneRect: noneRect)
    }
    
    public class func showSuccess(message: String, position: YTHitPosition = .center, noneRect: CGRect? = nil, duration: Int? = 2) {
        assert(!(position == .none && noneRect == nil), "自定义位置时必须传入noneRect")
        hitView.duration = duration
        hitView.hitImgView.isHidden = false
        //let msgWidth = hitView.msgLabel.estimatedWidth(maxHeight: hitView.bounds.size.height - 20, maxLine: 1)
        //let msgWidth2 = hitView.msgLabel.sizeThatFits(CGSize(width: hitView.bounds.size.width - 20, height: hitView.bounds.size.height - 20))
        //let msgWidth3 = NSString(string: message).boundingRect(with: CGSize(width: hitView.bounds.size.width - 20, height: hitView.bounds.size.height - 20), options: .usesLineFragmentOrigin, attributes: hitView.msgLabel.setLabelLineSpacing(), context: nil)
        let msgWidth = NSString(string: message).boundingRect(with: CGSize(width: hitView.bounds.size.width - 20, height: hitView.bounds.size.height - 20), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: hitView.msgLabel.font ?? UIFont.systemFont(ofSize: 17)], context: nil).size.width + 1
        //print("msgWidth:\(msgWidth), msgWidth2:\(msgWidth2), msgWidth3:\(msgWidth3)")
        if msgWidth > hitView.bounds.size.width - 20 {
            hitView.msgLabel.textAlignment = .left
            hitView.msgLabel.frame = CGRect(x: 10 + 30, y: 10, width: msgWidth, height: hitView.bounds.size.height - 20)
            hitView.hitImgView.frame = CGRect(x: hitView.msgLabel.frame.minX - 35, y: (hitView.bounds.size.height - 20)/2, width: 20, height: 20)
        } else {
            hitView.msgLabel.textAlignment = .center
            hitView.msgLabel.frame = CGRect(x: (hitView.bounds.size.width - msgWidth)/2, y: 10, width: msgWidth, height: hitView.bounds.size.height - 20)
            hitView.hitImgView.frame = CGRect(x: hitView.msgLabel.frame.minX - 35, y: (hitView.bounds.size.height - 20)/2, width: 20, height: 20)
        }
        hitView.msgLabel.text = message
        hitView.hitImgView.image = UIImage(named: YTHitView.hitSuccImg)
        showAnimation(position: position, noneRect: noneRect)
    }

    public class func showWarnning(message: String, position: YTHitPosition = .center, noneRect: CGRect? = nil, duration: Int? = 2) {
        showSuccess(message: message, position: position, noneRect: noneRect, duration: duration)
        hitView.hitImgView.image = UIImage(named: YTHitView.hitWarnImg)
    }
}

//MARK: - private mothods
extension YTHitView {
    
    private class func updateHitViewFrame(position: YTHitPosition) {
        switch position {
        case .top:
            hitView.frame = CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: -hitViewHeight, width: hitViewWidth, height: hitViewHeight)
            break
        case .bottom:
            hitView.frame = CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: UIScreen.main.bounds.size.height, width: hitViewWidth, height: hitViewHeight)
            break
        case .center, .none:
            break
        }
    }
    
    private class func showAnimation(position: YTHitPosition, noneRect: CGRect? = nil) {
        guard UIApplication.shared.delegate?.window??.subviews.contains(hitView) == false else {
            return
        }
        updateHitViewFrame(position: position)
        UIApplication.shared.delegate?.window??.addSubview(hitView)
        
        YTHitView.hitView.alpha = 1
        if position == .center {
            hitView.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
            YTHitView.hitView.addScaleAnimate(view: hitView)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(YTHitView.hitView.duration ?? 0) ) {
                hide(position: position)
            }
        } else if position == .none {
            if let rect = noneRect {
                hitView.frame = rect
                YTHitView.hitView.addScaleAnimate(view: hitView)
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(YTHitView.hitView.duration ?? 0) ) {
                    hide(position: position)
                }
            }
        } else {
            var targetFrame = CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: kTopSafeHeight + 20, width: hitViewWidth, height: hitViewHeight)
            if position == .bottom {
                targetFrame = CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: UIScreen.main.bounds.size.height - kBottomSafeHeight - hitViewHeight - 20, width: hitViewWidth, height: hitViewHeight)
            }
            UIView.animate(withDuration: 0.3) {
                YTHitView.hitView.frame = targetFrame
            } completion: { (finish) in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(YTHitView.hitView.duration ?? 0) ) {
                    hide(position: position)
                }
            }
        }
    }
    
    // 模拟系统弹框动画
    private func addScaleAnimate(view: UIView) {
        let animateKeyframes = CAKeyframeAnimation(keyPath: "transform")
        animateKeyframes.duration = 0.3
        animateKeyframes.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
                                   NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
                                   NSValue(caTransform3D: CATransform3DIdentity)]
        animateKeyframes.keyTimes = [0.0, 0.7, 1.0]
        animateKeyframes.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
        view.layer.add(animateKeyframes, forKey: nil)
    }
    
    private class func hide(position: YTHitPosition) {
        if position == .center || position == .none {
            YTHitView.hitView.alpha = 1
            UIView.animate(withDuration: 0.3) {
                YTHitView.hitView.alpha = 0
            } completion: { (finish) in
                YTHitView.hitView.removeFromSuperview()
            }
        } else {
            var targetFrame = CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: -hitViewHeight, width: hitViewWidth, height: hitViewHeight)
            if position == .bottom {
                targetFrame = CGRect(x: (UIScreen.main.bounds.size.width - hitViewWidth)/2, y: UIScreen.main.bounds.size.height, width: hitViewWidth, height: hitViewHeight)
            }
            UIView.animate(withDuration: 0.3, animations: {
                YTHitView.hitView.frame = targetFrame
            }) { (isfinish) in
                YTHitView.hitView.removeFromSuperview()
            }
        }
    }
}

//MARK: - delegate or data source
extension YTHitView {
    
}

//MARK: - other classes
