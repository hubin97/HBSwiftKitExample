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
        _slider.thumbImage = R.image.star_select()
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
        return button
    }()
    
    // 上一首
    lazy var previousButton: Button = {
        let button = Button(type: .custom)
        button.setImage(UIImage(named: "icon_media_last", in: assetsBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    // 下一首
    lazy var nextButton: Button = {
        let button = Button(type: .custom)
        button.setImage(UIImage(named: "icon_media_next", in: assetsBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: CGRect.zero)
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
        
        playButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        slider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
//    func bindData() {
//        playButton.rx_throttledTap().subscribe(onNext: { [weak self] in
//            //self?.playAction()
//        }).disposed(by: rx.disposeBag)
//        
//        nextButton.rx_throttledTap().subscribe(onNext: { [weak self] in
//            //self?.nextAction()
//        }).disposed(by: rx.disposeBag)
//    }
    
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
//        switch player.timeControlStatus {
//        case .waitingToPlayAtSpecifiedRate:
//            playButton.isHidden = true
//            waitAnimation.isHidden = false
//            startRotationAnimation()
//        case .playing:
//            stopRotationAnimation()
//            isPlaying = true
//            waitAnimation.isHidden = true
//            playButton.isHidden = false
//            playButton.isSelected = true
//        case .paused:
//            isPlaying = false
//            stopRotationAnimation()
//            waitAnimation.isHidden = true
//            playButton.isHidden = false
//            playButton.isSelected = false
//        default:
//            isPlaying = false
//            stopRotationAnimation()
//            waitAnimation.isHidden = true
//            playButton.isHidden = false
//            playButton.isSelected = false
//        }
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
        _scaleButton.setImage(UIImage(named: "icon_screen_small", in: assetsBundle, compatibleWith: nil), for: .normal)
        _scaleButton.addTarget(self, action: #selector(scaleAction), for: .touchUpInside)
        return _scaleButton
    }()
    
    lazy var rotateButton: UIButton = {
        let _rotateButton = UIButton(type: .custom)
        _rotateButton.setImage(UIImage(named: "icon_screen_rotate", in: assetsBundle, compatibleWith: nil), for: .normal)
        _rotateButton.addTarget(self, action: #selector(rotateAction), for: .touchUpInside)
        return _rotateButton
    }()
    
    override func setupLayout() {
        addSubview(slider)
        addSubview(scaleButton)
        addSubview(rotateButton)
         
        slider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()//.inset(35)
            make.top.equalToSuperview()//.offset(10)
            make.height.equalTo(30)
        }
 
        rotateButton.snp.makeConstraints { (make) in
            make.top.equalTo(slider.snp.bottom)
            make.leading.equalTo(scaleButton.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(30)
        }
        
        scaleButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerY.equalTo(rotateButton)
        }
    }
    
    @objc func scaleAction() {
        delegate?.playToolBar(self, scaleAction: true)
    }
    
    @objc func rotateAction() {
        delegate?.playToolBar(self, rotateAction: true)
    }
}

// MARK: - 水平工具栏
class VideoPlayHorizontalToolBar: VideoPlayToolBar {
 
    override func setupLayout() {
        addSubview(slider)
//        addSubview(scaleButton)
//        addSubview(rotateButton)
         
        slider.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()//.inset(35)
            make.top.equalToSuperview()//.offset(10)
            make.height.equalTo(30)
        }
 
//        rotateButton.snp.makeConstraints { (make) in
//            make.top.equalTo(slider.snp.bottom)
//            make.leading.equalTo(scaleButton.snp.trailing).offset(20)
//            make.trailing.equalToSuperview().inset(20)
//            make.width.height.equalTo(30)
//        }
//        
//        scaleButton.snp.makeConstraints { (make) in
//            make.width.height.equalTo(30)
//            make.centerY.equalTo(rotateButton)
//        }
    }
}
