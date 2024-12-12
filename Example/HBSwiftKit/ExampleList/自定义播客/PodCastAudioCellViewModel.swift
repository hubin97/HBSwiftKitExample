//
//  PodCastListCellViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import RxRelay
import Kingfisher

// MARK: - main class
class PodCastAudioCellViewModel: TableViewCellViewModel {
    
    var titleRelay = BehaviorRelay<String?>(value: nil)
    var descRelay = BehaviorRelay<String?>(value: nil)
    var playCountRelay = BehaviorRelay<String?>(value: nil)
    var durationRelay = BehaviorRelay<String?>(value: nil)
    var updateTimeRelay = BehaviorRelay<String?>(value: nil)
    
    // 外部提供封面
    var pictureRelay = BehaviorRelay<String?>(value: nil)
    // MP3元数据解析到的封面
    var artworkRelay = BehaviorRelay<UIImage?>(value: nil)
    
    var audioTrack: AudioTrack?
    convenience init(item: AudioTrack) {
        self.init()
        self.audioTrack = item
        self.showDefaultData(with: item)
        self.updateMetaData()
    }
    
    // 默认数据
    func showDefaultData(with item: AudioTrack) {
        titleRelay.accept(item.title)
        descRelay.accept(item.desc)
        pictureRelay.accept(item.artworkUrl)
        
        let minute = String(format: "%.1f", (item.duration ?? 0)/60)
        durationRelay.accept("时长: \(minute)分钟")
        
        updateTimeRelay.accept("更新时间: \(item.updateTime ?? "")")

        if let playCount = item.playCount {
            let value = String(format: "%.1f", playCount/1000)
            let playValue = playCount > 1000 ? "播放量: \(value)k": "播放量: \(playCount)"
            playCountRelay.accept(playValue)
        }
    }
    
    // 更新音频元数据
    func updateMetaData() {
        audioTrack?.preloadArtwork(placeholder: nil) { [weak self] metaData, coverImage in
            guard let self = self, let metaData = metaData else { return }
            print("metaData: \(metaData)")
            
            titleRelay.accept(metaData.title ?? audioTrack?.title)
            descRelay.accept(metaData.artist ?? audioTrack?.desc)
            
            let duration = metaData.duration ?? 0
            let minute = String(format: "%.1f", duration/60)
            durationRelay.accept("时长: \(minute)分钟")

            updateTimeRelay.accept("更新时间: \(audioTrack?.updateTime ?? "")")
            
            if let playCount = audioTrack?.playCount {
                let value = String(format: "%.1f", playCount/1000)
                playCountRelay.accept("播放量: \(value)k")
            }

            if let coverImage = coverImage {
                self.artworkRelay.accept(coverImage)
            }
        }
    }
    
    deinit {
        print("deinit \(self)")
    }
}

// MARK: - private mothods
extension PodCastAudioCellViewModel {
    
    func tapIconView() {
        print("tapIconView")
        //let item = vm.trackListRelay.value[indexPath.row]
        if let item = audioTrack {
            AudioPlayerManager.shared.playTrack(item)
        }
    }
}
