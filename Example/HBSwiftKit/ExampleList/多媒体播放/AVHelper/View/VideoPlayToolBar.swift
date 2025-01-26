//
//  VideoPlayToolBar.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/30.

import Foundation
import AVFoundation

// MARK: - global var and methods
protocol VideoPlayToolBarDelegate: AnyObject {
    func playToolBar(_ toolBar: VideoPlayToolBar, playAction: Bool)
    func playToolBar(_ toolBar: VideoPlayToolBar, previousAction: Bool)
    func playToolBar(_ toolBar: VideoPlayToolBar, nextAction: Bool)
    
    func playToolBar(_ toolBar: VideoPlayToolBar, scaleAction: Bool)
    func playToolBar(_ toolBar: VideoPlayToolBar, rotateAction: Bool)

    func playToolBar(_ toolBar: VideoPlayToolBar, touchesBegan sliderValue: Float)
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesMoved sliderValue: Float)
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesEnded sliderValue: Float)
}

extension VideoPlayerViewDelegate {
    func playToolBar(_ toolBar: VideoPlayToolBar, playAction: Bool) {}
    func playToolBar(_ toolBar: VideoPlayToolBar, previousAction: Bool) {}
    func playToolBar(_ toolBar: VideoPlayToolBar, nextAction: Bool) {}
    
    func playToolBar(_ toolBar: VideoPlayToolBar, scaleAction: Bool) {}
    func playToolBar(_ toolBar: VideoPlayToolBar, rotateAction: Bool) {}
    
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesBegan sliderValue: Float) {}
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesMoved sliderValue: Float) {}
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesEnded sliderValue: Float) {}
}

class VideoPlayToolBar: UIView {
    
    weak var delegate: VideoPlayToolBarDelegate?
    
    // 是否正在拖拽
    var isDraging: Bool = false
    
    var config: MediaPlayProgressConfig = MediaPlayProgressConfig() {
        didSet {
            slider.config = config
        }
    }

    // 是否正在播放
    private var isPlaying: Bool = false
    
    lazy var slider: MediaPlayProgress = {
        let _slider = MediaPlayProgress()
        //_slider.thumbImage = UIImage(named: "icon_media_tablet", in: assetsBundle, compatibleWith: nil)
        _slider.thumbImage = UIImage(named: "icon_media_tv", in: assetsBundle, compatibleWith: nil)
        _slider.value = 0
        _slider.bufferedValue = 0
        _slider.delegate = self
        return _slider
    }()
    
    // 当前时间 / 总时长
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .right
        label.textColor = .white
        label.text = "00:00/00:00"
        return label
    }()
    
    // 播放按钮
    lazy var playButton: Button = {
        let button = Button(type: .custom)
        button.setImage(UIImage(named: "icon_media_play", in: assetsBundle, compatibleWith: nil), for: .normal)
        button.setImage(UIImage(named: "icon_media_stop", in: assetsBundle, compatibleWith: nil), for: .selected)
        button.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        return button
    }()
    
    // 上一首
    lazy var previousButton: Button = {
        let button = Button(type: .custom)
        button.setImage(UIImage(named: "icon_media_last", in: assetsBundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(playPreviousAction), for: .touchUpInside)
        return button
    }()
    
    // 下一首
    lazy var nextButton: Button = {
        let button = Button(type: .custom)
        button.setImage(UIImage(named: "icon_play_next_white", in: assetsBundle, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(playNextAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        //bindData()
        //playStateUpdate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(slider)
        addSubview(timeLabel)
        addSubview(playButton)
        addSubview(nextButton)
    }
    
    @objc func playAction() {
        playButton.isSelected.toggle()
        delegate?.playToolBar(self, playAction: playButton.isSelected)
    }
    @objc func playPreviousAction() {
        delegate?.playToolBar(self, previousAction: true)
    }
    @objc func playNextAction() {
        delegate?.playToolBar(self, nextAction: true)
    }
    
    /// 更新缓冲进度
    func updateBufferValue(_ bufferValue: Float) {
        // slider.bufferedValue = bufferValue
    }
    
    /// 更新音频播放进度信息
    func updateToolBar(with item: AVPlaylistItem) {
        guard let player = AVPlayerManager.shared.getPlayer(),  let playerItem = player.currentItem else {
            // 未初始化音频信息
            let duration = item.mediaMeta?.duration ?? 0
            let total = Int(duration)
            slider.value = 0
            timeLabel.text = String(format: "%02d:%02d", 0, 0) + "/" + String(format: "%02d:%02d", total / 60, total % 60)
            return
        }
        
        // 校验有效
        let isValideDuration = playerItem.duration.isValid && !playerItem.duration.seconds.isNaN
        guard isValideDuration else { return }
        
        let duration = playerItem.duration.seconds
        let currentTime = player.currentTime().seconds
        let total = Int(item.mediaMeta?.duration ?? duration)
        
        let current = Int(currentTime)
        slider.value = Float(current)/Float(total)
        timeLabel.text = String(format: "%02d:%02d", current / 60, current % 60) + "/" + String(format: "%02d:%02d", total / 60, total % 60)
    }
    
    /// 拖拽时更新进度
    func updatePlayPregress(with sliderValue: Float) {
        guard let currentItem = AVPlayerManager.shared.getPlaylist()?.getCurrentItem() else { return }
        let duration = currentItem.mediaMeta?.duration ?? 0
        let total = Int(duration)
        let current = Int(Float(total) * sliderValue)
        slider.value = sliderValue
        timeLabel.text = String(format: "%02d:%02d", current / 60, current % 60) + "/" + String(format: "%02d:%02d", total / 60, total % 60)
    }
    
    /// 更新播放状态
    func updatePlayStatus() {
        guard let player = AVPlayerManager.shared.getPlayer() else { return }
        switch player.timeControlStatus {
        case .waitingToPlayAtSpecifiedRate:
            LogM.debug("wait...")
        case .playing:
            playButton.isSelected = true
        case .paused:
            playButton.isSelected = false
        default:
            playButton.isSelected = false
        }
    }
}

extension VideoPlayToolBar: MediaPlayProgressDelegate {
    
    func playProgress(_ progress: MediaPlayProgress, touchesBegan value: Float) {
        isDraging = true
        //slider.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        //slider.config.cornerRadius = slider.config.progressHeight * 1.5/2
        delegate?.playToolBar(self, touchesBegan: value)
    }
    
    func playProgress(_ progress: MediaPlayProgress, touchesMoved value: Float) {
        isDraging = true
        delegate?.playToolBar(self, touchesMoved: value)
    }
    
    func playProgress(_ progress: MediaPlayProgress, touchesEnded value: Float) {
        isDraging = false
        slider.transform = CGAffineTransform.identity
        slider.config.cornerRadius = slider.config.progressHeight/2
        delegate?.playToolBar(self, touchesEnded: value)
    }
}

// MARK: - 竖屏工具栏
class VideoPlayVerticalToolBar: VideoPlayToolBar {
    
    lazy var scaleButton: UIButton = {
        let _scaleButton = UIButton(type: .custom)
        _scaleButton.setImage(UIImage(named: "icon_maxmize", in: assetsBundle, compatibleWith: nil), for: .normal)
        _scaleButton.setImage(UIImage(named: "icon_minmize", in: assetsBundle, compatibleWith: nil), for: .selected)
        _scaleButton.addTarget(self, action: #selector(scaleAction), for: .touchUpInside)
        return _scaleButton
    }()
    
    lazy var rotateButton: UIButton = {
        let _rotateButton = UIButton(type: .custom)
        _rotateButton.setImage(UIImage(named: "icon_video_rotate", in: assetsBundle, compatibleWith: nil), for: .normal)
        _rotateButton.addTarget(self, action: #selector(rotateAction), for: .touchUpInside)
        return _rotateButton
    }()
    
    @objc func scaleAction() {
        delegate?.playToolBar(self, scaleAction: true)
    }
    
    @objc func rotateAction() {
        delegate?.playToolBar(self, rotateAction: true)
    }
}

// 竖屏 16:9  1  back 40 toolbar 44  / toolbar 70 / 全屏也是 70
class HalfVerticalToolBar: VideoPlayVerticalToolBar {
    
    override func setupLayout() {
        addSubview(playButton)
        addSubview(slider)
        addSubview(scaleButton)
        addSubview(rotateButton)
         
        scaleButton.isSelected = false
        playButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        rotateButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        scaleButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(rotateButton.snp.leading).offset(-10)
            make.width.height.equalTo(44)
            make.centerY.equalTo(rotateButton)
        }
        slider.snp.makeConstraints { (make) in
            make.leading.equalTo(playButton.snp.trailing).offset(20)
            make.trailing.equalTo(scaleButton.snp.leading).offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}

class FullVerticalToolBar: VideoPlayVerticalToolBar {
 
    override func setupLayout() {
        addSubview(slider)
        addSubview(scaleButton)
        addSubview(rotateButton)
         
        scaleButton.isSelected = true
        slider.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        rotateButton.snp.makeConstraints { (make) in
            make.top.equalTo(slider.snp.bottom)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(44)
        }
        scaleButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(rotateButton.snp.leading).offset(-10)
            make.width.height.equalTo(44)
            make.centerY.equalTo(rotateButton)
        }
    }
}

// MARK: - 水平工具栏
class VideoPlayHorizontalToolBar: VideoPlayToolBar {
 
    override func setupLayout() {
        addSubview(playButton)
        addSubview(slider)
        
        slider.snp.makeConstraints { (make) in
            make.top.equalToSuperview()//.offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        playButton.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom)//.offset(6)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(44)
        }
    }
}
