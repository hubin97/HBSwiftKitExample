//
//  AudioPlayerViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class AudioPlayerViewModel: ViewModel {

    let operateItems = ["收藏", "评论", "分享", "更多"]
    
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
extension AudioPlayerViewModel { 
}

// MARK: - call backs
extension AudioPlayerViewModel { 
}

// MARK: - delegate or data source
extension AudioPlayerViewModel { 
}

// MARK: - other classes
