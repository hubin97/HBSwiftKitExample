//
//  PodCastAlbumDetailViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import Foundation
import RxRelay
// MARK: - global var and methods

// MARK: - main class
class PodCastAlbumDetailViewModel: ViewModel {
     
    let posterViewHeight: CGFloat = 216
    let rowHeight: CGFloat = 100
    var contentSize: CGSize {
        return CGSize(width: 0, height: CGFloat(trackListRelay.value.count) * rowHeight + posterViewHeight)
    }

    var trackListRelay: BehaviorRelay<[AudioTrack]> = BehaviorRelay(value: [])
    var audioListRelay: BehaviorRelay<[PodcastAlbumAudioListMeta]> = BehaviorRelay(value: [])
    
    var albumMeta: PodcastAlbumListMeta?
    convenience init(with albumMeta: PodcastAlbumListMeta) {
        self.init()
        self.albumMeta = albumMeta
        self.fetchAlbumAudioList()
    }
}

// MARK: - private mothods
extension PodCastAlbumDetailViewModel {
    
    func fetchAlbumAudioList() {
        //guard let albumId = albumMeta?.id else { return }
        PodcastRequest.albumItems(albumId: 1).done { audioList in
            // PodcastAlbumAudioListMeta
            self.audioListRelay.accept(audioList)
            self.getTrackList(with: audioList)
        }.catch { error in
            print("error: \(error)")
        }
    }
    
//    func setAlbumRead() {
//        guard let albumId = albumMeta?.id else { return }
//        PodcastRequest.albumRead(albumId: albumId).done { _ in
//            print("专辑设置为已读")
//        }.catch { error in
//            print("error: \(error)")
//        }
//    }
}

// MARK: - call backs
extension PodCastAlbumDetailViewModel {
    
    func getTrackList(with audioList: [PodcastAlbumAudioListMeta]) {
        let tracks = audioList.map { item in
            AudioTrack(audioUrl: URL(string: item.resourceUrl), artworkUrl: item.picture, title: item.title, duration: TimeInterval(item.duration/1000), desc: item.description, playCount: item.playCount, updateTime: item.updateTimeStr)
        }
        self.trackListRelay.accept(tracks)
    }
}
