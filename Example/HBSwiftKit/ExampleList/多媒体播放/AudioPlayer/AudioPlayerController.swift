//
//  AudioPlayerController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import AVFoundation

// MARK: - global var and methods

// MARK: - main class
class AudioPlayerController: ViewController, ViewModelProvider {
    typealias ViewModelType = AudioPlayerViewModel
    
    lazy var avPlayerManager: AVPlayerManager = {
        return AVPlayerManager.shared
    }()
    
    lazy var player: AVPlayer? = {
        return avPlayerManager.getPlayer()
    }()

    override func setupLayout() {
        super.setupLayout()
        self.naviBar.isHidden = true
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        if let playItem = vm.playItem {
            avPlayerManager.play(item: playItem)
        }
    }
}

// MARK: - private mothods
extension AudioPlayerController { 
}

// MARK: - call backs
extension AudioPlayerController { 
}

// MARK: - delegate or data source
extension AudioPlayerController {
    
}

// MARK: - other classes
