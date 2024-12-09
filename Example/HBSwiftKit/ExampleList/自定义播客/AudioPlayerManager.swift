//
//  AudioPlayerManager.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import UIKit
import AVFoundation
import MediaPlayer
import Kingfisher

// MARK: - main class
class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    
    private var isPlaying = false
    /// 音频播放器
    private var audioPlayer: AVPlayer?
    /// 音频名称
    private var currentAudioTitle: String?
    /// 作者/艺术人
    private var currentAudioArtist: String?
    /// 音频封面 图片大小最好适合控制面板显示（建议不超过 512x512 像素）。
    private var currentAudioAvatar: UIImage?
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
    /// 播放音频（支持动态更新标题、封面）
    func playAudio(with url: URL?, title: String? = nil, artist: String? = nil, artwork: UIImage? = nil) {
        // 停止当前播放
        stopAudio()
        
        // 播放音频
        if let url = url {
            // 初始化 AVPlayer
            audioPlayer = AVPlayer(url: url)
            audioPlayer?.play()
            isPlaying = true
        }
        
        // 设置当前播放信息
        if let title = title {
            setAudioTitle(with: title)
        }
        if let artist = artist {
            setAudioArtist(with: artist)
        }
        if let artwork = artwork {
            setAudioAvatar(with: artwork)
        }
        
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
}

// MARK: - Now Playing Info
extension AudioPlayerManager {
    
    /// 更新控制面板和锁屏信息
    private func updateNowPlayingInfo() {
        guard let player = audioPlayer else { return }
        // 更新 Now Playing
        var nowPlayingInfo = [String: Any]()
        // 音频标题
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentAudioTitle ?? "Unknown Title"
        // 作者（可自定义）
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentAudioArtist ?? "Unknown Artist"
        
        // 播放进度和时长
        if let currentItem = player.currentItem {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentItem.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        }
        
        // 封面图片
        if let artwork = currentAudioAvatar {
            let mediaArtwork = MPMediaItemArtwork(boundsSize: artwork.size) { _ in
                return artwork
            }
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

// MARK: - Helper Methods
extension AudioPlayerManager {
    
    // 进度条设置
    func seekToPosition(_ position: TimeInterval) {
        let time = CMTime(seconds: position, preferredTimescale: 600) // 创建 CMTime
        // 调整播放位置
        audioPlayer?.seek(to: time)
        // 更新 Now Playing 信息
        updateNowPlayingInfo()
    }
    
    // 下一曲
    func nextTrack() {
        // 播放下一首音频
        // playAudio(with: nextAudioURL)
    }
    
    // 上一曲
    func previousTrack() {
        // 播放上一首音频
        // playAudio(with: previousAudioURL)
    }
}

// MARK: - call backs
extension AudioPlayerManager {
    
    /// 设置音频展示标题
    @discardableResult
    func setAudioTitle(with title: String) -> Self {
        self.currentAudioTitle = title
        return self
    }
    
    /// 设置音频艺术家
    @discardableResult
    func setAudioArtist(with name: String) -> Self {
        self.currentAudioArtist = name
        return self
    }
    
    /// 设置音频封面图片
    @discardableResult
    func setAudioAvatar(with image: UIImage?) -> Self {
        self.currentAudioAvatar = image
        return self
    }
    
    /// 更新控制面板和锁屏页信息
    /// 如果是设置标题, 作者, 封面, 音频资源路径, 请调用此方法
    func setUpdateNowPlayingInfoCenter() -> Self {
        self.updateNowPlayingInfo()
        return self
    }
    
    /// 设置音频资源路径(网络图片)
    func setAsyncAvatar(with imgPath: String?) -> Self {
        guard let imgPath = imgPath?.urlEncoded, let url = URL(string: imgPath) else { return self }
        ImageDownloader.default.downloadImage(with: url, options: [.transition(.fade(0.3))]) { result in
            switch result {
            case .success(let value):
                self.currentAudioAvatar = value.image
                self.updateNowPlayingInfo()
            case .failure(let error):
                print("Failed to download image: \(error)")
                iToast.makeToast(error.localizedDescription)
            }
        }
        return self
    }
}

// MARK: - delegate or data source
extension AudioPlayerManager { 
}

// MARK: - other classes
