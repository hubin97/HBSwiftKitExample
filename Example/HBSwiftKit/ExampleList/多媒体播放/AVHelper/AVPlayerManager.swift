//
//  AVPlayerManager.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation
import AVFoundation
import MediaPlayer

// MARK: AVPlayerManagerDelegate
protocol AVPlayerManagerDelegate: AnyObject {
    //func AVPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didSwitchTo step: AudioSwitchStep)
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateProgressTo time: TimeInterval)
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateBufferProgressTo progress: Double)
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateStatusTo status: AVPlayer.TimeControlStatus)
    func avPlayerManager(_ manager: AVPlayerManager, previous item: AVPlaylistItem)
    func avPlayerManager(_ manager: AVPlayerManager, next item: AVPlaylistItem)
}

extension AVPlayerManagerDelegate {
    func avPlayerManager(_ manager: AVPlayerManager, item: AVPlaylistItem, didUpdateBufferProgressTo progress: Double) {}
    func avPlayerManager(_ manager: AVPlayerManager, previous item: AVPlaylistItem) {}
    func avPlayerManager(_ manager: AVPlayerManager, next item: AVPlaylistItem) {}
}

// MARK: - AVPlayerManager
class AVPlayerManager {
    
    static let shared = AVPlayerManager()

    weak var delegate: AVPlayerManagerDelegate?
    
    // MARK: Properties
    private var player: AVPlayer?
    private var playlist: AVPlaylist?
    private var playerLayer: AVPlayerLayer?

    private var nowPlayingUpdater: NowPlayingUpdater?
    private var remoteCommandHandler: RemoteCommandHandler?
    
    private var avPlayerNotification: AVPlayerNotification?
    private var avPlayerObserver: AVPlayerObserver?
   
    private init() {
        self.setupAudioSession()
        self.setupRemoteCommand()
        self.setupNotiAndObserver()
        
        // 缓存区
        //audioPlayer?.automaticallyWaitsToMinimizeStalling = false
    }

    // 设置播放模式
    func setPlaybackMode(_ mode: AVPlaybackMode) {
        playlist?.setPlaybackMode(mode)
    }

    // 返回 AVPlayer 实例以便 ViewController 使用
    func getPlayer() -> AVPlayer? {
        return player
    }
    
    // 设置播放列表
    func setPlaylist(_ playlist: AVPlaylist) {
        self.playlist = playlist
    }
    
    /// 返回 Playlist
    func getPlaylist() -> AVPlaylist? {
        return playlist
    }
    
    // 是否正在播放
    func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
        //return player?.rate != 0
    }
    
    // 获取当前播放时间
    func getCurrentTime() -> CMTime? {
        return player?.currentTime()
    }
    
    // 获取当前播放进度
    func getCurrentProgress() -> Float {
        guard let duration = player?.currentItem?.duration else { return 0 }
        return Float(CMTimeGetSeconds(getCurrentTime() ?? CMTime.zero) / CMTimeGetSeconds(duration))
    }
    
    //
    
    // 创建并返回 AVPlayerLayer
    func getPlayerLayer() -> AVPlayerLayer? {
        return playerLayer
    }
    
    // 返回 NowPlayingUpdater
    func getNowPlayingUpdater() -> NowPlayingUpdater? {
        return nowPlayingUpdater
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Configuration
extension AVPlayerManager {
    
    // MARK: Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
    
    // MARK: Setup remote command center
    private func setupRemoteCommand() {
        self.remoteCommandHandler = RemoteCommandHandler(playerManager: self)
        self.remoteCommandHandler?.setupRemoteCommandCenter()
        
        //self.nowPlayingController = NowPlayingUpdater(player: player, playlist: playlist)
        self.nowPlayingUpdater = NowPlayingUpdater(useMetadata: true)
    }
    
    // 监听播放完成通知
    private func setupNotiAndObserver() {
        self.avPlayerNotification = AVPlayerNotification(playerManager: self)
        self.avPlayerObserver = AVPlayerObserver(playerManager: self)
    }
    
    /// 设置监听
    private func setupPlayerObservers() {
        self.avPlayerObserver?.setupPlayerObservers()
    }
    
    /// 移除监听
    private func removePlayerObservers() {
        self.avPlayerObserver?.removePlayerObservers()
    }
    
    // MARK: -
    func updateNowPlayingInfo() {
        self.nowPlayingUpdater?.updateNowPlayingInfo()
    }
}

// MARK: 播放控制
extension AVPlayerManager {
    
    // 播放指定媒体
    func play(url: URL) {
        // 播放前先停止
        self.stop()
        
        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.player?.play()
        
        // 创建 AVPlayerLayer
        if self.playerLayer == nil {
            self.playerLayer = AVPlayerLayer(player: player)
            self.playerLayer?.videoGravity = .resizeAspect
        }
        
        // 设置监听
        self.setupPlayerObservers()
        // 更新播放信息
        self.updateNowPlayingInfo()
    }
    
    // 播放指定媒体(是否进行URL校验)
    func play(item: AVPlaylistItem, isValidate: Bool) {
        if isValidate {
            // 验证音频资源, 这是个耗时操作, 默认等待状态
            delegate?.avPlayerManager(self, item: item, didUpdateStatusTo: .waiting)
            
            let asset = AVAsset(url: item.url)
            AVAssetValidator.validateAudioAsset(asset) { [weak self] (isValid, status) in
                guard let self = self else { return }
                if isValid {
                    self.play(url: item.url)
                } else {
                    self.delegate?.avPlayerManager(self, item: item, didUpdateStatusTo: .paused)
                    LogM.debug("资源验证无效: \(status.description)")
                }
            }
        } else {
            self.play(url: item.url)
        }
    }
    
    // 播放指定媒体
    func play(item: AVPlaylistItem) {
        self.playlist?.setPlayIndex(with: item)
        self.play(url: item.url)
    }
    
    // 播放指定媒体(索引的)
    func play(at index: Int) {
        guard let item = playlist?.getPlayItem(at: index) else {
            LogM.debug("No media available to play.")
            return
        }
        self.playlist?.setPlayIndex(with: index)
        self.play(url: item.url)
    }
    
    // 播放当前媒体
    func play() {
        guard let item = playlist?.getCurrentItem() else {
            LogM.debug("No media available to play.")
            return
        }
        self.play(url: item.url)
    }
    
    // 播放下一个媒体
    func playNext() {
        guard let nextItem = playlist?.getNextItem() else { return }
        self.play(url: nextItem.url)
    }

    // 播放上一个媒体
    func playPrevious() {
        guard let previousItem = playlist?.getPreviousItem() else { return }
        self.play(url: previousItem.url)
    }
    
    // 暂停当前播放
    func pause() {
        player?.pause()
    }

    // 继续播放
    func resume() {
        player?.play()
    }
    
    // 停止播放
    func stop() {
        player?.pause()
        player = nil
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    // 播放/暂停
    func togglePlayPause(item: AVPlaylistItem) {
        if isPlaying() {
            pause()
        } else {
            if player == nil {
                play(item: item)
            } else {
                resume()
            }
        }
    }
}

// MARK: 进度控制
extension AVPlayerManager {
    
    // 设置播放进度 (CMTime)
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }
    
    // 设置播放进度 (TimeInterval)
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    // 设置播放进度(比例)
    func seek(to progress: Float) {
        guard let duration = player?.currentItem?.duration else { return }
        let time = CMTime(seconds: Double(progress) * CMTimeGetSeconds(duration), preferredTimescale: 600)
        player?.seek(to: time)
    }
}

extension AVPlayerManager {
    
    // 设置音量
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
    
    // 获取音量
    func getVolume() -> Float {
        return player?.volume ?? 0
    }
    
    // 设置静音
    func setMuted(_ muted: Bool) {
        player?.isMuted = muted
    }
    
    // 是否静音
    func isMuted() -> Bool {
        return player?.isMuted ?? false
    }
    
    // 获取当前播放速率
    func getRate() -> Float {
        return player?.rate ?? 0
    }
    
    // 设置播放速率
    func setRate(_ rate: Float) {
        player?.rate = rate
    }
    
    // 快进15s
    func forward(_ seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let time = CMTimeAdd(currentTime, CMTime(seconds: seconds, preferredTimescale: 1))
        player?.seek(to: time)
    }
    
    // 快退15s
    func rewind(_ seconds: Double) {
        guard let currentTime = player?.currentTime() else { return }
        let time = CMTimeSubtract(currentTime, CMTime(seconds: seconds, preferredTimescale: 1))
        player?.seek(to: time)
    }
}
