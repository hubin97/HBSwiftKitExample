//
//  SignalPlateView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/12/7.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit
import HBSwiftKit

// MARK: - global var and methods

// MARK: - main class
class SignalPlateView: UIView {

    lazy var maxRingView: UIImageView = {
        let size: CGFloat = kScaleW(300)
        let _maxRingView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        _maxRingView.image = UIImage(named: R.image.ring_max.name)
        return _maxRingView
    }()

    lazy var midRingView: UIImageView = {
        let size: CGFloat = kScaleW(270)
        let _midRingView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        _midRingView.center = maxRingView.center
        _midRingView.image = UIImage(named: R.image.ring_mid.name)
        return _midRingView
    }()

    lazy var minRingView: UIImageView = {
        let size: CGFloat = kScaleW(240)
        let _minRingView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        _minRingView.center = maxRingView.center
        _minRingView.image = UIImage(named: R.image.ring_min.name)
        return _minRingView
    }()

    lazy var signalPlateView: UIImageView = {
        let size: CGFloat = kScaleW(200)
        let _signalPlateView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        _signalPlateView.center = maxRingView.center
        _signalPlateView.image = UIImage(named: R.image.signalplate.name)
        return _signalPlateView
    }()

    lazy var signalPointerView: UIImageView = {
        let size: CGFloat = kScaleW(150)
        let _signalPointerView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        _signalPointerView.center = maxRingView.center
        _signalPointerView.image = UIImage(named: R.image.signalpointer.name)
        return _signalPointerView
    }()

    /// 标记是否处于动画中
    var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(maxRingView)
        self.addSubview(midRingView)
        self.addSubview(minRingView)
        self.addSubview(signalPlateView)
        self.addSubview(signalPointerView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension SignalPlateView {

    /// 开启循环旋转动画
    /// - Parameters:
    ///   - view: 应用视图
    ///   - clockwise: 是否顺时针
    ///   - duration: 周期时长
    func repeatCabRotationAnimation(_ view: UIView, _ clockwise: Bool, _ duration: CFTimeInterval, _ totaltime: CFTimeInterval? = nil) {
        let transformView = CABasicAnimation(keyPath: "transform.rotation.z")
        transformView.fromValue = clockwise ? 0 : Double.pi * 2
        transformView.toValue = clockwise ? Double.pi * 2 : 0
        transformView.duration = duration
        if let time = totaltime {
            transformView.repeatCount = Float(time/duration)
        } else {
            transformView.repeatCount = MAXFLOAT
        }
        transformView.isRemovedOnCompletion = false
        transformView.fillMode = .forwards
        transformView.timingFunction = CAMediaTimingFunction(name: .linear)
        view.layer.add(transformView, forKey: "rotationAnimation")
    }

    /// 循环摇摆动效
    /// - Parameters:
    ///   - view: 应用视图
    ///   - duration: 周期
    func repeatCabSwingAnimation(_ view: UIView, _ duration: CFTimeInterval, _ totaltime: CFTimeInterval? = nil) {
        let transformView = CAKeyframeAnimation(keyPath: "transform.rotation")
        transformView.values = [-Double.pi/4, Double.pi/6, -Double.pi/2, 0, Double.pi/2]
        transformView.keyTimes = [0, 0.28, 0.43, 0.72, 1]
        transformView.duration = duration
        if let time = totaltime {
            // 考虑到autoreverses, 所以此处结果再除2
            transformView.repeatCount = Float(time/duration/2)
        } else {
            transformView.repeatCount = MAXFLOAT
        }
        transformView.isRemovedOnCompletion = false
        transformView.fillMode = .forwards
        transformView.autoreverses = true
        transformView.timingFunction = CAMediaTimingFunction(name: .linear)
        view.layer.add(transformView, forKey: "swingAnimation")
    }
}

// MARK: - call backs
extension SignalPlateView {

    /// 开启动画
    /// - Parameters:
    ///   - totalTime: 总耗时
    ///   - completeHandle: 完成回调
    func startAnimate(_ totalTime: CFTimeInterval = 20, completeHandle: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            completeHandle?()
        }
        isAnimating = true
        repeatCabRotationAnimation(maxRingView, true, 3, totalTime)
        repeatCabRotationAnimation(midRingView, true, 2, totalTime)
        repeatCabRotationAnimation(minRingView, true, 1, totalTime)
        repeatCabSwingAnimation(signalPointerView, 3.5, totalTime)
    }

    /// 设定最后角度
    /// - Parameter value: 0 ~ pi*26/18
    func resultAngle(_ value: CGFloat) {
        guard isAnimating == true else { return }
        self.isAnimating = false
        self.removeAllAnimate()
        UIView.animate(withDuration: 1) {
            let rAngle = CGFloat.pi * 13/18 - value
            self.signalPointerView.transform = CGAffineTransform.init(rotationAngle: rAngle)
        }
    }

    func removeAllAnimate() {
        maxRingView.layer.removeAllAnimations()
        midRingView.layer.removeAllAnimations()
        minRingView.layer.removeAllAnimations()
        signalPointerView.layer.removeAllAnimations()
    }
}

// MARK: - delegate or data source
extension SignalPlateView {
}

// MARK: - other classes
