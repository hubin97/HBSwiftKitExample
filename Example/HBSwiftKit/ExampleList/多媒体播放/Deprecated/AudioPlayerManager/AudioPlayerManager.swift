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
    /// 无 (none相比`sequential`, 只是不会自动播放下一曲)
    case none
    /// 顺序播放
    case sequential
    /// 循环播放
    case shuffle
    /// 单曲循环
    case repeatOne
}

/// 音频切换回调 (准备开始, 准备完成)
enum AudioSwitchStep {
    /// 准备开始
    case start
    /// 准备完成
    case ended
}

// MARK: AudioPlayerManagerDelegate
protocol AudioPlayerManagerDelegate: AnyObject {
    func audioPlayerManager(_ manager: AudioPlayerManager, track: AudioTrack, didSwitchTo step: AudioSwitchStep)
    func audioPlayerManager(_ manager: AudioPlayerManager, track: AudioTrack, didUpdateProgressTo time: TimeInterval)
    func audioPlayerManager(_ manager: AudioPlayerManager, track: AudioTrack, didUpdateBufferProgressTo progress: Float)
    func audioPlayerManager(_ manager: AudioPlayerManager, track: AudioTrack, didChangeStateTo state: AudioTrack.PlayState)
    func audioPlayerManager(_ manager: AudioPlayerManager, previous track: AudioTrack)
    func audioPlayerManager(_ manager: AudioPlayerManager, next track: AudioTrack)
}

extension AudioPlayerManagerDelegate {
    func audioPlayerManager(_ manager: AudioPlayerManager, track: AudioTrack, didUpdateBufferProgressTo progress: Float) {}
    func audioPlayerManager(_ manager: AudioPlayerManager, previous track: AudioTrack) {}
    func audioPlayerManager(_ manager: AudioPlayerManager, next track: AudioTrack) {}
}

// MARK: - main class
class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    
    weak var delegate: AudioPlayerManagerDelegate?

    // private properties
    /// 播放状态
    private var playState: AudioTrack.PlayState = .paused
    /// 播放模式, 默认 无
    private var playbackMode: PlaybackMode = .none
    /// 音频播放状态
    private var isPlaying = false
    /// 音频播放器
    private(set) var audioPlayer: AVPlayer?
    /// 当前播放曲目索引
    private var currentTrackIndex = 0
    /// 播放列表
    private(set) var playlist: [AudioTrack] = []

    /// 面板同步定时器
    private var timeObserver: Any?
    /// 状态同步定时器
    private var stateObserver: Any?
    /// 等待失败原因
    private var failReasonObserver: Any?

    private var statusObserve: Any?
    
    /// 当前播放的音频
    var currentTrack: AudioTrack? {
        guard !playlist.isEmpty else { return nil }
        return playlist[currentTrackIndex]
    }
    
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
        observePlayerProgress()
        observerTimeControlStatus()
        observerWaitFailReason()

        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackError), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - private mothods
extension AudioPlayerManager {
    
    // MARK: - Play Specific Track
    // 切换播放状态
    func togglePlayPause(_ track: AudioTrack? = nil) {
        if let track = track {
            switch track.playState {
            case .loading:
                return
            case .playing:
                pauseAudio()
            case .paused:
                // 如果是当前播放的音频, 则恢复播放, 否则切换到新音频
                // !!!: 初次播放第一条会有问题, 当前 audioPlayer.currentItem != nil时, 即有设置过url
                if playlist[currentTrackIndex] == track && audioPlayer?.currentItem != nil {
                    resumeAudio()
                } else {
                    playTrack(track)
                }
            }
        } else {
            if isPlaying {
                pauseAudio()
            } else {
                resumeAudio()
            }
        }
    }
    
    // 停止音频
    func stopAudio() {
        // FIXME: 规避登出时闪退
        guard let player = audioPlayer, !playlist.isEmpty else { return }
        player.pause()
        seekToPosition(0)
        //audioPlayer = nil
//        //MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    /// 释放音频播放器
    func freeAudioPlayer() {
        stopAudio()

        if let observer = timeObserver {
            audioPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        stateObserver = nil
        failReasonObserver = nil
        
        audioPlayer = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    private func playTrack(at index: Int) {
        guard !playlist.isEmpty, index >= 0, index < playlist.count else {
            print("Invalid track index")
            return
        }
        
        currentTrackIndex = index
        playCurrentTrack()
    }
    
    private func playTrack(_ track: AudioTrack) {
        guard let index = playlist.firstIndex(where: { $0 == track }) else {
            print("Track not found in the playlist")
            return
        }
        
        playTrack(at: index)
    }

    // 暂停音频
    func pauseAudio() {
        audioPlayer?.pause()
    }
    
    // 恢复音频
    private func resumeAudio() {
        audioPlayer?.play()
    }
    
    // 下一曲
    func nextTrack() {
        guard !playlist.isEmpty else { return }
        
        switch playbackMode {
        case .sequential, .none:
            currentTrackIndex = (currentTrackIndex + 1) % playlist.count
        case .shuffle:
            currentTrackIndex = Int.random(in: 0..<playlist.count)
        case .repeatOne:
            // 保持 currentTrackIndex 不变
            break
        }
        //playlist.forEach({ $0 == playlist[currentTrackIndex] ? ($0.playState = .playing) : ($0.playState = .paused) })
        delegate?.audioPlayerManager(self, next: playlist[currentTrackIndex])
        playCurrentTrack()
    }

    // 上一曲
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
        //playlist.forEach({ $0 == playlist[currentTrackIndex] ? ($0.playState = .playing) : ($0.playState = .paused) })
        delegate?.audioPlayerManager(self, previous: playlist[currentTrackIndex])
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
        case .none:
            playbackMode = .none
        }
        
        print("Playback mode changed to: \(playbackMode)")
    }
}

extension AudioPlayerManager {
    
    /// 打断监听, 1. 来电 2. 闹钟 3. 其他音频
    @objc func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            // 中断开始，暂停播放
            print("中断开始，暂停播放")
            pauseAudio()
        case .ended:
            // 中断结束，检查是否需要恢复播放
            print("中断结束，检查是否需要恢复播放")
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resumeAudio()
                }
            }
        @unknown default:
            break
        }
    }
    
    /// 检查音频输出设备
    @objc func handleRouteChange() {
        // 检查音频输出设备
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            if output.portType == .headphones {
                print("耳机插入")
            } else if output.portType == .builtInSpeaker {
                print("使用内置扬声器")
                playlist[currentTrackIndex].playState = .paused
                delegate?.audioPlayerManager(self, track: playlist[currentTrackIndex], didChangeStateTo: .paused)
            } else if output.portType == .bluetoothA2DP {
                print("使用蓝牙音箱")
            } else if output.portType == .airPlay {
                print("使用 AirPlay")
            } else {
                print("其他音频输出设备")
            }
        }
    }

    @objc private func handlePlaybackDidFinish() {
        if playbackMode == .none {
            stopAudio()
            return
        }
        
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
        
        // 停止当前播放
        stopAudio()
      
        // FIXME: 虽然使用 observerTimeControlStatus 监听, 但是这里初次创建时, 还没有audioPlayer, 所以还是需要更新loading状态
        playlist.forEach { $0.playState = $0 == track ? .loading : .paused}
        delegate?.audioPlayerManager(self, track: self.playlist[currentTrackIndex], didChangeStateTo: .loading)
        delegate?.audioPlayerManager(self, track: track, didSwitchTo: .start)

        // 准备播放
        self.readyToPlay(track) {[weak self] track in
            guard let self = self else { return }
            
            // 检查是否解析超时了, 如果超时了取消当次播放
            if track.isLoadTimeout == true {
                LogM.debug("音频已解析超时")
                self.playlist[currentTrackIndex].isLoadTimeout = false
                return
            }
            self.play(track: track)
        }
    }
    
    // 开始播放
    func play(track: AudioTrack) {
        guard let audioUrl = track.audioUrl else { return }

        audioPlayer = AVPlayer(url: audioUrl)
        audioPlayer?.play()

        // 设置监听
        observePlayerProgress()
        observerTimeControlStatus()
        observerWaitFailReason()

        delegate?.audioPlayerManager(self, track: track, didSwitchTo: .ended)
        
        //updateNowPlayingInfo()
        // 更新音频元数据 (主要是时长)
        if track.metaData == nil {
            // 更新时长和封面
            track.preloadArtwork(defaultMeta: nil, placeholder: nil) {[weak self] meta, _ in
                guard let self = self else { return }
                
                if meta == nil {
                    print("音频元数据解析失败")
                    //iToast.makeToast(RLocalizable.string_player_loading_fail.key.localized)
                    self.playlist[currentTrackIndex].playState = .paused
                    self.delegate?.audioPlayerManager(self, track: track, didChangeStateTo: .paused)
                    return
                }
                
                //FIXME: 更新到播放列表缓存 异步情况, 快速切换时, 会导致播放音频下标不一致被错误替换
                self.playlist.first(where: { $0 == track })?.metaData = meta
                // 更新 Now Playing 信息
                self.updateNowPlayingInfo()
                
                //LogM.debug("\(track.cloudData?.title ?? "") 更新音频元数据解析")
                // 回调
                //completion(track)
            }
        }
    }
    
    // 预加载, 并解析音频元数据
    func readyToPlay(_ track: AudioTrack, completion: @escaping (AudioTrack) -> Void) {
        // 开启超时检测
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {[weak self] in
            guard let self = self else { return }
            // 检查是否超时, 1. 当前音频 2. 音频状态为 loading
            if self.playlist[currentTrackIndex] == track, self.playlist[currentTrackIndex].playState == .loading {
                print("音频加载超时")
                //iToast.makeToast(RLocalizable.string_player_loading_fail.key.localized)
                self.playlist[currentTrackIndex].isLoadTimeout = true
                self.pauseAudio()
            }
        }

        // 音频校验 是否载入成功
        let date = Date()
        track.validateCheck(url: track.audioUrl) {[weak self] isValid, status in
            guard let self = self else { return }
            let duration = Date().timeIntervalSince(date)
            LogM.debug("音频校验总耗时: \(duration)")
            
            guard isValid && status == .loaded else {
                //iToast.makeToast(RLocalizable.string_player_loading_fail.key.localized)
                self.playlist[currentTrackIndex].playState = .paused
                self.delegate?.audioPlayerManager(self, track: track, didChangeStateTo: .paused)
                return
            }
            completion(track)
        }
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
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.metaData?.title ?? "Unknown Title"
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.metaData?.artist ?? "Unknown Artist"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.metaData?.duration

        // 播放进度和时长
        if let currentItem = player.currentItem {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.metaData?.duration ?? currentItem.asset.duration.seconds
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
            // 如果当前音频为空, 则不执行播放
            if let self = self, self.audioPlayer?.currentItem == nil {
                return .commandFailed
            }
            // 如果当前音频正在加载, 则不执行播放
            if let self = self, self.playlist[currentTrackIndex].playState == .loading {
                return .commandFailed
            }
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
            guard let self = self, playlist.count > currentTrackIndex, let currentItem = self.audioPlayer?.currentItem else { return }
            
            // 注意规避 po audioPlayer.currentItem?.duration.seconds : nan
//            AVPlayerItem 的 duration 还未被正确设置，或者音频流的 duration 尚未被加载。常见原因包括：
//
//            音频尚未加载：AVPlayerItem 可能还没有准备好，duration 还未更新。
//            网络流媒体问题：如果你在播放流媒体（例如，网络音频），服务器未提供文件的持续时长信息。
//            音频资源无效或损坏：如果音频文件损坏或无法读取，duration 可能无法获取。
            
            // 检查音频资源是否有效
            let isValideDuration = currentItem.duration.isValid && !currentItem.duration.seconds.isNaN
            
            // 播放进度
            if isValideDuration {
                let duration = currentItem.currentTime().seconds
                let track = self.playlist[currentTrackIndex]
                self.delegate?.audioPlayerManager(self, track: track, didUpdateProgressTo: duration)
            }
            
            // 缓冲进度
            if let timeRange = currentItem.loadedTimeRanges.first?.timeRangeValue, isValideDuration {
                //let timeRanges = currentItem.loadedTimeRanges
                let bufferedTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
                let totalDuration = currentItem.duration.isValid ? currentItem.duration.seconds: 0
                let progress = bufferedTime / totalDuration
                //print("缓冲进度：\(progress * 100)%")
                let track = self.playlist[currentTrackIndex]
                self.delegate?.audioPlayerManager(self, track: track, didUpdateBufferProgressTo: Float(progress))
            }
            
            self.updateNowPlayingInfo()
        }
    }
    
    private func observerTimeControlStatus() {
        guard let player = audioPlayer else { return }
        stateObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            guard let self = self else { return }
            let track = self.playlist[currentTrackIndex]
            switch player.timeControlStatus {
            case .paused:
                LogM.debug("timeControlStatus_paused")
                self.isPlaying = false
                self.updateNowPlayingInfo()
                self.playlist.forEach { $0.playState = .paused}
                self.delegate?.audioPlayerManager(self, track: self.playlist[currentTrackIndex], didChangeStateTo: .paused)
            case .playing:
                LogM.debug("timeControlStatus_playing")
                self.isPlaying = true
                self.updateNowPlayingInfo()
                self.playlist.forEach { $0.playState = $0 == track ? .playing : .paused}
                self.delegate?.audioPlayerManager(self, track: self.playlist[currentTrackIndex], didChangeStateTo: .playing)
            case .waitingToPlayAtSpecifiedRate:
                LogM.debug("timeControlStatus_wait")
                self.isPlaying = false
                self.updateNowPlayingInfo()
                self.playlist.forEach { $0.playState = $0 == track ? .loading : .paused}
                self.delegate?.audioPlayerManager(self, track: self.playlist[currentTrackIndex], didChangeStateTo: .loading)
            @unknown default:
                LogM.debug("timeControlStatus_xx")
                break
            }
        }
        
        guard let playerItem = player.currentItem else { return }
        statusObserve = playerItem.observe(\.status, options: [.new]) { [weak self] playerItem, _ in
            guard let self = self else { return }
            switch playerItem.status {
            case .readyToPlay:
                LogM.debug("playerItem_status_readyToPlay")
                self.isPlaying = false
                self.updateNowPlayingInfo()
                self.playlist.enumerated().forEach { $0.element.playState = ($0.offset == self.currentTrackIndex ? .loading : .paused) }
                self.delegate?.audioPlayerManager(self, track: self.playlist[currentTrackIndex], didChangeStateTo: .loading)
            case .failed:
                LogM.debug("playerItem_status_failed")
                self.isPlaying = false
                self.playlist[currentTrackIndex].playState = .paused
                self.delegate?.audioPlayerManager(self, track: self.playlist[currentTrackIndex], didChangeStateTo: .paused)
            default:
                LogM.debug("playerItem_status_default")
                break
            }
        }

    }
    
    private func observerWaitFailReason() {
        guard let player = audioPlayer else { return }
        failReasonObserver = player.observe(\.reasonForWaitingToPlay, options: [.new]) { player, _ in
            if let reason = player.reasonForWaitingToPlay {
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
            }
            
            if let error = player.currentItem?.error as NSError? {
                LogM.debug("@2播放失败: \(error.localizedDescription)")
                switch error.domain {
                case NSURLErrorDomain:
                    LogM.debug("网络问题: \(error.localizedDescription)")
                    print("音频资源加载失败，请检查网络连接")
                case AVFoundationErrorDomain:
                    LogM.debug("音频资源无效: \(error.localizedDescription)")
                    print("音频资源已失效，请更换音频")
                default:
                    LogM.debug("未知错误: \(error.localizedDescription)")
                    print("播放失败，请稍后再试")
                }
            }
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
}
