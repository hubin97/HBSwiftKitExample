//
//  AVPlayerNotification.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation
import AVFoundation

// MARK: - global var and methods

// MARK: - main class
class AVPlayerNotification {
    
    private var playerManager: AVPlayerManager
    
    init(playerManager: AVPlayerManager) {
        self.playerManager = playerManager
        self.setupNoti()
    }
    
    func setupNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackError), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
}

// MARK: - private mothods
extension AVPlayerNotification {
    
    /// 打断监听, 1. 来电 2. 闹钟 3. 其他音频
    @objc func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            // 中断开始，暂停播放
            print("中断开始，暂停播放")
            playerManager.pause()
        case .ended:
            // 中断结束，检查是否需要恢复播放
            print("中断结束，检查是否需要恢复播放")
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    playerManager.resume()
                }
            }
        @unknown default:
            break
        }
    }
    
    /// 检查音频输出设备
    @objc func handleRouteChange() {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            if output.portType == .headphones {
                print("耳机插入")
            } else if output.portType == .builtInSpeaker {
                print("使用内置扬声器")
                //playlist[currentTrackIndex].playState = .paused
                //delegate?.audioPlayerManager(self, track: playlist[currentTrackIndex], didChangeStateTo: .paused)
            } else if output.portType == .bluetoothA2DP {
                print("使用蓝牙音箱")
            } else if output.portType == .airPlay {
                print("使用 AirPlay")
            } else {
                print("其他音频输出设备")
            }
        }
    }

    /// 播放结束处理
    @objc private func handlePlaybackDidFinish() {
        let playbackMode = playerManager.getPlaylist()?.playbackMode ?? .none
        if playbackMode == .none {
            playerManager.stop()
            return
        }
        
        if playbackMode == .repeatOne {
            playerManager.play()
        } else if playbackMode == .random || playbackMode == .sequential {
            playerManager.playNext()
        }
    }
    
    @objc private func handlePlaybackError(notification: Notification) {
        if let failedItem = notification.object as? AVPlayerItem,
           let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            print("播放失败: \(error.localizedDescription)")
            print("失败的音频项: \(failedItem)")
        }
    }
}

// MARK: - call backs
extension AVPlayerNotification { 
}

// MARK: - delegate or data source
extension AVPlayerNotification { 
}

// MARK: - other classes
