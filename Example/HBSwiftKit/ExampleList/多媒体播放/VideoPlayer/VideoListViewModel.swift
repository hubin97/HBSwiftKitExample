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
        VideoMeta(type: .local, playList: [
            AVPlaylistItem(id: 200, title: "【最强对决】 友情的决裂：宇智波风间VS千手新之助-哔哩哔哩", source: "友情的决裂.mp4", artist: "bilibili", imageUrl: "http://i2.hdslb.com/bfs/archive/4ab4d91063eec2c0399eae9acf54f37cd86d1ea5.jpg"),
            AVPlaylistItem(id: 201, title: "【最强对决】 友情的决裂Intro", source: "友情的决裂intro.mp4", artist: "bilibili", imageUrl: "http://i2.hdslb.com/bfs/archive/4ab4d91063eec2c0399eae9acf54f37cd86d1ea5.jpg")
        ]),
        VideoMeta(type: .remote, playList: [
            AVPlaylistItem(id: 2000, title: "【720P/TVRip】三十年前的老动画至今秒杀一片-哔哩哔哩", url: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67877ca3e4b0604661da5888.mp4", artist: "bilibili"),
            AVPlaylistItem(id: 2001, title: "【哔哩哔哩】一段动漫打戏，竟然全是中国功夫的杀人技！", url: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67958ef8e4b0054dc8430e03.mp4", artist: "bilibili"),
            AVPlaylistItem(id: 2002, title: "【最强对决】 友情的决裂intro-哔哩哔哩", url: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67877d72e4b0604661da588a.mp4",  artist: "bilibili", imageUrl: "http://i2.hdslb.com/bfs/archive/4ab4d91063eec2c0399eae9acf54f37cd86d1ea5.jpg"),
            AVPlaylistItem(id: 2003, title: "【最强对决】 友情的决裂：宇智波风间VS千手新之助-哔哩哔哩", url: "https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/feedback/67877d72e4b0604661da588b.mp4",  artist: "bilibili", imageUrl: "http://i2.hdslb.com/bfs/archive/4ab4d91063eec2c0399eae9acf54f37cd86d1ea5.jpg")])
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
