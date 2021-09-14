//
//  VideoCropView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/14.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AVFoundation
//MARK: - global var and methods

protocol VideoPlayerViewDelegate: NSObjectProtocol {
    func playerView(_ playerView: VideoCropView, didPlayAt time: CMTime)
    func playerView(_ playerView: VideoCropView, didPauseAt time: CMTime)
    func playerView(_ playerViewReadyForDisplay: VideoCropView)
}

//MARK: 尺寸剪辑预览视图
class VideoCropView: UIView {
    
    weak var delegate: VideoPlayerViewDelegate?
    var playStartTime: CMTime?
    var playEndTime: CMTime?
    var isPlaying: Bool = false
    var shouldPlay = true

    let scrollView = UIScrollView()
    var playerLayer: AVPlayerLayer?
    //var player: AVPlayer?
    lazy var player: AVPlayer = {
        let player = AVPlayer.init()
        return player
    }()
    
    var videoSize = CGSize.zero
    var cropSize = CGSize.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustLayout()
    }
    
    func setupUI() {
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
    }
    
    func adjustLayout() {
        if videoSize.equalTo(CGSize.zero) || cropSize.equalTo(CGSize.zero) {
            return
        }
        let length = bounds.width
        let videoRatio = videoSize.width/videoSize.height
        let cropRatio = cropSize.width/cropSize.height
        
        // calculate scrollSize
        var scrollSize = CGSize.zero
        var scrollOrigin = CGPoint.zero
        if cropRatio > 1 {
            scrollSize = CGSize(width: length, height: length/cropRatio)
            scrollOrigin = CGPoint(x: CGFloat(0), y: (1-1/cropRatio)*0.5*length)
        }else {
            scrollSize = CGSize(width: length*cropRatio, height: length)
            scrollOrigin = CGPoint(x: (1-cropRatio)*0.5*length, y: CGFloat(0))
        }
        // calculate contentSize
        var contentSize = CGSize.zero
        if videoRatio > cropRatio {
            contentSize = CGSize(width: scrollSize.height*videoRatio, height: scrollSize.height)
        }else {
            contentSize = CGSize(width: scrollSize.width, height: scrollSize.width/videoRatio)
        }
        scrollView.frame = CGRect(origin: scrollOrigin, size: scrollSize)
        scrollView.contentSize = contentSize
        //scrollView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        playerLayer?.frame = CGRect(origin: CGPoint.zero, size: contentSize)
    }
    
    // MARK: Public
    func load(asset: AVAsset, cropSize: CGSize) {
        videoSize = transformedSize(asset)
        self.cropSize = cropSize
        
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        playerLayer = AVPlayerLayer(player: player)
        scrollView.layer.addSublayer(playerLayer!)
        adjustLayout()
    }
    
    func pause() {
        if isPlaying {
            player.pause()
            isPlaying = false
            delegate?.playerView(self, didPauseAt: player.currentTime())
        }
    }
    func play() {
        if !isPlaying {
            player.play()
            isPlaying = true
            delegate?.playerView(self, didPlayAt: player.currentTime())
        }
    }
    
    func seek(to time: CMTime, comletion: ((Bool) -> Void)? = nil) {
        player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { (isFinished) in
            comletion?(isFinished)
        }
    }
    
    func resetPlay() {
        isPlaying = false
        if let startTime = playStartTime {
            seek(to: startTime) { (isFinished) in
                if isFinished {
                    self.play()
                }
            }
        }else {
            seek(to: kCMTimeZero) { (isFinished) in
                if isFinished {
                    self.play()
                }
            }
        }
    }
    
    func cropRect() -> CGRect {
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let scrollViewSize = scrollView.frame.size
        let origin = CGPoint(x: contentOffset.x/contentSize.width, y: contentOffset.y/contentSize.height)
        let size = CGSize(width: scrollViewSize.width/contentSize.width, height: scrollViewSize.height/contentSize.height)
        return CGRect(origin: origin, size: size)
    }
    
    func transformedSize(_ asset: AVAsset) -> CGSize {
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first
        if let track = videoTrack {
            let naturalSize = track.naturalSize
            var sourceSize = naturalSize
            let trackTrans = track.preferredTransform
            if (trackTrans.b == 1 && trackTrans.c == -1)||(trackTrans.b == -1 && trackTrans.c == 1) {
                sourceSize = CGSize(width: naturalSize.height, height: naturalSize.width)
            }
            return sourceSize
        }
        return CGSize(width: 0, height: 0)
    }
}
//MARK: - private mothods
extension VideoCropView {
    
}

//MARK: - call backs
extension VideoCropView {
    
}

//MARK: - delegate or data source
extension VideoCropView {
    
}

//MARK: - other classes
