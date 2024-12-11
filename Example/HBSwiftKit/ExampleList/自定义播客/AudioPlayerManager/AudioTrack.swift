//
//  AudioTrack.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import AVFoundation
import MediaPlayer
import Kingfisher

// MP3 元数据
struct MP3MetaData {
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

// 音频轨道
class AudioTrack: Equatable {
    
    // 比较音频轨道是否相等, 来源一致即相等
    static func == (lhs: AudioTrack, rhs: AudioTrack) -> Bool {
        return lhs.audioUrl == rhs.audioUrl
    }
    
    enum Artwork {
        case local(UIImage)  // 本地图片
        case remote(URL)     // 网络图片 URL
    }
    
    let audioUrl: URL?       // 音频资源 URL
    let artwork: Artwork?    // 封面图片（支持本地和网络）
    
    var metaData: MP3MetaData? // MP3 元数据
    
    // 基本信息 (mp3 可解析参数字段)
    var title: String?        // 曲目标题
    var album: String?        // 专辑名称
    var artist: String?       // 艺术家名称
    var duration: TimeInterval? // 音频时长（可选）
        
    // 其他信息 (可选)
    let desc: String?
    let playCount: Int?
    let updateTime: String?
    
    // 缓存属性
    private(set) var coverImage: UIImage?
    private(set) var cachedMediaArtwork: MPMediaItemArtwork?

    init(audioUrl: URL?, artwork: Artwork? = nil, title: String? = nil, album: String? = nil, artist: String? = nil, duration: TimeInterval? = nil, placeholder: UIImage? = nil, desc: String? = nil, playCount: Int? = nil, updateTime: String? = nil) {
        self.title = title
        self.artist = artist
        self.audioUrl = audioUrl
        self.artwork = artwork
        self.duration = duration
        self.desc = desc
        self.playCount = playCount
        self.updateTime = updateTime
        
        // self.preloadArtwork(placeholder: nil, completion: { _, _ in })
    }
}

extension AudioTrack {
    
    /// 解析音频文件元数据, 并缓存结果, 没解析到, 使用默认指定
    func preloadArtwork(placeholder: UIImage? = nil, completion: @escaping (MP3MetaData?, UIImage?) -> Void) {
        guard let audioUrl = audioUrl else { return }
        
        extractMP3Metadata(from: audioUrl) { [weak self] metaData in
            guard let self = self else { return }
            self.title = metaData?.title
            self.artist = metaData?.artist
            self.duration = metaData?.duration
            self.metaData = metaData

            // 使用音频文件中提取到的封面图片
            if let artworkImage = metaData?.artwork {
                self.coverImage = artworkImage
                self.cachedMediaArtwork = MPMediaItemArtwork(boundsSize: artworkImage.size, requestHandler: { _ in artworkImage })
                
                DispatchQueue.main.async {
                    completion(metaData, artworkImage)
                }
            } else {
                // 如果没有封面，尝试使用传入的封面图
                self.defalutArtwork(placeholder: nil) { image, mediaArtwork in
                    self.coverImage = image
                    self.cachedMediaArtwork = mediaArtwork
                    
                    DispatchQueue.main.async {
                        completion(metaData, image)
                    }
                }
            }
        }
    }
    
    /// 从音频文件中提取元数据
    private func extractMP3Metadata(from url: URL?, completion: @escaping (MP3MetaData?) -> Void) {
        guard let url = url else { return }
        
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            var title: String?
            var artist: String?
            var album: String?
            var duration: TimeInterval?
            var artwork: UIImage? // 封面图片, 不是所有 mp3 都有封面
            
            // 获取时长
            duration = CMTimeGetSeconds(asset.duration)
            
            // 提取 ID3 元数据（包括封面）
            for format in asset.metadata where format.keySpace == AVMetadataKeySpace.id3 {
                if let key = format.key as? String {
                    switch key {
                    case "TIT2": // 标题
                        title = format.stringValue
                    case "TPE1": // 艺术家
                        artist = format.stringValue
                    case "TALB": // 专辑
                        album = format.stringValue
                    case "APIC": // 封面图片
                        if let data = format.dataValue {
                            artwork = UIImage(data: data)
                        }
                    default:
                        break
                    }
                }
            }
            
            // 如果从音频文件中提取到封面图，直接设置封面图
            if let artworkImage = artwork {
                self.coverImage = artworkImage
                self.cachedMediaArtwork = MPMediaItemArtwork(boundsSize: artworkImage.size, requestHandler: { _ in artworkImage })
            }
            
            let metaData = MP3MetaData(title: title, artist: artist, album: album, duration: duration, artwork: artwork)
            self.metaData = metaData
            
            DispatchQueue.main.async {
                completion(metaData)
            }
        }
    }
    
//    /// 异步预加载封面图片和 MPMediaItemArtwork
//    private func preloadArtwork(placeholder: UIImage? = nil) {
//        fetchArtwork(placeholder: placeholder) { [weak self] image, mediaArtwork in
//            self?.coverImage = image
//            self?.cachedMediaArtwork = mediaArtwork
//        }
//    }
    
    /// 异步获取封面图片和 MPMediaItemArtwork，并缓存结果
    /// - Parameters:
    ///   - placeholder: 占位图片
    ///   - completion: 回调，返回封面图片和 MPMediaItemArtwork
    private func defalutArtwork(placeholder: UIImage?, completion: @escaping (UIImage?, MPMediaItemArtwork?) -> Void) {
        // 如果已经缓存，直接返回
        if let cachedImage = coverImage, let cachedMediaArtwork = cachedMediaArtwork {
            completion(cachedImage, cachedMediaArtwork)
            return
        }
        
        // 如果从音频文件中没有解析到封面图片，使用传入的 artwork
        if let artworkImage = artwork {
            switch artworkImage {
            case .local(let image):
                let mediaArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                completion(image, mediaArtwork)
                
            case .remote(let url):
                // 网络封面图片，使用 URL 加载远程封面
                KingfisherManager.shared.retrieveImage(with: url) { result in
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
