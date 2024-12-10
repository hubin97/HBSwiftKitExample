//
//  AudioPlayerManager.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import UIKit
import AVFoundation
import MediaPlayer

// MARK: - main class
class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    
    private var isPlaying = false
    /// 音频播放器
    private var audioPlayer: AVPlayer?
    /// 当前播放曲目索引
    private var currentTrackIndex = 0
    /// 播放列表
    private var playlist: [AudioTrack] = []
    /// 面板同步定时器
    private var timeObserver: Any?

    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
}

// MARK: - private mothods
extension AudioPlayerManager {
    
    // MARK: - Play Audio
    func playTrackList(playlist: [AudioTrack]) {
        self.playlist = playlist
        currentTrackIndex = 0
        playCurrentTrack()
    }
    
    // MARK: - Play Specific Track
    func playTrack(at index: Int) {
        guard !playlist.isEmpty, index >= 0, index < playlist.count else {
            print("Invalid track index")
            return
        }
        
        currentTrackIndex = index
        playCurrentTrack()
    }
    
    func playTrack(_ track: AudioTrack) {
        guard let index = playlist.firstIndex(where: { $0.audioUrl == track.audioUrl }) else {
            print("Track not found in the playlist")
            return
        }
        
        playTrack(at: index)
    }

    private func playCurrentTrack() {
        guard !playlist.isEmpty else { return }
        let track = playlist[currentTrackIndex]
        guard let audioUrl = track.audioUrl else {
            print("Invalid audio URL")
            return
        }
     
        // 停止当前播放
        stopAudio()
        
        // 设置新的播放源
        audioPlayer = AVPlayer(url: audioUrl)
        audioPlayer?.play()
        isPlaying = true
        
        updateNowPlayingInfo()
        observePlayerProgress()
    }
        
    // 停止音频
    func stopAudio() {
        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    // 暂停音频
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    // 恢复音频
    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    // 下一曲
    func nextTrack() {
        guard !playlist.isEmpty else { return }
        currentTrackIndex = (currentTrackIndex + 1) % playlist.count
        playCurrentTrack()
    }
    
    // 上一曲
    func previousTrack() {
        guard !playlist.isEmpty else { return }
        currentTrackIndex = (currentTrackIndex - 1 + playlist.count) % playlist.count
        playCurrentTrack()
    }
    
    // 进度条设置
    func seekToPosition(_ position: TimeInterval) {
        // 创建 CMTime
        let time = CMTime(seconds: position, preferredTimescale: 600)
        // 调整播放位置
        audioPlayer?.seek(to: time)
        // 更新 Now Playing 信息
        updateNowPlayingInfo()
    }
}

// MARK: - Now Playing Info
extension AudioPlayerManager {
    
    /// 更新控制面板和锁屏信息
    private func updateNowPlayingInfo() {
        guard let player = audioPlayer, !playlist.isEmpty else { return }
        let track = playlist[currentTrackIndex]

        // 更新 Now Playing
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title ?? track.metaData?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist ?? track.metaData?.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.duration ?? track.metaData?.duration

        // 播放进度和时长
        if let currentItem = player.currentItem {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.duration ?? track.metaData?.duration ?? currentItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        }
        
        // 封面图片
        if let mediaArtwork = track.cachedMediaArtwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArtwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Remote Command Center
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resumeAudio()
            return .success
        }
        
        // 暂停
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pauseAudio()
            return .success
        }
        
        // 停止
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.stopAudio()
            return .success
        }
        
        // 下一曲
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
        
        // 上一曲
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
        
        // 设置播放进度
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            
            if let changeEvent = event as? MPChangePlaybackPositionCommandEvent {
                let newPosition = changeEvent.positionTime
                // 调用您自己的方法来调整播放位置
                self.seekToPosition(newPosition)
                return .success
            }
            return .commandFailed
        }
    }
    
    // MARK: - Observe Playback Progress
    private func observePlayerProgress() {
        guard let player = audioPlayer else { return }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] _ in
            self?.updateNowPlayingInfo()
        }
    }
}

// MARK: - call backs
extension AudioPlayerManager {
    
    /// 播放音频列表
    @discardableResult
    func setPlaylist(with list: [AudioTrack]) -> Self {
        self.playlist = list
        return self
    }
    
    /// 设置音频展示标题
//    @discardableResult
//    func setAudioTitle(with title: String) -> Self {
//        self.currentAudioTitle = title
//        return self
//    }
//    
//    /// 设置音频艺术家
//    @discardableResult
//    func setAudioArtist(with name: String) -> Self {
//        self.currentAudioArtist = name
//        return self
//    }
//    
//    /// 设置音频封面图片
//    @discardableResult
//    func setAudioAvatar(with image: UIImage?) -> Self {
//        self.currentAudioAvatar = image
//        return self
//    }
    
    /// 更新控制面板和锁屏页信息
    /// 如果是设置标题, 作者, 封面, 音频资源路径, 请调用此方法
    func setUpdateNowPlayingInfoCenter() -> Self {
        self.updateNowPlayingInfo()
        return self
    }
    
    /// 设置音频资源路径(网络图片)
//    @discardableResult
//    func setAsyncAvatar(with imgPath: String?) -> Self {
//        guard !playlist.isEmpty else { return self }
//        var track = playlist[currentTrackIndex]
//        
//        guard let imgPath = imgPath?.urlEncoded, let url = URL(string: imgPath) else { return self }
//        ImageDownloader.default.downloadImage(with: url, options: [.transition(.fade(0.3))]) {[weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let value):
//                track.artworkIcon = value.image
//                self.playlist[currentTrackIndex] = track
//                self.updateNowPlayingInfo()
//            case .failure(let error):
//                print("Failed to download image: \(error)")
//                iToast.makeToast(error.localizedDescription)
//            }
//        }
//        return self
//    }
}

// MARK: - delegate or data source
extension AudioPlayerManager { 
}

// MARK: - other classes
