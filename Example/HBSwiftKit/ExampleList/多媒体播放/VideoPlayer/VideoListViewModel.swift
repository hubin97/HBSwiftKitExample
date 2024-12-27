//
//  VideoListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class VideoListViewModel: ViewModel {
    
    /**
     【【720P/TVRip】鋼之鍊金術師(2003)(台配國語)-哔哩哔哩】 https://b23.tv/kCdEqi1

     【最强对决 友情的决裂：宇智波风间VS千手新之助-哔哩哔哩】 https://b23.tv/WbWpsJu

     【《灵笼 第二季》 30分钟前瞻PV-哔哩哔哩国创】https://b23.tv/ep781831

     【一段动漫打戏，竟然全是中国功夫的杀人技！纯享版-哔哩哔哩】 https://b23.tv/we04wYc

     【三十年前的老动画至今秒杀一片-哔哩哔哩】 https://b23.tv/PqgifbD

     【史诗级神作《魔兽争霸3》是怎么改变游戏历史的？-哔哩哔哩】 https://b23.tv/6rK15ue
     
     "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/membership/66c55804a7f43d1fde74c9b0.mp4"
     */
    
    // B站视频下载工具 https://snapany.com/zh/bilibili
    
    enum VideoType {
        // 本地视频
        case local
        // 网络视频
        case remote
        
        var value: String {
            switch self {
            case .local:
                return "本地视频"
            case .remote:
                return "网络视频"
            }
        }
    }
    
    struct VideoMeta {
        let type: VideoType
        let playList: [AVPlaylistItem]
    }
    
    let sections: [VideoMeta] = [
        VideoMeta(type: .local, playList: [AVPlaylistItem(id: 0, title: "【最强对决】 友情的决裂：宇智波风间VS千手新之助-哔哩哔哩", source: "友情的决裂.mp4", artist: "bilibili", imageUrl: "http://i2.hdslb.com/bfs/archive/4ab4d91063eec2c0399eae9acf54f37cd86d1ea5.jpg")]),
        VideoMeta(type: .remote, playList: [
            AVPlaylistItem(id: 0, title: "【720P/TVRip】鋼之鍊金術師(2003)(台配國語)-哔哩哔哩", url: "https://upos-sz-mirror08c.bilivideo.com/upgcxcode/15/51/20185115/20185115_da3-1-16.mp4?e=ig8euxZM2rNcNbRVhwdVhwdlhWdVhwdVhoNvNC8BqJIzNbfq9rVEuxTEnE8L5F6VnEsSTx0vkX8fqJeYTj_lta53NCM=&uipk=5&nbs=1&deadline=1735289463&gen=playurlv2&os=08cbv&oi=1782024106&trid=2e4a5d8400b24d6687c5a8fc87cf35f5h&mid=0&platform=html5&og=hw&upsig=d9ad85aad041c84e94bc7ae4eb0d7112&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform,og&bvc=vod&nettype=0&f=h_0_0&bw=53232&logo=80000000", artist: "bilibili"),
            AVPlaylistItem(id: 1, title: "【最强对决】 友情的决裂：宇智波风间VS千手新之助-哔哩哔哩", url: "https://cn-sh-ct-01-07.bilivideo.com/upgcxcode/03/24/1487622403/1487622403-1-16.mp4?e=ig8euxZM2rNcNbRVhwdVhwdlhWdVhwdVhoNvNC8BqJIzNbfq9rVEuxTEnE8L5F6VnEsSTx0vkX8fqJeYTj_lta53NCM=&uipk=5&nbs=1&deadline=1735289492&gen=playurlv2&os=bcache&oi=1782024106&trid=0000a67eb4b23ccd4cbcbffb4315502c0c2bh&mid=0&platform=html5&og=hw&upsig=32c89df658e1f9d72a8b3023b30ae060&uparams=e,uipk,nbs,deadline,gen,os,oi,trid,mid,platform,og&cdnid=88207&bvc=vod&nettype=0&f=h_0_0&bw=42898&logo=80000000",  artist: "bilibili", imageUrl: "http://i2.hdslb.com/bfs/archive/4ab4d91063eec2c0399eae9acf54f37cd86d1ea5.jpg")])
    ]
    
//    lazy var avPlayerManager: AVPlayerManager = {
//        return AVPlayerManager.shared
//    }()
    
//    required init() {
//        super.init()
//        self.avPlayerManager.setPlaylist(AVPlaylist(playlist: playList, playbackMode: .none))
//    }
}

// MARK: - private mothods
extension VideoListViewModel { 
}

// MARK: - call backs
extension VideoListViewModel { 
}

// MARK: - delegate or data source
extension VideoListViewModel { 
}

// MARK: - other classes
