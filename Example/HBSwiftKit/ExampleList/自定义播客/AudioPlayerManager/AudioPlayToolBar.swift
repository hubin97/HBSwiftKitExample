//
//  AudioPlayToolBar.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import SnapKit
import AVFoundation

// MARK: - global var and methods
protocol AudioPlayToolBarDelegate: AnyObject {
    func playToolBar(_ toolBar: AudioPlayToolBar, isPlaying: Bool)
    func playToolBar(_ toolBar: AudioPlayToolBar, sliderValueChanged: Float)
    func playToolBar(_ toolBar: AudioPlayToolBar, previousAction: Bool)
    func playToolBar(_ toolBar: AudioPlayToolBar, nextAction: Bool)
    func playToolBar(_ toolBar: AudioPlayToolBar, isDragging: Bool, sliderValue: Float)
}

// MARK: - main class
class AudioPlayToolBar: UIView {
    
    weak var delegate: AudioPlayToolBarDelegate?
    
    // 是否正在播放
    private var isPlaying: Bool = false
    // 进度条 UISlider
    private lazy var slider: UISlider = {
        let _slider = UISlider()
        _slider.minimumValue = 0
        _slider.maximumValue = 1
        _slider.value = 0
        _slider.minimumTrackTintColor = .white
        _slider.maximumTrackTintColor = .gray
        _slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        // 添加触摸事件监听
        _slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        _slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        // 添加点击手势 用于点击滑动
        _slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
        return _slider
    }()
    
    // 当前时间
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "00:00"
        return label
    }()
    
    // 总时长
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        label.textColor = .white
        label.text = "00:00"
        return label
    }()
    
    // 播放按钮
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.icon_track_play(), for: .normal)
        button.setImage(R.image.icon_track_pause(), for: .selected)
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    // 上一首
    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.icon_track_last(), for: .normal)
        button.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        return button
    }()
    
    // 下一首
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.icon_track_next(), for: .normal)
        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        backgroundColor = .white
        addSubview(slider)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(playButton)
        addSubview(previousButton)
        addSubview(nextButton)
        
        slider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(35)
            make.top.equalToSuperview()//.offset(10)
            make.height.equalTo(56)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(slider)
            make.bottom.equalTo(slider.snp.bottom)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(slider)
            make.centerY.equalTo(currentTimeLabel)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
            make.top.equalTo(slider.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(10)
        }
        
        previousButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(playButton.snp.leading).offset(-45)
            make.width.height.equalTo(40)
            make.centerY.equalTo(playButton)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.leading.equalTo(playButton.snp.trailing).offset(45)
            make.width.height.equalTo(previousButton)
            make.centerY.equalTo(playButton)
        }
    }
}

// MARK: - private mothods
extension AudioPlayToolBar {
    
    /// 初始化音频播放进度信息
    func setupAudioInfo(with audioPlayer: AVPlayer?, audioTrack: AudioTrack) {
        /**
         po audioPlayer?.currentItem?.duration.seconds
        ▿ Optional<Double>
          - some : nan
         */
        let duration = audioPlayer?.currentItem?.duration.seconds ?? 0
        let total = Int(audioTrack.metaData?.duration ?? duration)
        
        slider.value = 0
        currentTimeLabel.text = String(format: "%02d:%02d", 0, 0)
        totalTimeLabel.text = String(format: "%02d:%02d", total / 60, total % 60)
    }
    
    /// 更新音频播放进度信息
    func updatePlayInfo(with audioPlayer: AVPlayer, audioTrack: AudioTrack) {
        let duration = audioPlayer.currentItem?.duration.seconds ?? 0
        let currentTime = audioPlayer.currentTime().seconds
        let total = Int(audioTrack.metaData?.duration ?? duration)

        let current = Int(currentTime)
        slider.value = Float(current)/Float(total)
        currentTimeLabel.text = String(format: "%02d:%02d", current / 60, current % 60)
        totalTimeLabel.text = String(format: "%02d:%02d", total / 60, total % 60)
        playButton.isSelected = audioTrack.isPlaying
    }
}

// MARK: - call backs
extension AudioPlayToolBar {
    
    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: slider)
        let percentage = point.x / slider.bounds.width
        let delta = Float(percentage) * (slider.maximumValue - slider.minimumValue)
        slider.value = slider.minimumValue + delta
        sliderValueChanged()
    }
    
    @objc func sliderValueChanged() {
        delegate?.playToolBar(self, sliderValueChanged: slider.value)
    }
    
    @objc func sliderTouchDown() {
        delegate?.playToolBar(self, isDragging: true, sliderValue: slider.value)
    }
    
    @objc func sliderTouchUp() {
        delegate?.playToolBar(self, isDragging: false, sliderValue: slider.value)
    }
    
    @objc func playAction() {
        isPlaying.toggle()
        playButton.isSelected = isPlaying
        delegate?.playToolBar(self, isPlaying: isPlaying)
    }
    
    @objc func previousAction() {
        delegate?.playToolBar(self, previousAction: true)
    }
    
    @objc func nextAction() {
        delegate?.playToolBar(self, nextAction: true)
    }
}

// MARK: - delegate or data source
extension AudioPlayToolBar { 
}

// MARK: - other classes
