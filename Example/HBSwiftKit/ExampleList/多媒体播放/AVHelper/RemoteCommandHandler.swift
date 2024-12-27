//
//  RemoteCommandHandler.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation
import MediaPlayer

class RemoteCommandHandler {
    
    private var playerManager: AVPlayerManager
    
    init(playerManager: AVPlayerManager) {
        self.playerManager = playerManager
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放
        commandCenter.playCommand.addTarget { [weak self] _ in
            if let self = self, self.playerManager.getPlayer()?.currentItem == nil {
                return .commandFailed
            }
            self?.playerManager.resume()
            return .success
        }
        
        // 暂停
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.playerManager.pause()
            return .success
        }
        
        // 停止
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.playerManager.stop()
            return .success
        }
        
        // 下一曲
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playerManager.playNext()
            return .success
        }
        
        // 上一曲
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playerManager.playPrevious()
            return .success
        }
        
        // 设置播放进度
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            
            if let changeEvent = event as? MPChangePlaybackPositionCommandEvent {
                let newPosition = changeEvent.positionTime
                self.playerManager.seek(to: newPosition)
                return .success
            }
            return .commandFailed
        }
    }
}
