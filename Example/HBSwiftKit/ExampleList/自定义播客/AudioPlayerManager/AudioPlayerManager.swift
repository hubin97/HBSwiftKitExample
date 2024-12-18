//
//  AudioPlayerManager.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import UIKit
import AVFoundation
import MediaPlayer

/// 播放模式
enum PlaybackMode {
    /// 顺序播放
    case sequential
    /// 循环播放
    case shuffle
    /// 单曲循环
    case repeatOne
}

// MARK: - main class
class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    
    /// 音频播放切换
    private var audioTrackSwitchCallBack: ((AudioTrack) -> Void)?
    /// 音频播放进度回调
    private var playerProgressCallBack: ((AudioTrack, TimeInterval) -> Void)?
    /// 音频缓存进度回调
    private var bufferProgressCallBack: ((AudioTrack, Float) -> Void)?
    
    // private properties
    /// 播放模式
    private var playbackMode: PlaybackMode = .sequential
    /// 音频播放状态
    private var isPlaying = false
    /// 音频播放器
    private(set) var audioPlayer: AVPlayer?
    /// 当前播放曲目索引
    private var currentTrackIndex = 0
    /// 播放列表
    private var playlist: [AudioTrack] = []

    /// 面板同步定时器
    private var timeObserver: Any?

    private override init() {
        super.init()
        setupAudioSession()
        setupNotification()
        setupRemoteCommandCenter()
        
        // 缓存区
        //audioPlayer?.automaticallyWaitsToMinimizeStalling = false
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
    
    // 监听播放完成通知
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackError), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        
        if let reason = audioPlayer?.reasonForWaitingToPlay {
            print("@1播放失败")
            switch reason {
            case .toMinimizeStalls:
                print("正在缓冲以避免播放卡顿")
            case .noItemToPlay:
                print("没有可播放的音频项，请检查播放队列")
            case .evaluatingBufferingRate:
                print("正在评估缓冲速率")
            default:
                print("未知原因导致播放暂停")
            }
        } else {
            print("播放器就绪/播放状态")
        }
        
        if let error = audioPlayer?.currentItem?.error as NSError? {
            print("@2播放失败: \(error.localizedDescription)")
            switch error.domain {
            case NSURLErrorDomain:
                print("网络问题: \(error.localizedDescription)")
                print("音频资源加载失败，请检查网络连接")
            case AVFoundationErrorDomain:
                print("音频资源无效: \(error.localizedDescription)")
                print("音频资源已失效，请更换音频")
            default:
                print("未知错误: \(error.localizedDescription)")
                print("播放失败，请稍后再试")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - private mothods
extension AudioPlayerManager {
    
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
        
        switch playbackMode {
        case .sequential:
            currentTrackIndex = (currentTrackIndex + 1) % playlist.count
        case .shuffle:
            currentTrackIndex = Int.random(in: 0..<playlist.count)
        case .repeatOne:
            // 保持 currentTrackIndex 不变
            break
        }
        
        playCurrentTrack()
    }

    /// 在随机模式下，上一个曲目可能需要额外维护一个播放历史栈（historyStack），以便用户可以返回到之前播放的曲目。
    func previousTrack() {
        guard !playlist.isEmpty else { return }
        
        if playbackMode == .shuffle {
            // 随机模式：重新随机选择
            currentTrackIndex = Int.random(in: 0..<playlist.count)
        } else {
            // 顺序播放
            currentTrackIndex = (currentTrackIndex - 1 + playlist.count) % playlist.count
        }
        
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
    
    func togglePlaybackMode() {
        switch playbackMode {
        case .sequential:
            playbackMode = .shuffle
        case .shuffle:
            playbackMode = .repeatOne
        case .repeatOne:
            playbackMode = .sequential
        }
        
        print("Playback mode changed to: \(playbackMode)")
    }
}

extension AudioPlayerManager {
    
    @objc private func handlePlaybackDidFinish() {
        if playbackMode == .repeatOne {
            playCurrentTrack() // 单曲循环
        } else if playbackMode == .shuffle || playbackMode == .sequential {
            nextTrack() // 顺序播放或随机播放
        }
    }
    
    @objc private func handlePlaybackError(notification: Notification) {
        if let failedItem = notification.object as? AVPlayerItem,
           let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            print("播放失败: \(error.localizedDescription)")
            print("失败的音频项: \(failedItem)")
        }
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
        playlist.forEach { $0.isPlaying = $0 == track }
        
        audioTrackSwitchCallBack?(track)
        updateNowPlayingInfo()
        observePlayerProgress()
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
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.metaData?.title ?? track.title ?? "Unknown Title"
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.metaData?.artist ?? track.artist ?? "Unknown Artist"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.metaData?.duration ?? track.duration

        // 播放进度和时长
        if let currentItem = player.currentItem {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.metaData?.duration ?? track.duration ?? currentItem.asset.duration.seconds
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
            guard let self = self else { return }
            
            // 播放进度
            if let duration = self.audioPlayer?.currentItem?.currentTime().seconds {
                let track = self.playlist[currentTrackIndex]
                self.playerProgressCallBack?(track, duration)
            }
            
            // 缓冲进度
            if let timeRanges = self.audioPlayer?.currentItem?.loadedTimeRanges, let timeRange = timeRanges.first?.timeRangeValue {
                let bufferedTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
                let totalDuration = self.audioPlayer?.currentItem?.duration.seconds ?? 0
                let progress = bufferedTime / totalDuration
                print("缓冲进度：\(progress * 100)%")
                let track = self.playlist[currentTrackIndex]
                self.bufferProgressCallBack?(track, Float(progress))
            }
            
            self.updateNowPlayingInfo()
        }
    }
}

// MARK: - call backs
extension AudioPlayerManager {
    
    /// 播放音频列表
    @discardableResult
    func setPlaylistList(with playlist: [AudioTrack]) -> Self {
        self.playlist = playlist
        return self
    }

    /// 设置播放模式
    func setPlaybackMode(with mode: PlaybackMode) -> Self {
        self.playbackMode = mode
        return self
    }
    
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
    
    // MARK: 状态监听
    
    /// 音频切换监听
    @discardableResult
    func onAudioTrackSwitch(_ callback: @escaping ((AudioTrack) -> Void)) -> Self {
        self.audioTrackSwitchCallBack = callback
        return self
    }
    
    /// 音频播放进度监听
    @discardableResult
    func onAudioPlayerProgressValueChange(_ callback: @escaping ((AudioTrack, TimeInterval) -> Void)) -> Self {
        self.playerProgressCallBack = callback
        return self
    }
    
    /// 音频缓存进度监听
    @discardableResult
    func onAudioBufferProgressValueChange(_ callback: @escaping ((AudioTrack, Float) -> Void)) -> Self {
        self.bufferProgressCallBack = callback
        return self
    }
}
