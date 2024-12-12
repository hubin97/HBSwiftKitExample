//
//  PodCastAudioDetailController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class PodCastAudioDetailController: ViewController, ViewModelProvider {
    typealias ViewModelType = PodCastAudioDetailViewModel
    
    // 是否正在拖动进度条
    private var isDragging: Bool = false

    let audioPlayerManager: AudioPlayerManager = {
        return AudioPlayerManager.shared
    }()
    
    // 背景图
    lazy var bgImageView: UIImageView = {
        let _bgImageView = UIImageView()
        _bgImageView.contentMode = .scaleAspectFill
        _bgImageView.clipsToBounds = true
        return _bgImageView
    }()
    
    // 高斯蒙层
    lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return _blurView
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.setImage(R.image.ib_back()?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)
        return _backButton
    }()
    
    // 工具栏
    lazy var toolBar: AudioPlayToolBar = {
        let _toolBar = AudioPlayToolBar()
        _toolBar.backgroundColor = .clear
        _toolBar.delegate = self
        return _toolBar
    }()
    
    override func setupLayout() {
        super.setupLayout()
        view.addSubview(bgImageView)
        view.addSubview(blurView)
        view.addSubview(backButton)
        view.addSubview(toolBar)
        
        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(10)
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }
        toolBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-kBottomSafeHeight)
            //$0.height.equalTo(100)
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        // 默认选择的
        self.bgImageView.image = vm.audioTrack.coverImage
        self.toolBar.setupAudioInfo(with: nil, audioTrack: vm.audioTrack)

        // 未播放时, 没有设置 url, audioPlayer 为空
        // guard let audioPlayer = audioPlayerManager.audioPlayer else { return }
        audioPlayerManager.onAudioTrackSwitch {[weak self] track in
            print("onAudioTrackSwitch: \(track.title ?? "")")
            guard let self = self, let audioPlayer = audioPlayerManager.audioPlayer else { return }
            self.vm.currentTrack = track
            self.bgImageView.image = track.coverImage
            self.toolBar.setupAudioInfo(with: audioPlayer, audioTrack: track)
        }
        audioPlayerManager.onAudioPlayerProgressValueChange {[weak self] track, duration in
            print("onAudioPlayerProgressValueChange: \(track.title ?? ""), duration: \(duration)")
            // 拖动进度条时, 不更新进度
            guard let self = self, let audioPlayer = audioPlayerManager.audioPlayer, track == self.vm.currentTrack, self.isDragging == false else { return }
            self.toolBar.updatePlayInfo(with: audioPlayer, audioTrack: track)
        }
    }
}

// MARK: - private mothods
extension PodCastAudioDetailController { 
}

// MARK: - call backs
extension PodCastAudioDetailController {
    
    @objc func tapBackAction() {
        backAction()
    }
}

// MARK: - delegate or data source
extension PodCastAudioDetailController: AudioPlayToolBarDelegate {
    
    func playToolBar(_ toolBar: AudioPlayToolBar, isPlaying: Bool) {
        if isPlaying {
            audioPlayerManager.playTrack(vm.currentTrack ?? vm.audioTrack)
        } else {
            audioPlayerManager.stopAudio()
        }
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, sliderValueChanged: Float) {
        guard let duration = vm.currentTrack?.duration, duration > 0 else { return }
        let time = TimeInterval(sliderValueChanged) * duration
        audioPlayerManager.seekToPosition(time)
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, previousAction: Bool) {
        audioPlayerManager.previousTrack()
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, nextAction: Bool) {
        audioPlayerManager.nextTrack()
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, isDragging: Bool, sliderValue: Float) {
        self.isDragging = isDragging
        if let audioPlayer = audioPlayerManager.audioPlayer, let currentTrack = vm.currentTrack, !isDragging {
            self.toolBar.updatePlayInfo(with: audioPlayer, audioTrack: currentTrack)
        }
    }
}

// MARK: - other classes
