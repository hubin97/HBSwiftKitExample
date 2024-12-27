//
//  VideoPlayerController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import AVFoundation

// MARK: - global var and methods

// MARK: - main class
class VideoPlayerController: ViewController, ViewModelProvider {
    typealias ViewModelType = VideoPlayerViewModel

    lazy var avPlayerManager: AVPlayerManager = {
        return AVPlayerManager.shared
    }()
    
    lazy var player: AVPlayer? = {
        return avPlayerManager.getPlayer()
    }()
    
    lazy var playerPreview: UIScrollView = {
        let view = UIScrollView(frame: self.view.bounds)
        view.backgroundColor = .black
        view.minimumZoomScale = 0.5
        view.maximumZoomScale = 3
        return view
    }()
    
    override func setupLayout() {
        super.setupLayout()
        // self.naviBar.title = "Video Player"
        self.naviBar.isHidden = true
        view.addSubview(playerPreview)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        if let playItem = vm.playItem {
            avPlayerManager.play(item: playItem)
            
            if let playerLayer = avPlayerManager.getPlayerLayer() {
                playerPreview.layer.insertSublayer(playerLayer, at: 0)
                playerLayer.frame = playerPreview.bounds
            }
        }
    }
}

// MARK: - private mothods
extension VideoPlayerController { 
}

// MARK: - call backs
extension VideoPlayerController { 
}

// MARK: - delegate or data source
extension VideoPlayerController { 
}

// MARK: - other classes
