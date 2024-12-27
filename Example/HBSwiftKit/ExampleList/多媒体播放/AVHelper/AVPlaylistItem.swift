//
//  AVPlaylistItem.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation
import MediaPlayer
import Kingfisher

// 多媒体 元数据
struct MediaMetaData {
    /// 音频标题
    var title: String?
    /// 艺术家名称
    var artist: String?
    /// 专辑名称
    var album: String?
    /// 音频时长
    var duration: TimeInterval?
    /// 封面图片, 不是所有 mp3 都有封面
    var artwork: UIImage?
}

// 播放列表中的单个媒体项
class AVPlaylistItem: Equatable {
    
    static func == (lhs: AVPlaylistItem, rhs: AVPlaylistItem) -> Bool {
        return lhs.id == rhs.id || lhs.url == rhs.url
    }
    
    let id: Int
    let url: URL
    var title: String?
    var artist: String?
    var duration: TimeInterval?
    var imageUrl: String?
    
    // 缓存属性
    private(set) var coverImage: UIImage?
    private(set) var cachedMediaArtwork: MPMediaItemArtwork?
    
    // 多媒体 元数据
    var mediaMeta: MediaMetaData?

    //
    init(id: Int, title: String, url: String, artist: String? = nil, imageUrl: String? = nil, duration: TimeInterval? = nil) {
        self.id = id
        self.title = title
        self.url = URL(string: url)!
        self.artist = artist
        self.imageUrl = imageUrl
        self.duration = duration
    }
    
    init(id: Int, title: String, source: String, artist: String? = nil, imageUrl: String? = nil, duration: TimeInterval? = nil) {
        self.id = id
        self.title = title
        self.url = Bundle.main.path(forResource: source, ofType: nil).flatMap { URL(fileURLWithPath: $0) }!
        self.artist = artist
        self.imageUrl = imageUrl
        self.duration = duration
    }
}

extension AVPlaylistItem {
    
    /// 是否使用解析数据
    func useMetadata() -> Bool {
        return AVPlayerManager.shared.getNowPlayingUpdater()?.getUseMetadata() ?? false
    }
    
    // 异步更新封面图片
    func asyncUpdateArtwork() {
        if mediaMeta == nil {
            if useMetadata() {
                preloadArtwork(loadMetaData: useMetadata(), defaultMeta: nil) { _, _ in }
            } else {
                let defaultMeta = MediaMetaData(title: title, artist: artist, album: nil, duration: duration, artwork: nil)
                preloadArtwork(loadMetaData: useMetadata(), defaultMeta: defaultMeta) { _, _ in }
            }
        }
    }
    
    /// 解析音频文件元数据, 并缓存结果, 没解析到, 使用默认指定
    /// - Parameters:
    ///  - loadMetaData: 是否加载元数据
    func preloadArtwork(loadMetaData: Bool = false, defaultMeta: MediaMetaData?, placeholder: UIImage? = nil, completion: @escaping (MediaMetaData?, UIImage?) -> Void) {
        
        if !loadMetaData {
            // 同步外部数据到元数据 (仅时长由解析获取)
            let asset = AVAsset(url: url)
            let duration = CMTimeGetSeconds(asset.duration)
            self.mediaMeta = MediaMetaData(title: defaultMeta?.title, artist: defaultMeta?.artist, album: nil, duration: duration, artwork: nil)
            
            self.updateArtwork(with: self.mediaMeta) { metaData, image in
                DispatchQueue.main.async {
                    completion(metaData, image)
                }
            }
            return
        }
        
        // 加载音频元数据
        self.analysisMediaMetadata(from: url) { [weak self] data in
            guard let self = self, let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
                return
            }
            
            // 缓存元数据
            self.mediaMeta = data
            
            // 更新封面
            self.updateArtwork(with: data) { metaData, image in
                DispatchQueue.main.async {
                    completion(metaData, image)
                }
            }
        }
    }

}

// MARK: - 音频元数据解析
extension AVPlaylistItem {
        
    /// 从音频文件中加载元数据
    private func analysisMediaMetadata(from url: URL, completion: @escaping (MediaMetaData?) -> Void) {
        let asset = AVAsset(url: url)
        
        let metadata = asset.commonMetadata
        // 获取时长
        let duration = CMTimeGetSeconds(asset.duration)
        // 提取元数据
        let title = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: .common).first?.stringValue
        let artist = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: .common).first?.stringValue
        let album = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyAlbumName, keySpace: .common).first?.stringValue
        // 获取封面
        var artworkImage: UIImage?
        if let artworkData = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: .common).first?.dataValue {
            artworkImage = UIImage(data: artworkData)
        }
        completion(MediaMetaData(title: title, artist: artist, album: album, duration: duration, artwork: artworkImage))
    }
}

// MARK: - 封面资源更新
extension AVPlaylistItem {
    
    /// 封面资源更新
    private func updateArtwork(with metaData: MediaMetaData?, completion: @escaping (MediaMetaData?, UIImage?) -> Void) {
        // 使用音频文件中提取到的封面图片
        if let artworkImage = metaData?.artwork {
            self.coverImage = artworkImage
            self.cachedMediaArtwork = MPMediaItemArtwork(boundsSize: artworkImage.size, requestHandler: { _ in artworkImage })
            completion(metaData, artworkImage)
        } else {
            // 如果没有封面，尝试使用传入的封面图
            self.defalutArtwork(picture: imageUrl, placeholder: nil) {[weak self] image, mediaArtwork in
                self?.coverImage = image
                self?.cachedMediaArtwork = mediaArtwork
                completion(metaData, image)
            }
        }
    }
    
    /// 异步获取封面图片和 MPMediaItemArtwork，并缓存结果
    /// - Parameters:
    ///   - placeholder: 占位图片
    ///   - completion: 回调，返回封面图片和 MPMediaItemArtwork
    private func defalutArtwork(picture: String?, placeholder: UIImage?, completion: @escaping (UIImage?, MPMediaItemArtwork?) -> Void) {
        // 如果已经缓存，直接返回
        if let cachedImage = coverImage, let cachedMediaArtwork = cachedMediaArtwork {
            completion(cachedImage, cachedMediaArtwork)
            return
        }
        
        // 如果从音频文件中没有解析到封面图片，使用传入的 artwork
        if let artworkUrl = URL(string: picture?.urlEncoded ?? "") {
            // 网络封面图片，使用 URL 加载远程封面
            KingfisherManager.shared.retrieveImage(with: artworkUrl) { result in
                switch result {
                case .success(let value):
                    let mediaArtwork = MPMediaItemArtwork(boundsSize: value.image.size) { _ in value.image }
                    completion(value.image, mediaArtwork)
                case .failure:
                    // 加载失败使用占位图
                    if let placeholder = placeholder {
                        let mediaArtwork = MPMediaItemArtwork(boundsSize: placeholder.size) { _ in placeholder }
                        completion(placeholder, mediaArtwork)
                    } else {
                        completion(nil, nil)
                    }
                }
            }
        } else {
            // 如果没有封面图，返回占位图或 nil
            if let placeholder = placeholder {
                let mediaArtwork = MPMediaItemArtwork(boundsSize: placeholder.size) { _ in placeholder }
                completion(placeholder, mediaArtwork)
            } else {
                completion(nil, nil)
            }
        }
    }
}
