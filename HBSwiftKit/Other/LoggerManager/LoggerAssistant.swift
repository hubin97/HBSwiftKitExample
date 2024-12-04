//
//  LoggerAssistant.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

// MARK: - main class
open class LoggerAssistant: UIView {

    private var icon: UIImage?
    private var tapEventBlock: (() -> Void)?
    private var beginPoint: CGPoint?
    private var movedPoint: CGPoint?
    
    /// 获取主窗口
    let appKeyWindow: UIWindow? = {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
        }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required convenience public init(size: CGSize? = nil, icon: UIImage? = nil, tapEvent: @escaping (() -> Void)) {
        self.init()
        defer {
            appKeyWindow?.addSubview(self)
            appKeyWindow?.bringSubviewToFront(self)
        }
        self.icon = icon
        self.tapEventBlock = tapEvent
        if let size = size, size != CGSize.zero {
            self.frame = CGRect(x: UIScreen.main.bounds.size.width - size.width, y: UIScreen.main.bounds.size.height/2, width: size.width, height: size.height)
        } else {
            self.frame = CGRect(x: UIScreen.main.bounds.size.width - 44, y: UIScreen.main.bounds.size.height/2, width: 44, height: 44)
        }
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panGes(_:))))
        //self.show()
    }
}

// MARK: - private mothods
extension LoggerAssistant {
 
    public func show() {
        let opBtn = UIButton.init(type: .custom)
        opBtn.frame = self.bounds
        if let img = icon {
            opBtn.setImage(img, for: .normal)
            //opBtn.setBackgroundImage(UIImage(color: .systemGroupedBackground), for: .normal)
            //opBtn.setRoundCorners(borderColor: .systemGroupedBackground, borderWidth: 1, raddi: 5, corners: .allCorners)
        } else {
            opBtn.setTitle("Logger", for: .normal)
            opBtn.setTitleColor(.systemBlue, for: .normal)
            //opBtn.setBackgroundImage(UIImage(color: .systemGroupedBackground), for: .normal)
            //opBtn.setRoundCorners()
        }
        opBtn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        self.addSubview(opBtn)
    }
    
    public func hide() {
        self.removeFromSuperview()
    }
}

// MARK: - call backs
extension LoggerAssistant {
    
    @objc func tapAction() {
        tapEventBlock?()
    }
    
    @objc func panGes(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            beginPoint = pan.location(in: UIApplication.shared.delegate?.window!)
            break
        case .changed:
            movedPoint = pan.location(in: UIApplication.shared.delegate?.window!)
            self.center = movedPoint ?? self.center
            break
        case .ended, .cancelled:
            let ePoint = pan.location(in: UIApplication.shared.delegate?.window!)
            let screenW = UIScreen.main.bounds.size.width
            let screenH = UIScreen.main.bounds.size.height

            if let bPoint = beginPoint, bPoint.equalTo(ePoint) == false {
                let minX = self.width/2
                let maxX = screenW - self.width/2
                let minY = self.height/2 + kTopSafeHeight
                let maxY = screenH - self.height/2 - kBottomSafeHeight
                
                var rx = min(maxX, ePoint.x)
                rx = max(minX, rx)
                var ry = min(maxY, ePoint.y)
                ry = max(minY, ry)
                
                if rx < screenW/2 {
                    if ry < screenH/2 {
                        if rx < ry {
                            rx = minX
                        } else {
                            ry = minY
                        }
                    } else {
                        if rx < screenH - ry {
                            rx = minX
                        } else {
                            ry = maxY
                        }
                    }
                } else {
                    if ry < screenH/2 {
                        if screenW - rx < ry {
                            rx = maxX
                        } else {
                            ry = minY
                        }
                    } else {
                        if screenW - rx < screenH - ry {
                            rx = maxX
                        } else {
                            ry = maxY
                        }
                    }
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.center = CGPoint(x: rx, y: ry)
                }
            }
            break
        case .failed:
            break
        default:
            break
        }
    }
}
