//
//  PodCastListCellViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import RxRelay
import Kingfisher

// MARK: - main class
class PodCastListCellViewModel: TableViewCellViewModel {
    
    var titleRelay = BehaviorRelay<String?>(value: nil)
    var descRelay = BehaviorRelay<String?>(value: nil)
    var playCountRelay = BehaviorRelay<String?>(value: nil)
    var durationRelay = BehaviorRelay<String?>(value: nil)
    var updateTimeRelay = BehaviorRelay<String?>(value: nil)
    var artworkRelay = BehaviorRelay<UIImage?>(value: nil)
    
    var audioTrack: AudioTrack?
    convenience init(item: AudioTrack) {
        self.init()
        self.audioTrack = item
        self.updateData()
    }
    
    func updateData() {
        audioTrack?.preloadArtwork(placeholder: nil) { [weak self] metaData, coverImage in
            /// self nil
            guard let self = self, let audioTrack = audioTrack else { return }
            titleRelay.accept(audioTrack.title)
            descRelay.accept(audioTrack.artist)
            artworkRelay.accept(coverImage)
            playCountRelay.accept("播放量: \(audioTrack.playCount ?? 0/1000)k")
            updateTimeRelay.accept("更新时间: \(audioTrack.updateTime ?? "")")
            if let duration = audioTrack.duration {
                let minute = NSDecimalNumber(value: duration / 60)
                durationRelay.accept("时长: \(minute)分钟")
            }
        }
    }
    
    deinit {
        print("deinit \(self)")
    }
}

// MARK: - private mothods
extension PodCastListCellViewModel {
    
    func tapIconView() {
        print("tapIconView")
        //let item = vm.trackListRelay.value[indexPath.row]
        if let item = audioTrack {
            AudioPlayerManager.shared.playTrack(item)
        }
    }
}

// MARK: - call backs
extension PodCastListCellViewModel { 
}

// MARK: - delegate or data source
extension PodCastListCellViewModel { 
}

// MARK: - other classes
