//
//  PodCastListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import Foundation
import RxRelay
// MARK: - global var and methods

// MARK: - main class
class PodCastListViewModel: ViewModel {
    
//    https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/m1.mp3
//    https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/m2.mp3
//    https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/m3.mp3
//    https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/m4.mp3
//    https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/big1.mp3
    
    var trackListRelay: BehaviorRelay<[AudioTrack]> = BehaviorRelay(value: [])
    
    required init() {
        let trackList = [
            AudioTrack(audioUrl: Bundle.main.url(forResource: "五音Jw-明月天涯", withExtension: "mp3"), artwork: AudioTrack.Artwork.remote(URL(string: "https://bkimg.cdn.bcebos.com/pic/91ef76c6a7efce1bfaf3ea92a051f3deb58f6589?x-bce-process=image/format,f_auto/quality,Q_70/resize,m_lfit,limit_1,w_512")!), desc: "五音Jw-明月天涯", playCount: 3120, updateTime: "2024-12-09"),
            AudioTrack(audioUrl: Bundle.main.url(forResource: "萧忆情Alex - 不谓侠", withExtension: "mp3"), artwork: AudioTrack.Artwork.remote(URL(string: "https://i.kfs.io/album/global/121624025,0v1/fit/500x500.jpg")!), title: "萧忆情Alex - 不谓侠", artist: "萧忆情Alex", desc: "萧忆情Alex - 不谓侠", playCount: 3120, updateTime: "2024-12-09"),
            AudioTrack(audioUrl: Bundle.main.url(forResource: "李荣浩 - 老街", withExtension: "mp3"), artwork: AudioTrack.Artwork.remote(URL(string: "https://static.fotor.com.cn/assets/stickers/freelancer_hyx_1016_06/763c2917-7e80-4514-8434-ff0e2671b55c_medium_thumb.jpg")!), title: "李荣浩 - 老街", artist: "李荣浩", desc: "李荣浩 - 老街", playCount: 13120, updateTime: "2024-12-09"),
            AudioTrack(audioUrl: URL(string: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/m1.mp3"), artwork: AudioTrack.Artwork.remote(URL(string: "https://bkimg.cdn.bcebos.com/pic/91ef76c6a7efce1bfaf3ea92a051f3deb58f6589?x-bce-process=image/format,f_auto/quality,Q_70/resize,m_lfit,limit_1,w_512")!), desc: "周杰伦 - xxx", playCount: 13120, updateTime: "2024-12-09"),
            AudioTrack(audioUrl: URL(string: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/log/big1.mp3"),  playCount: 13120, updateTime: "2024-12-09")
        ]
        
        trackListRelay.accept(trackList)
    }
    
    let posterViewHeight: CGFloat = 216
    let rowHeight: CGFloat = 100
    var contentSize: CGSize {
        return CGSize(width: 0, height: CGFloat(trackListRelay.value.count) * rowHeight + posterViewHeight)
    }
}

// MARK: - private mothods
extension PodCastListViewModel { 
}

// MARK: - call backs
extension PodCastListViewModel { 
}

// MARK: - delegate or data source
extension PodCastListViewModel { 
}

// MARK: - other classes
struct PodCastItem {
    let title: String
    let artist: String
    let artwork: String
    let audioUrl: URL?
    
    let desc: String
    let playCount: String
    let updateTime: String
}

struct PodCastModel {
    let artwork: String
    let title: String
    let desc: String
    let playCount: String
    let updateTime: String
    let item: PodCastItem? = nil
}
