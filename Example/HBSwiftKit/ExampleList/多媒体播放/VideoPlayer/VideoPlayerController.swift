//
//  VideoPlayerController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import AVFoundation

// MARK: - global var and methods

// MARK: - main class
class VideoPlayerController: ViewController, ViewModelProvider {
    typealias ViewModelType = VideoPlayerViewModel

    lazy var avPlayerManager: AVPlayerManager = {
        return AVPlayerManager.shared
    }()
    
    lazy var player: AVPlayer? = {
        return avPlayerManager.getPlayer()
    }()
    
    private var playerLayer: AVPlayerLayer?
    
    lazy var playerPreview: UIScrollView = {
        let view = UIScrollView(frame: self.view.bounds)
        view.backgroundColor = .black
        view.minimumZoomScale = 0.5
        view.maximumZoomScale = 3
        view.setBorder(borderColor: .red, borderWidth: 2)
        return view
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.setImage(R.image.ib_back()?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)
        return _backButton
    }()
   
    lazy var verticalToolBar: VideoPlayVerticalToolBar = {
        let _verticalToolBar = VideoPlayVerticalToolBar()
        _verticalToolBar.backgroundColor = .clear
        _verticalToolBar.config = MediaPlayProgressConfig()
        _verticalToolBar.delegate = self
        return _verticalToolBar
    }()
    
    lazy var horizontalToolBar: VideoPlayHorizontalToolBar = {
        let _horizontalToolBar = VideoPlayHorizontalToolBar()
        _horizontalToolBar.backgroundColor = .clear
        _horizontalToolBar.config = MediaPlayProgressConfig()
        _horizontalToolBar.delegate = self
        _horizontalToolBar.isHidden = true
        return _horizontalToolBar
    }()
    
    override func setupLayout() {
        super.setupLayout()
        // self.naviBar.title = "Video Player"
        self.naviBar.isHidden = true
        view.addSubview(playerPreview)
        view.addSubview(verticalToolBar)
        view.addSubview(horizontalToolBar)
        view.addSubview(backButton)
        
//        playerPreview.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        verticalToolBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kBottomSafeHeight)
            make.height.equalTo(60)
        }
        horizontalToolBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kBottomSafeHeight)
            make.height.equalTo(60)
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(10)
            $0.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        if let playItem = vm.playItem {
            avPlayerManager.play(item: playItem)
            
            if let playerLayer = avPlayerManager.getPlayerLayer() {
                playerPreview.layer.insertSublayer(playerLayer, at: 0)
                playerLayer.frame = playerPreview.bounds
                self.playerLayer = playerLayer
            }
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.avPlayerManager.stop()
    }
}

// MARK: - private mothods
extension VideoPlayerController {
    
    @objc func tapBackAction() {
        backAction()
    }
}

// MARK: - call backs
extension VideoPlayerController: VideoPlayToolBarDelegate {
    
    func playToolBar(_ toolBar: VideoPlayToolBar, playAction: Bool) {
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
    
    func playToolBar(_ toolBar: VideoPlayToolBar, previousAction: Bool) {
        avPlayerManager.playPrevious()
    }
    
    func playToolBar(_ toolBar: VideoPlayToolBar, nextAction: Bool) {
        avPlayerManager.playNext()
    }
    
    func playToolBar(_ toolBar: VideoPlayToolBar, scaleAction: Bool) {
        LogM.debug("半屏/全屏切换")
    }
    func playToolBar(_ toolBar: VideoPlayToolBar, rotateAction: Bool) {
        LogM.debug("旋转")
//        verticalToolBar.isHidden = true
//        horizontalToolBar.isHidden = false
        // 预览图层 横竖屏切换
        UIView.animate(withDuration: 0.25) {
            self.playerPreview.frame = CGRect(x: 0, y: 0, width: kScreenH, height: kScreenW)
            self.playerPreview.center = self.view.center
            self.playerPreview.transform = CGAffineTransform(rotationAngle: .pi/2)
        } completion: { _ in
            self.playerLayer?.frame = self.playerPreview.bounds
        }
    }

    //
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesBegan sliderValue: Float) {
        
    }
    
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesMoved sliderValue: Float) {
        toolBar.updatePlayPregress(with: sliderValue)
    }
    
    func playToolBar(_ toolBar: VideoPlayToolBar, touchesEnded sliderValue: Float) {
        guard let currentItem = avPlayerManager.getPlaylist()?.getCurrentItem() else { return }
        // 必须使用真实时长 (即元数据解析的时长)
        guard let duration = currentItem.mediaMeta?.duration, duration > 0 else { return }
        let time = TimeInterval(sliderValue) * duration
        LogM.debug("seek to: \(Int(time)/60): \(Int(time)%60)")
        avPlayerManager.seek(to: time)
    }

}

// MARK: - delegate or data source
extension VideoPlayerController: AVPlayerManagerDelegate {
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateProgressTo time: TimeInterval) {
        // 规避拖拽
        guard !verticalToolBar.isDraging else { return }
        verticalToolBar.updateToolBar(with: item)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateBufferProgressTo progress: Float) {
        verticalToolBar.updateBufferValue(progress)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateStatusTo status: AVPlayer.TimeControlStatus) {
        verticalToolBar.updatePlayStatus()
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, previous item: AVPlaylistItem) {
        //updatePlayItem(item)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, next item: AVPlaylistItem) {
        //updatePlayItem(item)
    }
}
// MARK: - other classes
