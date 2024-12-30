//
//  AudioPlayerController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import AVFoundation

// MARK: - global var and methods

// MARK: - main class
class AudioPlayerController: ViewController, ViewModelProvider {
    typealias ViewModelType = AudioPlayerViewModel
    
    lazy var avPlayerManager: AVPlayerManager = {
        return AVPlayerManager.shared
    }()
    
    lazy var player: AVPlayer? = {
        return avPlayerManager.getPlayer()
    }()

    // 返回按钮
    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.setImage(R.image.ib_back()?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)
        return _backButton
    }()
    
    // 背景
    lazy var bgImageView: UIImageView = {
        let _bgImageView = UIImageView(image: R.image.image())
        _bgImageView.contentMode = .scaleAspectFill
        return _bgImageView
    }()
    
    // 高斯蒙层
    lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        return _blurView
    }()
    
    // 工具栏
    lazy var toolBar: AudioPlayToolBar = {
        let _toolBar = AudioPlayToolBar()
        _toolBar.backgroundColor = .clear
        _toolBar.config = AudioPlayProgressConfig()
        _toolBar.delegate = self
        return _toolBar
    }()
    
    override func setupLayout() {
        super.setupLayout()
        view.backgroundColor = .white
        view.addSubview(bgImageView)
        view.addSubview(blurView)
        view.addSubview(toolBar)
        view.addSubview(backButton)
        // 设置naviBar在TableView上
        //view.bringSubviewToFront(naviBar)
        naviBar.isHidden = true
        
        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
      
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(10)
            $0.size.equalTo(CGSize(width: 44, height: 44))
        }
        toolBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-kBottomSafeHeight - 20)
            //$0.height.equalTo(100)
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        if let playItem = vm.playItem {
            avPlayerManager.play(item: playItem)
            updatePlayItem(playItem)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.avPlayerManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avPlayerManager.delegate = nil
    }
}

// MARK: - private mothods
extension AudioPlayerController {
    
    /// 更新播放项
    func updatePlayItem(_ item: AVPlaylistItem) {
        bgImageView.kf.setImage(with: URL(string: item.imageUrl?.urlEncoded ?? ""), placeholder: R.image.image())
    }
}

// MARK: - call backs
extension AudioPlayerController {
    
    @objc func tapBackAction() {
        backAction()
    }
}

// MARK: - AudioPlayToolBarDelegate
extension AudioPlayerController: AudioPlayToolBarDelegate {
    
    func playToolBar(_ toolBar: AudioPlayToolBar, playAction: Bool) {
        guard let currentItem = avPlayerManager.getPlaylist()?.getCurrentItem() else { return }
        let status = player?.timeControlStatus ?? .paused
        switch status {
        case .paused:
            avPlayerManager.togglePlayPause(item: currentItem)
        case .playing:
            avPlayerManager.pause()
        default:
            break
        }
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, previousAction: Bool) {
        avPlayerManager.playPrevious()
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, nextAction: Bool) {
        avPlayerManager.playNext()
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, touchesBegan sliderValue: Float) {
        
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, touchesMoved sliderValue: Float) {
        toolBar.updatePlayPregress(with: sliderValue)
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, touchesEnded sliderValue: Float) {
        guard let player = avPlayerManager.getPlayer(), let currentItem = avPlayerManager.getPlaylist()?.getCurrentItem() else { return }
        // 必须使用真实时长 (即元数据解析的时长)
        guard let duration = currentItem.mediaMeta?.duration, duration > 0 else { return }
        let time = TimeInterval(sliderValue) * duration
        LogM.debug("seek to: \(Int(time)/60): \(Int(time)%60)")
        avPlayerManager.seek(to: time)
    }
}

// MARK: AVPlayerManagerDelegate
extension AudioPlayerController: AVPlayerManagerDelegate {
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateProgressTo time: TimeInterval) {
        toolBar.updateToolBar(with: player, item: item)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateBufferProgressTo progress: Float) {
        toolBar.updateBufferValue(progress)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateStatusTo status: AVPlayer.TimeControlStatus) {
        toolBar.updatePlayStatus()
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, previous item: AVPlaylistItem) {
        updatePlayItem(item)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, next item: AVPlaylistItem) {
        updatePlayItem(item)
    }
}
