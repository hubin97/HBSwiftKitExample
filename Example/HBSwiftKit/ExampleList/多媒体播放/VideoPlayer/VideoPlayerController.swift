//
//  VideoPlayerController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import AVFoundation

// MARK: - global var and methods

// MARK: - main class
class VideoPlayerController: ViewController, ViewModelProvider, ScreenOrientationHandler {
    typealias ViewModelType = VideoPlayerViewModel

    var currentOrientation: UIInterfaceOrientation = .portrait
    var isOrientationLocked: Bool = false
    var isFullScreen: Bool = false
    
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
        //view.setBorder(borderColor: .red, borderWidth: 2)
        return view
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.frame = CGRect(x: 0, y: kStatusBarHeight, width: 44, height: 44)
        _backButton.setImage(UIImage(named: "icon_back_white", in: assetsBundle, compatibleWith: nil)?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)
        return _backButton
    }()
   
    private let progressConfig: MediaPlayProgressConfig = {
        var config = MediaPlayProgressConfig()
        config.progressHeight = 3
        config.cornerRadius = 1.5
        config.thumbImageSize = CGSize(width: 24, height: 24)
        return config
    }()
    
    private let halfVerticalViewH = kScreenW / (16/9) + kStatusBarHeight
    lazy var halfVerticalToolBar: HalfVerticalToolBar = {
        let originY = kStatusBarHeight + kScreenW / (16/9) - 44
        let _toolBar = HalfVerticalToolBar(frame: CGRect(x: 0, y: originY, width: kScreenW, height: 44))
        _toolBar.backgroundColor = .clear
        _toolBar.config = progressConfig
        _toolBar.delegate = self
        return _toolBar
    }()
    
    lazy var fullVerticalToolBar: FullVerticalToolBar = {
        let _toolBar = FullVerticalToolBar(frame: CGRect(x: 0, y: kScreenH - kBottomSafeHeight - 70, width: kScreenW, height: kBottomSafeHeight + 70))
        _toolBar.backgroundColor = .clear
        _toolBar.config = progressConfig
        _toolBar.delegate = self
        return _toolBar
    }()
        
    lazy var horizontalToolBar: VideoPlayHorizontalToolBar = {
        // (x: kTopSafeHeight, y: 0, width: kScreenH - kTopSafeHeight - kBottomSafeHeight, height: kScreenW)
        let _toolBar = VideoPlayHorizontalToolBar(frame: CGRect(x: kTopSafeHeight, y: kScreenW - 70, width: kScreenH - kTopSafeHeight - kBottomSafeHeight, height: 70))
        _toolBar.backgroundColor = .clear
        _toolBar.config = progressConfig
        _toolBar.delegate = self
        return _toolBar
    }()
    
    lazy var halfContainerView: UIView = {
        let frame = CGRect(x: 0, y: halfVerticalViewH, width: kScreenW, height: kScreenH - halfVerticalViewH)
        let view = UIView(frame: frame)
        view.backgroundColor = .white
        return view
    }()

    override func setupLayout() {
        super.setupLayout()
        // self.naviBar.title = "Video Player"
        self.naviBar.isHidden = true
        view.backgroundColor = .black
        view.addSubview(halfContainerView)
        view.addSubview(playerPreview)
        view.addSubview(halfVerticalToolBar)
        view.addSubview(fullVerticalToolBar)
        view.addSubview(horizontalToolBar)
        view.addSubview(backButton)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        var date = Date()
        if let playItem = vm.playItem {
            DispatchQueue.global().async {
                self.avPlayerManager.play(item: playItem)
                LogM.debug("耗时1: \(Date().timeIntervalSince(date))")
                
                date = Date()
                if let playerLayer = self.avPlayerManager.getPlayerLayer() {
                    playerLayer.frame = self.playerPreview.bounds
                    self.playerLayer = playerLayer
                    LogM.debug("耗时2: \(Date().timeIntervalSince(date))")
                    
                    DispatchQueue.main.async {
                        self.playerPreview.layer.insertSublayer(playerLayer, at: 0)
                    }
                }
            }
        }
        
        self.adjustLayoutForIsFullScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.avPlayerManager.delegate = self
        self.setupOrientationListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avPlayerManager.delegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.avPlayerManager.stop()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}

// MARK: - private mothods
extension VideoPlayerController {
    
    @objc func tapBackAction() {
        if currentOrientation.isLandscape {
            self.toggleOrientation()
            return
        }
        backAction()
    }
    
    // 预览图层 横竖屏切换
    func adjustLayout(for orientation: UIInterfaceOrientation) {
        self.updateConfig()

        self.backButton.frame = CGRect(x: orientation.isPortrait ? 0: kTopSafeHeight, y: orientation.isPortrait ? kStatusBarHeight: 20, width: 44, height: 44)
        
        let videoFrame = orientation.isLandscape ? CGRect(x: kTopSafeHeight, y: 0, width: kScreenH - kTopSafeHeight - kBottomSafeHeight, height: kScreenW): CGRect(x: 0, y: 0, width: kScreenW, height: isFullScreen ? kScreenH: halfVerticalViewH)
        UIView.animate(withDuration: 0.25) {
            self.playerPreview.frame = videoFrame
        } completion: { _ in
            self.playerLayer?.frame = self.playerPreview.bounds
        }
    }
    
    // 竖屏 16:9  1  back 40 toolbar 44  / toolbar 70 / 全屏也是 70
    func adjustLayoutForIsFullScreen() {
        self.updateConfig()
        
        let videoFrame = CGRect(x: 0, y: 0, width: kScreenW, height: isFullScreen ? kScreenH: halfVerticalViewH)
        UIView.animate(withDuration: 0.25) {
            self.playerPreview.frame = videoFrame
        } completion: { _ in
            self.playerLayer?.frame = self.playerPreview.bounds
        }
    }
    
    func updateConfig() {
        if currentOrientation.isPortrait {
            self.halfVerticalToolBar.isHidden = isFullScreen
            self.fullVerticalToolBar.isHidden = !isFullScreen
            self.horizontalToolBar.isHidden = true
            self.halfVerticalToolBar.scaleButton.isHidden = false
            self.fullVerticalToolBar.scaleButton.isHidden = false
            self.halfContainerView.isHidden = isFullScreen
        } else {
            self.horizontalToolBar.isHidden = false
            self.halfVerticalToolBar.isHidden = true
            self.fullVerticalToolBar.isHidden = true
            self.halfVerticalToolBar.scaleButton.isHidden = true
            self.fullVerticalToolBar.scaleButton.isHidden = true
            self.halfContainerView.isHidden = true
        }
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
        if currentOrientation == .portrait {
            isFullScreen.toggle()
            adjustLayoutForIsFullScreen()
        }
    }
    func playToolBar(_ toolBar: VideoPlayToolBar, rotateAction: Bool) {
        LogM.debug("旋转")
        self.toggleOrientation()
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
        guard !halfVerticalToolBar.isDraging && !fullVerticalToolBar.isDraging && !horizontalToolBar.isDraging else { return }
        halfVerticalToolBar.updateToolBar(with: item)
        fullVerticalToolBar.updateToolBar(with: item)
        horizontalToolBar.updateToolBar(with: item)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateBufferProgressTo progress: Float) {
        halfVerticalToolBar.updateBufferValue(progress)
        fullVerticalToolBar.updateBufferValue(progress)
        horizontalToolBar.updateBufferValue(progress)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateStatusTo status: AVPlayer.TimeControlStatus) {
        DispatchQueue.main.async {
            self.halfVerticalToolBar.updatePlayStatus()
            self.fullVerticalToolBar.updatePlayStatus()
            self.horizontalToolBar.updatePlayStatus()
        }
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, previous item: AVPlaylistItem) {
        //updatePlayItem(item)
    }
    
    func avPlayerManager(_ manager: AVPlayerManager, next item: AVPlaylistItem) {
        //updatePlayItem(item)
    }
}
// MARK: - other classes
