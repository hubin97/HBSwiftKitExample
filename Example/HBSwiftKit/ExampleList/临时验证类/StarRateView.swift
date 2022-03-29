//
//  StarRateView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2022/2/28.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import UIKit

// MARK: - global var and methods
public protocol StarRateViewDelegate: AnyObject {
    func starRateResult(view: UIView, ratio: Float)
}

// MARK: - main class
public class StarRateView: UIView {

    weak var delegate: StarRateViewDelegate?
    /// 是否支持手势调整
    public var canAjust: Bool = false {
        didSet {
            if canAjust {
                self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGes(_:))))
                self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panGes(_:))))
            }
        }
    }
    /// 星星比例渐变时间
    public var duration: TimeInterval = 0.1

    var starMax: Int = 5
    var rateValue: Float = 0

    lazy var backView: UIView = {
        let _backView = UIView.init(frame: self.bounds)
        _backView.clipsToBounds = true
        return _backView
    }()
    lazy var foreView: UIView = {
        let _foreView = UIView.init(frame: self.bounds)
        _foreView.clipsToBounds = true
        return _foreView
    }()
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backView)
        self.addSubview(foreView)
    }
    public convenience init(frame: CGRect, starMax: Int = 5, rateValue: Float = 0.0, backIcon: String = "star_nomal", foreIcon: String = "star_select") {
        self.init(frame: frame)
        self.starMax = starMax
        self.rateValue = rateValue
        self.drawStarView(for: backView, icon: backIcon)
        self.drawStarView(for: foreView, icon: foreIcon)
        self.updateStarView(by: rateValue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private mothods
extension StarRateView {

    private func drawStarView(for view: UIView, icon: String) {
        let itemWidth = self.bounds.width/CGFloat(starMax)
        let itemHeight = self.bounds.height
        for idx in 0..<starMax {
            let imageView = UIImageView.init(image: UIImage(named: icon))
            imageView.frame = CGRect(x: CGFloat(idx) * itemWidth, y: 0, width: itemWidth, height: itemHeight)
            view.addSubview(imageView)
        }
    }

    @objc func tapGes(_ tap: UITapGestureRecognizer) {
        let offsetX = tap.location(in: self).x
        let ratio = Float(offsetX) / Float(self.bounds.width)
        self.updateStarView(by: ratio)
        self.delegate?.starRateResult(view: self, ratio: ratio)
    }

    @objc func panGes(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed, .ended:
            let offsetX = pan.location(in: self).x
            let ratio = Float(offsetX) / Float(self.bounds.width)
            self.updateStarView(by: ratio)
            self.delegate?.starRateResult(view: self, ratio: ratio)
        default:
            break
        }
    }
}

// MARK: - call backs
extension StarRateView {

    /// 更新星星视图
    /// - Parameter ratio: 比例
    public func updateStarView(by ratio: Float) {
        UIView.animate(withDuration: duration) {
            self.foreView.frame = CGRect(x: 0, y: 0, width: CGFloat(ratio) * self.bounds.width, height: self.bounds.height)
        }
    }
}

// MARK: - delegate or data source
extension StarRateView { }

// MARK: - other classes
