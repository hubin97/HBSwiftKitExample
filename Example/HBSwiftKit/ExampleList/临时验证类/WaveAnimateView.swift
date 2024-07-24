//
//  WaveAnimateView.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/5/28.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class WaveAnimateView: UIView {
    
    /// 振幅
    var amp: CGFloat = 5.0
    /// 角速度
    var omega: CGFloat = 1.0
    /// 初相
    var phi: CGFloat = 0.0
    /// 偏距
    var offset: CGFloat = 10.0
    /// 移动速度
    var speed: CGFloat = 2
    /// 绘制线程
    var displayLink: CADisplayLink!
    /// 填充颜色
    var fillColor: UIColor = .systemBlue
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        self.omega = Double.pi * 2 / bounds.width
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// value 0 ~ 1
    @objc func displayLine() {
        phi -= speed * omega
        setNeedsDisplay()
    }
    
    func refresh(_ value: CGFloat, speed: CGFloat = 2, amp: CGFloat = 5) {
        assert(value >= 0 && value <= 1, "value >= 0, value <= 1")
        self.phi = 0
        self.speed = speed
        self.amp = amp
        self.offset = (1 - value) * bounds.height
        self.displayLink = CADisplayLink(target: self, selector: #selector(displayLine))
        self.displayLink.add(to: RunLoop.main, forMode: .common)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        // 初始化运动路径 CGMutablePathRef
        let path = CGMutablePath()
        // 设置起始位置
        path.move(to: CGPoint(x: 0, y: bounds.height))
        // 正弦曲线公式为：y = Asin(ωx + φ) + k;
        for x in stride(from: CGFloat(0.0), through: bounds.width, by: 1.0) {
            let y = amp * sin(omega * x + phi) + offset
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.closeSubpath()
        
        // 绘制曲线
        context.setFillColor(fillColor.cgColor)
        context.setLineWidth(0.5)
        context.addPath(path)
        context.fillPath()
    }
}
