//
//  AVPlayList.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/26.

import Foundation

/// 资源包
let assetsBundle = Bundle(url: R.file.audioAssetsBundle()!)

/// 播放模式
enum AVPlaybackMode {
    /// 无 (none相比`sequential`, 只是不会自动播放下一曲)
    case none
    /// 顺序播放
    case sequential
    /// 随机播放
    case random
    /// 单曲循环
    case repeatOne
    
    var icon: UIImage? {
        switch self {
        case .none:
            return UIImage(named: "icon_play_mode_none", in: assetsBundle, compatibleWith: nil)
        case .sequential:
            return UIImage(named: "icon_play_mode_sequential", in: assetsBundle, compatibleWith: nil)
        case .random:
            return UIImage(named: "icon_play_mode_random", in: assetsBundle, compatibleWith: nil)
        case .repeatOne:
            return UIImage(named: "icon_play_mode_repeat_one", in: assetsBundle, compatibleWith: nil)
        }
    }
}

// 播放列表
class AVPlaylist {
    /// 播放列表
    private(set) var playlist: [AVPlaylistItem] = []
    /// 当前播放的媒体项索引
    private var currentItemIndex: Int = 0
    /// 存储播放历史
    //private var historyStack: [AVPlaylistItem] = []
    /// 播放模式
    var playbackMode: AVPlaybackMode = .none

    init(playlist: [AVPlaylistItem], playbackMode: AVPlaybackMode) {
        self.playlist = playlist
        self.playbackMode = playbackMode
    }
    
    // 设置播放模式
    func setPlaybackMode(_ mode: AVPlaybackMode) {
        playbackMode = mode
    }
}

extension AVPlaylist {
    
    // 增加一个媒体项
    func addItem(_ item: AVPlaylistItem) {
        playlist.append(item)
    }

    // 移除一个媒体项
    func removeItem(at index: Int) {
        guard index < playlist.count else { return }
        playlist.remove(at: index)
    }

    // 清空播放列表
    func clearPlaylist() {
        playlist.removeAll()
    }
    
    // 获取当前媒体项
    func getCurrentItem() -> AVPlaylistItem? {
        guard playlist.indices.contains(currentItemIndex) else { return nil }
        return playlist[currentItemIndex]
    }

    // 获取下一个媒体项
    func getNextItem() -> AVPlaylistItem? {
        switch playbackMode {
        case .none, .repeatOne, .sequential:
            currentItemIndex = (currentItemIndex + 1) % playlist.count
        case .random:
            // 随机模式, 应该要排除当前项
            currentItemIndex = Int.random(in: 0..<playlist.count)
        }
        return getCurrentItem()
    }

    // 获取上一个媒体项
    /// 在随机模式下，上一个曲目可能需要额外维护一个播放历史栈（historyStack），以便用户可以返回到之前播放的曲目。
    func getPreviousItem() -> AVPlaylistItem? {
        if playbackMode == .random {
            // 随机模式：重新随机选择?
            currentItemIndex = Int.random(in: 0..<playlist.count)
        } else {
            currentItemIndex = (currentItemIndex - 1 + playlist.count) % playlist.count
        }
        return getCurrentItem()
    }
    
    // 获取指定索引的媒体项
    func getPlayItem(at index: Int) -> AVPlaylistItem? {
        guard playlist.indices.contains(index) else { return nil }
        currentItemIndex = index
        return playlist[index]
    }
    
    func setPlayIndex(with item: AVPlaylistItem) {
        guard let index = playlist.firstIndex(where: { $0.id == item.id }) else { return }
        currentItemIndex = index
    }
    
    func setPlayIndex(with index: Int) {
        currentItemIndex = index
    }
}
