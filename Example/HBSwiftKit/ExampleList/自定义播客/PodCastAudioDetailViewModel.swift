//
//  PodCastAudioDetailViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class PodCastAudioDetailViewModel: ViewModel {
    
    // 当前播放的音频
    var currentTrack: AudioTrack?
    // 选择进入的音频
    var audioTrack: AudioTrack!
    convenience init(with item: AudioTrack) {
        self.init()
        self.audioTrack = item
        self.currentTrack = item
    }
    
//    var audioMeta: PodcastAlbumAudioListMeta?
//    convenience init(with item: PodcastAlbumAudioListMeta) {
//        self.init()
//        self.audioMeta = item
//        
//        self.audioTrack = AudioTrack(audioUrl: URL(string: item.resourceUrl), artwork: AudioTrack.Artwork.remote(URL(string: item.picture)!), title: item.title, duration: TimeInterval(item.duration/1000), desc: item.description, playCount: item.playCount, updateTime: item.updateTime)
//    }
}

// MARK: - private mothods
extension PodCastAudioDetailViewModel { 
}

// MARK: - call backs
extension PodCastAudioDetailViewModel { 
}

// MARK: - delegate or data source
extension PodCastAudioDetailViewModel { 
}

// MARK: - other classes
