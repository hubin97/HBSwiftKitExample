//
//  VideoPlayerViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class VideoPlayerViewModel: ViewModel {
    
    var playItem: AVPlaylistItem?
    convenience init(item: AVPlaylistItem) {
        self.init()
        self.playItem = item
    }
    
    convenience init(index: Int) {
        self.init()
        self.playItem = AVPlayerManager.shared.getPlaylist()?.getPlayItem(at: index)
    }
}

// MARK: - private mothods
extension VideoPlayerViewModel { 
}

// MARK: - call backs
extension VideoPlayerViewModel { 
}

// MARK: - delegate or data source
extension VideoPlayerViewModel { 
}

// MARK: - other classes
