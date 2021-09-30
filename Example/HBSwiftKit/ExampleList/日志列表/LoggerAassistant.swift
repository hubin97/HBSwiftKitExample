//
//  LoggerAassistant.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/30.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation

//MARK: - global var and methods

//MARK: - main class
class LoggerAassistant: UIView {

    var beginPoint: CGPoint?
    var movedPoint: CGPoint?

    private var icon: UIImage?
    private var tapEventBlock: (() -> ())?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(size: CGSize? = nil, icon: UIImage? = nil, tapEvent: @escaping (() -> ())) {
        self.init()
        defer {
            UIApplication.shared.delegate?.window??.addSubview(self)
            UIApplication.shared.delegate?.window??.bringSubview(toFront: self)
        }
        self.icon = icon
        self.tapEventBlock = tapEvent
        if let size = size, size != CGSize.zero {
            self.frame = CGRect(x: UIScreen.main.bounds.size.width - size.width, y: UIScreen.main.bounds.size.height/2, width: size.width, height: size.height)
        } else {
            self.frame = CGRect(x: UIScreen.main.bounds.size.width - 44, y: UIScreen.main.bounds.size.height/2, width: 44, height: 44)
        }
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panGes(_:))))
        self.setUp()
    }
}

//MARK: - private mothods
extension LoggerAassistant {
 
    func setUp() {
        let opBtn = UIButton.init(type: .custom)
        opBtn.frame = self.bounds
        if let img = icon {
            opBtn.setImage(img, for: .normal)
            opBtn.setBackgroundImage(UIImage(color: .lightGray), for: .normal)
            opBtn.setRoundCorners(borderColor: .lightGray, borderWidth: 1, raddi: 5, corners: .allCorners)
        } else {
            opBtn.setTitle("Logger", for: .normal)
            opBtn.setTitleColor(.systemBlue, for: .normal)
            opBtn.setBackgroundImage(UIImage(color: .lightGray), for: .normal)
            opBtn.setRoundCorners()
        }
        opBtn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        self.addSubview(opBtn)
    }
}

//MARK: - call backs
extension LoggerAassistant {
    
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
                var rx = min(screenW - self.width/2, ePoint.x)
                rx = max(self.width/2, rx)
                var ry = min(screenH - self.height/2, ePoint.y)
                ry = max(self.height/2, ry)
                
                if rx < screenW/2 {
                    if ry < screenH/2 {
                        if rx < ry {
                            rx = self.width/2
                        } else {
                            ry = self.height/2
                        }
                    } else {
                        if rx < screenH - ry {
                            rx = self.width/2
                        } else {
                            ry = screenH - self.height/2
                        }
                    }
                } else {
                    if ry < screenH/2 {
                        if screenW - rx < ry {
                            rx = screenW - self.width/2
                        } else {
                            ry = self.height/2
                        }
                    } else {
                        if screenW - rx < screenH - ry {
                            rx = screenW - self.width/2
                        } else {
                            ry = screenH - self.height/2
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

//MARK: - delegate or data source
extension LoggerAassistant {
    
}

//MARK: - other classes
