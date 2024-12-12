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

    // 音频资源 URL
    var audioUrl: URL?
    
    // MP3 元数据 (真实数据)
    var metaData: MP3MetaData?
    
    // 基本信息 (可由外部定义) (mp3 可解析参数字段)
    var title: String?        // 曲目标题
    var album: String?        // 专辑名称
    var artist: String?       // 艺术家名称
    var duration: TimeInterval? // 音频时长（可选）
    var artworkUrl: String?     // 封面图片

    // 其他信息 (可选)
    let desc: String?
    let playCount: Int?
    let updateTime: String?
    
    // 播放状态
    var isPlaying: Bool = false
    
    // 缓存属性
    private(set) var coverImage: UIImage?
    private(set) var cachedMediaArtwork: MPMediaItemArtwork?

    init(audioUrl: URL?, artworkUrl: String? = nil, title: String? = nil, album: String? = nil, artist: String? = nil, duration: TimeInterval? = nil, placeholder: UIImage? = nil, desc: String? = nil, playCount: Int? = nil, updateTime: String? = nil) {
        self.title = title
        self.artist = artist
        self.audioUrl = audioUrl
        self.artworkUrl = artworkUrl
        self.duration = duration
        self.desc = desc
        self.playCount = playCount
        self.updateTime = updateTime
        
//        self.preloadArtwork(placeholder: nil, completion: { _, _ in })
    }
}

// MARK: - 音频元数据解析
extension AudioTrack {
    
    /// 解析音频文件元数据, 并缓存结果, 没解析到, 使用默认指定
    /// - Parameters:
    ///  - loadMetaData: 是否加载元数据
    func preloadArtwork(loadMetaData: Bool = false, placeholder: UIImage? = nil, completion: @escaping (MP3MetaData?, UIImage?) -> Void) {
        guard let audioUrl = audioUrl else { return }
        
        validateAudioUrl(audioUrl) {[weak self] isValid in
            if let self = self, !isValid {
                print("音频URL无效")
                self.updateArtwork(with: metaData) { _, image in
                    DispatchQueue.main.async {
                        completion(nil, image)
                    }
                }
                return
            }
            
            if let self = self, !loadMetaData {
                // 同步外部数据到元数据 (仅时长由解析获取)
                let asset = AVAsset(url: audioUrl)
                let duration = CMTimeGetSeconds(asset.duration)
                self.metaData = MP3MetaData(title: title, artist: artist, album: album, duration: duration, artwork: nil)
                
                self.updateArtwork(with: metaData) { metaData, image in
                    DispatchQueue.main.async {
                        completion(metaData, image)
                    }
                }
                return
            }
            
            // 加载音频元数据
            self?.loadAudioMetadata(from: audioUrl) { [weak self] metaData, status in
                guard let self = self, let metaData = metaData, status == .loaded else {
                    DispatchQueue.main.async {
                        completion(nil, nil)
                    }
                    return
                }
                
                // 缓存元数据
                self.metaData = metaData
                
                self.updateArtwork(with: metaData) { metaData, image in
                    DispatchQueue.main.async {
                        completion(metaData, image)
                    }
                }
            }
        }
    }
    
    /// 封面资源更新
    func updateArtwork(with metaData: MP3MetaData?, completion: @escaping (MP3MetaData?, UIImage?) -> Void) {
        // 使用音频文件中提取到的封面图片
        if let artworkImage = metaData?.artwork {
            self.coverImage = artworkImage
            self.cachedMediaArtwork = MPMediaItemArtwork(boundsSize: artworkImage.size, requestHandler: { _ in artworkImage })
            completion(metaData, artworkImage)
        } else {
            // 如果没有封面，尝试使用传入的封面图
            self.defalutArtwork(placeholder: nil) {[weak self] image, mediaArtwork in
                self?.coverImage = image
                self?.cachedMediaArtwork = mediaArtwork
                completion(metaData, image)
            }
        }
    }
    
    /// 从音频文件中加载元数据
    func loadAudioMetadata(from url: URL, completion: @escaping (MP3MetaData?, AVKeyValueStatus) -> Void) {
        let asset = AVAsset(url: url)
        validateAudioAsset(asset) { isValid, status  in
            if !isValid {
                completion(nil, .failed)
                return
            }
            
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
            completion(MP3MetaData(title: title, artist: artist, album: album, duration: duration, artwork: artworkImage), status)
        }
    }
    
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
        if let artworkUrl = URL(string: artworkUrl?.urlEncoded ?? "") {
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

// MARK: - 校验音频是否有效
extension AudioTrack {

    /// 音频路径是否有效
    func validateAudioUrl(_ url: URL, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // 仅检查资源头部
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }
    
    /// 音频 资源有效性校验
    func validateAudioAsset(_ asset: AVAsset, completion: @escaping (Bool, AVKeyValueStatus) -> Void) {
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            // 如果资源加载失败，返回 nil
            var error: NSError?
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            if status == .loaded {
                completion(true, status)
            } else {
                self.showInvalidReason(status)
                completion(false, status)
            }
        }
    }
    
    /// 音频资源无效原因
    func showInvalidReason(_ status: AVKeyValueStatus) {
        switch status {
        case .failed:
            print("音频文件不可用")
        case .cancelled:
            print("音频文件加载被取消")
        case .unknown:
            print("音频文件状态未知")
        case .loading:
            print("音频文件正在加载")
        default:
            print("音频状态未知")
        }
    }
}
