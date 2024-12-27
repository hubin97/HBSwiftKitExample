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
    func playToolBar(_ toolBar: AudioPlayToolBar, previousAction: Bool)
    func playToolBar(_ toolBar: AudioPlayToolBar, nextAction: Bool)
    
    func playToolBar(_ toolBar: AudioPlayToolBar, touchesBegan sliderValue: Float)
    func playToolBar(_ toolBar: AudioPlayToolBar, touchesMoved sliderValue: Float)
    func playToolBar(_ toolBar: AudioPlayToolBar, touchesEnded sliderValue: Float)
}

// MARK: - main class
class AudioPlayToolBar: UIView {
    
    weak var delegate: AudioPlayToolBarDelegate?
    
    // 是否正在播放
    private var isPlaying: Bool = false
    // 进度条 UISlider
//    private lazy var slider: UISlider = {
//        let _slider = UISlider()
//        _slider.minimumValue = 0
//        _slider.maximumValue = 1
//        _slider.value = 0
//        _slider.minimumTrackTintColor = Colors.gray
//        _slider.maximumTrackTintColor = Colors.gray4
//        _slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
//        // 添加触摸事件监听
//        _slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
//        _slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
//        // 添加点击手势 用于点击滑动
//        _slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:))))
//        return _slider
//    }()
    
    var config: AudioPlayProgressConfig = AudioPlayProgressConfig() {
        didSet {
            slider.config = config
        }
    }

    private lazy var slider: AudioPlayProgress = {
        let _slider = AudioPlayProgress()
        _slider.value = 0
        _slider.bufferedValue = 0
        _slider.delegate = self
        return _slider
    }()
    
    // 当前时间
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.textColor = .lightGray
        label.text = "00:00"
        return label
    }()
    
    // 总时长
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .right
        label.textColor = .lightGray
        label.text = "00:00"
        return label
    }()
    
    // 播放按钮
    private lazy var playButton: Button = {
        let button = Button(type: .custom)
        button.setImage(R.image.icon_audio_tool_play(), for: .normal)
        button.setImage(R.image.icon_audio_tool_stop(), for: .selected)
        //button.setImage(R.image.icon_audio_tool_wait(), for: .disabled)
        //button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    // 等待动画
    private lazy var waitAnimation: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.icon_audio_tool_wait()
        imageView.isHidden = true
        return imageView
    }()
    
    // 上一首
    private lazy var previousButton: Button = {
        let button = Button(type: .custom)
        button.setImage(R.image.icon_audio_tool_last(), for: .normal)
        //button.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        return button
    }()
    
    // 下一首
    private lazy var nextButton: Button = {
        let button = Button(type: .custom)
        button.setImage(R.image.icon_audio_tool_next(), for: .normal)
        //button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupLayout()
        bindData()
        //playStateUpdate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        backgroundColor = .white
        addSubview(slider)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(waitAnimation)
        addSubview(playButton)
        addSubview(previousButton)
        addSubview(nextButton)
        
        slider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(35)
            make.top.equalToSuperview()//.offset(10)
            make.height.equalTo(30)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(slider)
            make.top.equalTo(slider.snp.bottom)//.offset(10)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(slider)
            make.centerY.equalTo(currentTimeLabel)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
            make.top.equalTo(currentTimeLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(10)
        }
        
        waitAnimation.snp.makeConstraints { (make) in
            make.center.equalTo(playButton)
            make.width.height.equalTo(playButton)
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
    
    func bindData() {
        playButton.rx_throttledTap().subscribe(onNext: { [weak self] in
            self?.playAction()
        }).disposed(by: rx.disposeBag)
        
        previousButton.rx_throttledTap().subscribe(onNext: { [weak self] in
            self?.previousAction()
        }).disposed(by: rx.disposeBag)
        
        nextButton.rx_throttledTap().subscribe(onNext: { [weak self] in
            self?.nextAction()
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - private mothods
extension AudioPlayToolBar {
    
    /// 播放状态更新
//    func playStateUpdate() {
//        AudioPlayerManager.shared.onAudioPlayerPlayStatusChange({[weak self] _, status in
//            self?.updatePlayStatus(status)
//        })
//    }
    
    /// 初始化音频播放进度信息
    func setupAudioInfo(audioTrack: AudioTrack) {
        // 1.已有音频信息 2.且初始化音频信息即当前的音频信息
        if let audioPlayer = AudioPlayerManager.shared.audioPlayer, audioPlayer.currentItem != nil, AudioPlayerManager.shared.currentTrack == audioTrack {
            // 同步进度
            self.updatePlayInfo(with: audioPlayer, audioTrack: audioTrack)
        } else {
            // 未初始化音频信息
            guard let duration = audioTrack.metaData?.duration else { return }
            let total = Int(duration/1000)
            slider.value = 0
            currentTimeLabel.text = String(format: "%02d:%02d", 0, 0)
            totalTimeLabel.text = String(format: "%02d:%02d", total / 60, total % 60)
        }
    }
    
    /// 更新音频播放进度信息
    func updatePlayInfo(with audioPlayer: AVPlayer, audioTrack: AudioTrack) {
        guard let currentItem = audioPlayer.currentItem else { return }
        let isValideDuration = currentItem.duration.isValid && !currentItem.duration.seconds.isNaN
        guard isValideDuration else { return }

        let duration = currentItem.duration.seconds
        let currentTime = audioPlayer.currentTime().seconds
        let total = Int(audioTrack.metaData?.duration ?? duration)

        let current = Int(currentTime)
        slider.value = Float(current)/Float(total)
        currentTimeLabel.text = String(format: "%02d:%02d", current / 60, current % 60)
        totalTimeLabel.text = String(format: "%02d:%02d", total / 60, total % 60)
        //playButton.isSelected = audioTrack.playState == .playing
    }
    
    /// 拖拽时更新进度
    func updatePlayInfo(with sliderValue: Float, audioTrack: AudioTrack) {
        guard let duration = audioTrack.metaData?.duration else { return }
        let total = Int(duration)
        let current = Int(Float(total) * sliderValue)
        slider.value = sliderValue
        currentTimeLabel.text = String(format: "%02d:%02d", current / 60, current % 60)
    }
    
    /// 更新缓冲进度
    func updateBufferValue(_ bufferValue: Float) {
        slider.bufferedValue = bufferValue
    }
    
    /// 更新播放状态
    func updatePlayStatus(_ status: AudioTrack.PlayState) {
        switch status {
        case .loading:
            playButton.isHidden = true
            waitAnimation.isHidden = false
            startRotationAnimation()
        case .playing:
            stopRotationAnimation()
            isPlaying = true
            waitAnimation.isHidden = true
            playButton.isHidden = false
            playButton.isSelected = true
        case .paused:
            isPlaying = false
            stopRotationAnimation()
            waitAnimation.isHidden = true
            playButton.isHidden = false
            playButton.isSelected = false
        }
    }
}

extension AudioPlayToolBar {
    
    func startRotationAnimation() {
        // 创建一个基础的旋转动画
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0  // 起始角度
        rotation.toValue = CGFloat.pi * 2  // 结束角度（2π，表示一圈）
        rotation.duration = 1  // 动画持续时间
        rotation.repeatCount = .infinity  // 无限循环
        rotation.isRemovedOnCompletion = false  // 动画完成后不移除
        
        // 添加动画到视图的图层
        waitAnimation.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopRotationAnimation() {
        // 停止动画时，手动设置视图的角度回到初始状态
        waitAnimation.layer.removeAnimation(forKey: "rotationAnimation")
        
        // 通过设置 transform.rotation 恢复到初始角度
        waitAnimation.layer.transform = CATransform3DIdentity
    }
}

// MARK: - call backs
extension AudioPlayToolBar {
    
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
extension AudioPlayToolBar: AudioPlayProgressDelegate {
    
    func audioPlayProgress(_ progress: AudioPlayProgress, touchesBegan value: Float) {
        slider.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        slider.config.cornerRadius = slider.config.progressHeight * 1.5/2
        delegate?.playToolBar(self, touchesBegan: value)
    }
    
    func audioPlayProgress(_ progress: AudioPlayProgress, touchesMoved value: Float) {
        delegate?.playToolBar(self, touchesMoved: value)
    }
    
    func audioPlayProgress(_ progress: AudioPlayProgress, touchesEnded value: Float) {
        slider.transform = CGAffineTransform.identity
        slider.config.cornerRadius = slider.config.progressHeight/2
        delegate?.playToolBar(self, touchesEnded: value)
    }
}
