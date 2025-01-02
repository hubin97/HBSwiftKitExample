//
//  AudioListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class AudioListViewModel: ViewModel {
    
    enum AudioType {
        // 本地
        case local
        // 网络
        case remote
        
        var value: String {
            switch self {
            case .local:
                return "本地音频"
            case .remote:
                return "网络音频"
            }
        }
    }
    
    struct AudioMeta {
        let type: AudioType
        let playList: [AVPlaylistItem]
    }
  
    // swiftlint:disable line_length
    var sections: [AudioMeta] = [
        AudioMeta(type: .local, playList: [
            AVPlaylistItem(id: 100, title: "五音Jw-明月天涯", source: "五音Jw-明月天涯.mp3", artist: "五音Jw"),
            AVPlaylistItem(id: 101, title: "李荣浩 - 老街", source: "李荣浩 - 老街.mp3", artist: "李荣浩"),
            AVPlaylistItem(id: 102, title: "萧忆情Alex - 不谓侠", source: "萧忆情Alex - 不谓侠.mp3", artist: "萧忆情Alex"),
            AVPlaylistItem(id: 103, title: "友情的决裂", source: "友情的决裂.mp4")
        ]),
        AudioMeta(type: .remote, playList: [
            AVPlaylistItem(id: 1000, title: "Dưới Những Cơn Mưa", url: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Audio%2FDuoi-Nhung-Con-Mua-Mr-Siro.mp3?alt=media&token=000e1b74-9b02-426b-82b7-771d12460e21", artist: "Mr.Siro", imageUrl: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Image%2FDuoi-Nhung-Con-Mua-Mr-Siro.jpg?alt=media&token=ef8a993d-9b6b-4d46-aed5-0e8545783ea5"),
            AVPlaylistItem(id: 1001, title: "Rực Rỡ Tháng Năm", url: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Audio%2FRuc-Ro-Thang-Nam-My-Tam.mp3?alt=media&token=c426a029-c5c1-4b73-ac92-f40338466afa", artist: "My Tam", imageUrl: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Image%2FRuc-Ro-Thang-Nam-My-Tam.jpg?alt=media&token=112fa097-969e-492a-b1ad-9d6894bd98f6"),
            AVPlaylistItem(id: 1002, title: "Xin Đừng Lặng Im", url: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Audio%2FXin-Dung-Lang-Im-Soobin-Hoang-Son.mp3?alt=media&token=5ecf4f8d-c120-449a-bf2e-7a998bfbf3e0", artist: "Soobin Hoang Son", imageUrl: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Image%2FXin-Dung-Lang-Im-Soobin-Hoang-Son.jpg?alt=media&token=311e6618-1721-40f1-a150-a5632c974ee5"),
            AVPlaylistItem(id: 1003, title: "Gửi Anh Xa Nhớ", url: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Audio%2FGui-Anh-Xa-Nho-Bich-Phuong.mp3?alt=media&token=2a835108-d7ae-4927-b33d-2ab64f8b47dc", artist: "Bich Phuong", imageUrl: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Image%2FGui-Anh-Xa-Nho-Bich-Phuong.jpg?alt=media&token=7a04ac2b-5f40-4808-928e-3f1b1f302c15"),
            AVPlaylistItem(id: 1004, title: "Cớ Sao Giờ Lại Chia Xa", url: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Audio%2FCo-Sao-Gio-Lai-Chia-Xa-Bich-Phuong.mp3?alt=media&token=1e84ce97-5f41-48f6-bbb2-1cc226b9f6ff", artist: "Bich Phuong", imageUrl: "https://firebasestorage.googleapis.com/v0/b/music-compose.appspot.com/o/Image%2FCo-Sao-Gio-Lai-Chia-Xa-Bich-Phuong.jpg?alt=media&token=6badc14b-8ca9-4e8f-9f54-e886af73af76")
        ])
    ]
}

// MARK: - private mothods
extension AudioListViewModel { 
}

// MARK: - call backs
extension AudioListViewModel { 
}

// MARK: - delegate or data source
extension AudioListViewModel { 
}

// MARK: - other classes
