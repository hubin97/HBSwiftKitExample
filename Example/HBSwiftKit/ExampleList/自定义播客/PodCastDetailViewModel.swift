//
//  PodCastDetailViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class PodCastDetailViewModel: ViewModel {
    
    // 当前播放的音频
    var currentTrack: AudioTrack?
    // 选择进入的音频
    var audioTrack: AudioTrack!
    convenience init(with item: AudioTrack) {
        self.init()
        self.audioTrack = item
    }
}

// MARK: - private mothods
extension PodCastDetailViewModel { 
}

// MARK: - call backs
extension PodCastDetailViewModel { 
}

// MARK: - delegate or data source
extension PodCastDetailViewModel { 
}

// MARK: - other classes
