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
    
    // 歌名
    lazy var titleLabel: UILabel = {
        let _titleLabel = UILabel()
        _titleLabel.textAlignment = .center
        _titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        _titleLabel.textColor = .white
        return _titleLabel
    }()
    
    // 艺术人
    lazy var authorLabel: UILabel = {
        let _authorLabel = UILabel()
        _authorLabel.textAlignment = .center
        _authorLabel.font = UIFont.systemFont(ofSize: 12)
        _authorLabel.textColor = .lightGray
        return _authorLabel
    }()
    
    // 封面
    lazy var posterView: UIImageView = {
        let _posterView = UIImageView(image: R.image.image())
        _posterView.contentMode = .scaleAspectFill
        _posterView.setBorder(cornerRadius: 16, makeToBounds: true)
        return _posterView
    }()
    
    // UIstack
    lazy var operateStackView: UIStackView = {
        let _operateStackView = UIStackView()
        _operateStackView.axis = .horizontal
        _operateStackView.alignment = .center
        _operateStackView.distribution = .fillEqually
        vm.operateItems.enumerated().forEach { offset, item in
            let itemButton = UIButton(type: .custom)
            itemButton.setTitle(item, for: .normal)
            itemButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            itemButton.tag = 1000 + offset
            itemButton.addTarget(self, action: #selector(opAction(_:)), for: .touchUpInside)
            _operateStackView.addArrangedSubview(itemButton)
        }
        return _operateStackView
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
        naviBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(bgImageView)
        view.addSubview(blurView)
        view.addSubview(toolBar)
        view.addSubview(backButton)
        // 设置naviBar在TableView上
        //view.bringSubviewToFront(naviBar)
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(posterView)
        view.addSubview(operateStackView)
        
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
            //$0.bottom.equalToSuperview().offset( -kBottomSafeHeight - 20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(kIsHaveBangs ? 0: 20)
            //$0.height.equalTo(100)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing).offset(10)
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(25)
        }
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        posterView.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(posterView.snp.width)
        }
        operateStackView.snp.makeConstraints { make in
            make.bottom.equalTo(toolBar.snp.top).offset(-40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
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
        titleLabel.text = item.title
        authorLabel.text = item.artist
        posterView.kf.setImage(with: URL(string: item.imageUrl?.urlEncoded ?? ""), placeholder: R.image.image())
    }
}

// MARK: - call backs
extension AudioPlayerController {
    
    @objc func tapBackAction() {
        backAction()
    }
    
    @objc func opAction(_ sender: UIButton) {
        LogM.debug("opAction: \(sender.tag)")
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
        guard let currentItem = avPlayerManager.getPlaylist()?.getCurrentItem() else { return }
        // 必须使用真实时长 (即元数据解析的时长)
        guard let duration = currentItem.mediaMeta?.duration, duration > 0 else { return }
        let time = TimeInterval(sliderValue) * duration
        LogM.debug("seek to: \(Int(time)/60): \(Int(time)%60)")
        avPlayerManager.seek(to: time)
    }
    
    func playToolBar(_ toolBar: AudioPlayToolBar, expand: Bool) {
        let playItems = AVPlayerManager.shared.getPlaylist()?.playlist ?? []
        LogM.debug("\(playItems.map({ $0.title ?? "" }))")
    }
}

// MARK: AVPlayerManagerDelegate
extension AudioPlayerController: AVPlayerManagerDelegate {
    
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateProgressTo time: TimeInterval) {
        // 规避拖拽
        guard !toolBar.isDraging else { return }
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
