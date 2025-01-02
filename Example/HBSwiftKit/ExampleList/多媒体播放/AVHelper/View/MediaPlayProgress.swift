//
//  MediaPlayProgress.swift
//  Momcozy
//
//  Created by hubin.h on 2024/12/16.
//  Copyright © 2024 路特创新. All rights reserved.

import Foundation
import UIKit

struct MediaPlayProgressConfig {
    var trackTintColor: UIColor = .lightGray
    var bufferTintColor: UIColor = .darkGray
    var progressTintColor: UIColor = .white
    var progressHeight: CGFloat = 6
    var cornerRadius: CGFloat = 3
}

protocol MediaPlayProgressDelegate: AnyObject {
    func playProgress(_ progress: MediaPlayProgress, touchesBegan value: Float)
    func playProgress(_ progress: MediaPlayProgress, touchesMoved value: Float)
    func playProgress(_ progress: MediaPlayProgress, touchesEnded value: Float)
}

// MARK: - main class
class MediaPlayProgress: UIControl {
    
    enum TouchEvent {
        case began
        case moved
        case ended
    }
    
    // 当前进度值
    var value: Float = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // 缓冲进度
    var bufferedValue: Float = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // 最小值和最大值
    var minimumValue: Float = 0.0
    var maximumValue: Float = 1.0
    
    // 配置属性
    var config: MediaPlayProgressConfig = MediaPlayProgressConfig() {
        didSet {
            progressTrackView.backgroundColor = config.trackTintColor
            progressBufferView.backgroundColor = config.bufferTintColor
            progressTintView.backgroundColor = config.progressTintColor
            
            progressTrackView.layer.cornerRadius = config.cornerRadius
            progressBufferView.layer.cornerRadius = config.cornerRadius
            progressTintView.layer.cornerRadius = config.cornerRadius
        }
    }
    
    // 滑块图像
    var thumbImage: UIImage? {
        didSet {
            thumbImageView.image = thumbImage
        }
    }
    
    weak var delegate: MediaPlayProgressDelegate?
    // 创建视图组件
    private let progressTrackView = UIView()
    private let progressBufferView = UIView()
    private let progressTintView = UIView()
    private let thumbImageView = UIImageView()

    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // 设置UI
    private func setupUI() {
        // 偏移量
        let originY = (bounds.height - config.progressHeight) / 2
        let pFrame = CGRect(x: 0, y: originY, width: bounds.width, height: config.progressHeight)
        
        // 设置进度条背景
        progressTrackView.frame = pFrame
        addSubview(progressTrackView)
        
        // 设置缓冲进度
        progressBufferView.frame = pFrame
        addSubview(progressBufferView)
        
        // 设置当前进度
        progressTintView.frame = pFrame
        addSubview(progressTintView)
        
        // 初始化滑块视图
        thumbImageView.contentMode = .scaleAspectFit
        addSubview(thumbImageView)
        
        // 初始化时使用默认的配置
        config = MediaPlayProgressConfig()
    }
}

// MARK: - private mothods
extension MediaPlayProgress {
    
    // 绘制进度条
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 偏移量
        let originY = (bounds.height - config.progressHeight) / 2

        // 轨道
        progressTrackView.frame = CGRect(x: 0, y: originY, width: bounds.width, height: config.progressHeight)

        // 缓冲进度
        let bufferedWidth = CGFloat((bufferedValue - minimumValue) / (maximumValue - minimumValue)) * bounds.width
        progressBufferView.frame = CGRect(x: 0, y: originY, width: bufferedWidth, height: config.progressHeight)
        
        // 当前播放进度
        let progressWidth = CGFloat((value - minimumValue) / (maximumValue - minimumValue)) * bounds.width
        progressTintView.frame = CGRect(x: 0, y: originY, width: progressWidth, height: config.progressHeight)
    }
    
    // 更新进度值
    private func updateValue(for touches: Set<UITouch>, touchEvent: TouchEvent) {
        guard let touch = touches.first else { return }
        
        // 获取触摸点相对视图的位置
        let location = touch.location(in: self)
        
        // 根据触摸位置计算新的值
        let newValue = Float(location.x / bounds.width) * (maximumValue - minimumValue) + minimumValue
        
        // 限制值在最小值和最大值之间
        value = min(max(newValue, minimumValue), maximumValue)

        // 触发值变化事件
        switch touchEvent {
        case .began:
            delegate?.playProgress(self, touchesBegan: value)
        case .moved:
            delegate?.playProgress(self, touchesMoved: value)
        case .ended:
            delegate?.playProgress(self, touchesEnded: value)
        }
    }
    
    // 设置缓冲进度
    func setBufferedValue(_ value: Float) {
        bufferedValue = min(max(value, minimumValue), maximumValue)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新滑块位置
        updateThumbPosition()
    }
    
    // 更新滑块位置
    private func updateThumbPosition() {
        guard let thumbImage = thumbImage else { return }
        
        // 计算滑块位置
        let progressWidth = CGFloat((value - minimumValue) / (maximumValue - minimumValue)) * bounds.width
        let thumbSize = thumbImage.size
        let thumbX = progressWidth - thumbSize.width / 2
        let thumbY = (bounds.height - thumbSize.height) / 2
        
        // 更新滑块视图
        thumbImageView.frame = CGRect(x: thumbX, y: thumbY, width: thumbSize.width, height: thumbSize.height)
    }
}

// MARK: - call backs
extension MediaPlayProgress {
    
    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateValue(for: touches, touchEvent: .began)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updateValue(for: touches, touchEvent: .moved)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updateValue(for: touches, touchEvent: .ended)
    }
}

// MARK: - delegate or data source
extension MediaPlayProgress { 
}

// MARK: - other classes
