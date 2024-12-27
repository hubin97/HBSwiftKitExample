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

    private var player: AVPlayer?
    private var playlist: AVPlaylist
    
    init(player: AVPlayer?, playlist: AVPlaylist) {
        self.player = player
        self.playlist = playlist
    }
    
    /// 更新控制面板和锁屏信息
    func updateNowPlayingInfo() {
        guard let item = playlist.getCurrentItem() else { return }
        
        // 更新 Now Playing
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = item.title ?? "Unknown Title"
        nowPlayingInfo[MPMediaItemPropertyArtist] = item.artist ?? "Unknown Artist"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.duration ?? 0
        
        // 播放进度和时长
        if let currentItem = player?.currentItem {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.duration ?? currentItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying() ? 1.0 : 0.0
        }
        
        // 封面图片
//        if let mediaArtwork = item.cachedMediaArtwork {
//            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArtwork
//        }
        
        // 更新 Now Playing 信息
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    private func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
    }
}
