//
//  AVPlayerObserver.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation
import AVFoundation

// MARK: - global var and methods
extension AVPlayer.TimeControlStatus {
    static let waiting = AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate
}

// MARK: - main class
class AVPlayerObserver: NSObject {
    
    private var playerManager: AVPlayerManager!
    
    /// 播放进度
    private var playTimeObserver: Any?
    /// 播放状态同步
    private var playStateObserver: Any?
    /// 等待失败原因
    private var waitReasonObserver: Any?
    /// 多媒体播放状态
    private var itemStatusObserve: Any?
 
    init(playerManager: AVPlayerManager) {
        super.init()
        self.playerManager = playerManager
        
        // 如果 `AVPlayerManager.AVPlayer`还未被设置, 即使设置监听也无效
        //self.setupPlayerObservers()
    }

    deinit {
        removePlayerObservers()
    }
}

// MARK: - private mothods
extension AVPlayerObserver {
    
    /// 设置监听
    func setupPlayerObservers() {
        // 监听播放进度
        observePlayerProgress()
        // 监听播放状态
        observerTimeControlStatus()
        // 监听等待失败原因
        observerWaitFailReason()
        // 监听多媒体播放状态
        observerItemStatus()
    }
    
    /// 移除监听
    func removePlayerObservers() {
        if let playTimeObserver = playTimeObserver {
            self.playerManager.getPlayer()?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
        if let playStateObserver = playStateObserver {
            self.playerManager.getPlayer()?.removeObserver(self, forKeyPath: "timeControlStatus")
            self.playStateObserver = nil
        }
        if let waitReasonObserver = waitReasonObserver {
            self.playerManager.getPlayer()?.removeObserver(self, forKeyPath: "reasonForWaitingToPlay")
            self.waitReasonObserver = nil
        }
        if let itemStatusObserve = itemStatusObserve {
            playerManager.getPlayer()?.currentItem?.removeObserver(self, forKeyPath: "status")
            self.itemStatusObserve = nil
        }
    }
}

// MARK: - call backs
extension AVPlayerObserver {
    
    /// `注意规避 po audioPlayer.currentItem?.duration.seconds : nan`
    /// AVPlayerItem 的 duration 还未被正确设置，或者音频流的 duration 尚未被加载。常见原因包括：
    /// 音频尚未加载：AVPlayerItem 可能还没有准备好，duration 还未更新。
    /// 网络流媒体问题：如果你在播放流媒体（例如，网络音频），服务器未提供文件的持续时长信息。
    /// 音频资源无效或损坏：如果音频文件损坏或无法读取，duration 可能无法获取。
    
    /// 监听播放进度
    private func observePlayerProgress() {
        playTimeObserver = playerManager.getPlayer()?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { [weak self] time in
            
            guard let self = self, let playerItem = self.playerManager?.getPlayer()?.currentItem, let item = self.playerManager.getPlaylist()?.getCurrentItem() else { return }
   
            // 检查音频资源是否有效
            let isValideDuration = playerItem.duration.isValid && !playerItem.duration.seconds.isNaN
            
            // 播放进度
            if isValideDuration {
                let duration = playerItem.currentTime().seconds
                self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateProgressTo: duration)
            }
            
            // 缓冲进度
            if let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue, isValideDuration {
                let bufferedTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
                let totalDuration = playerItem.duration.isValid ? playerItem.duration.seconds: 0
                let progress = bufferedTime / totalDuration
                //print("缓冲进度：\(progress * 100)%")
                self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateBufferProgressTo: Float(progress))
            }
            
            // 更新播放信息
            self.playerManager.updateNowPlayingInfo()
        }
    }
    
    /// 监听播放状态
    private func observerTimeControlStatus() {
        playStateObserver = playerManager.getPlayer()?.observe(\.timeControlStatus, options: [.new, .old]) { [weak self] player, change in
            guard let self = self, let item = self.playerManager.getPlaylist()?.getCurrentItem() else { return }
            switch player.timeControlStatus {
            case .paused:
                LogM.debug("timeControlStatus_paused")
                //self.playerManager.getPlaylist().forEach { $0.playState = .paused}
                self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateStatusTo: .paused)
            case .playing:
                LogM.debug("timeControlStatus_playing")
                //self.playlist.forEach { $0.playState = $0 == track ? .playing : .paused}
                self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateStatusTo: .playing)
            case .waitingToPlayAtSpecifiedRate:
                LogM.debug("timeControlStatus_wait")
                //self.playlist.forEach { $0.playState = $0 == track ? .loading : .paused}
                self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateStatusTo: .waiting)
            @unknown default:
                LogM.debug("timeControlStatus_xx")
            }

            self.playerManager.updateNowPlayingInfo()
        }
    }
    
    /// 监听等待失败原因
    private func observerWaitFailReason() {
        waitReasonObserver = playerManager.getPlayer()?.observe(\.reasonForWaitingToPlay, options: [.new, .old]) { [weak self] player, change in
            guard let self = self, let reason = player.reasonForWaitingToPlay else { return }
            switch reason {
            case .toMinimizeStalls:
                LogM.debug("正在缓冲以避免播放卡顿")
            case .noItemToPlay:
                LogM.debug("没有可播放的音频项，请检查播放队列")
            case .evaluatingBufferingRate:
                LogM.debug("正在评估缓冲速率")
            default:
                LogM.debug("未知原因导致播放暂停")
            }
            self.playerManager.updateNowPlayingInfo()
        }
    }
    
    /// 监听多媒体播放状态
    private func observerItemStatus() {
        itemStatusObserve = playerManager.getPlayer()?.currentItem?.observe(\.status, options: [.new, .old]) { [weak self] playerItem, change in
            guard let self = self, let item = self.playerManager.getPlaylist()?.getCurrentItem() else { return }
            switch playerItem.status {
            case .readyToPlay:
                LogM.debug("playerItem_status_readyToPlay")
                self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateStatusTo: .waiting)
            case .failed:
                LogM.debug("playerItem_status_failed: \(playerItem.error?.localizedDescription ?? "")")
                //self.playerManager.delegate?.avPlayerManager(self.playerManager, item: item, didUpdateStatusTo: .paused)
            default:
                LogM.debug("playerItem_status_default")
            }
            self.playerManager.updateNowPlayingInfo()
        }
    }
}

// MARK: - delegate or data source
extension AVPlayerObserver { 
}

// MARK: - other classes
