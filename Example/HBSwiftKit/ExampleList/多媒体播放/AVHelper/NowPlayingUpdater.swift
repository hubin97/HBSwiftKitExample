//
//  NowPlayingUpdater.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation
import MediaPlayer

// MARK: - global var and methods

// MARK: - main class
class NowPlayingUpdater {

    private var player: AVPlayer? {
        return AVPlayerManager.shared.getPlayer()
    }
    private var playlist: AVPlaylist? {
        return AVPlayerManager.shared.getPlaylist()
    }
    
    private var useMetadata = false
    /// 初始化, 是否使用解析数据
    convenience init(useMetadata: Bool) {
        self.init()
        self.useMetadata = useMetadata
    }

    /// 是否使用解析数据
    func getUseMetadata() -> Bool {
        return useMetadata
    }
    
    /// 更新控制面板和锁屏信息
    func updateNowPlayingInfo() {
        guard let item = playlist?.getCurrentItem() else { return }
        item.asyncUpdateArtwork()
        
        var media_title = item.title ?? "Unknown Title"
        var media_artist = item.artist ?? "Unknown Artist"
        var media_duration = item.duration ?? 0
        
        if let title = item.mediaMeta?.title, useMetadata {
            media_title = title
        }
        
        if let artist = item.mediaMeta?.artist, useMetadata {
            media_artist = artist
        }
        
        if let duration = item.mediaMeta?.duration {
            media_duration = duration
        }

        // 更新 Now Playing
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = media_title
        nowPlayingInfo[MPMediaItemPropertyArtist] = media_artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = media_duration
        
        // 播放进度和时长
        if let currentItem = player?.currentItem {
            //nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.duration ?? currentItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying() ? 1.0 : 0.0
        }
        
        // 封面图片
        if let mediaArtwork = item.cachedMediaArtwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArtwork
        }
        
        // 更新 Now Playing 信息
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    private func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
    }
}
