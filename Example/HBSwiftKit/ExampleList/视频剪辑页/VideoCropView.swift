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

protocol VideoCropViewDelegate: class {
    func exportFailed(error: Error?)
    func exportSuccess(outputUrl: URL)
    func exportProgress(progress: CGFloat)
}


//MARK: 尺寸剪辑预览视图
class VideoCropView: UIView {
    
    weak var playDelegate: VideoPlayerViewDelegate?
    
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
    
    public var outputSize: CGSize?
    public var rect: CGRect?
    public var timeRange: CMTimeRange?
    public var bitRate: Int64?
    public var profile: String?
    public var fileType: String?
    public var outputUrl: URL?

    
    // public
    public weak var cropDelegate: VideoCropViewDelegate?
    public var exportFailedHandler: ((_ error: Error?)->Void)?
    public var exportSuccessHandler: ((_ outputUrl: URL)->Void)?
    public var exportProgressHandler: ((_ progress: CGFloat)->Void)?

    // private
    var writer: AVAssetWriter?
    var writerVideoInput: AVAssetWriterInput?
    var writerAudioInput: AVAssetWriterInput?
    var reader: AVAssetReader?
    var readerVideoOutput: AVAssetReaderVideoCompositionOutput?
    var readerAudioOutput: AVAssetReaderAudioMixOutput?
    var videoExportQueue: DispatchQueue?
    var audioExportQueue: DispatchQueue?
    
    var videoExportFinished = false
    var audioExprotFinished = false
    var audioTrackExists = false

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
//        scrollView.delegate = self
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 3.0
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
        self.outputSize = cropSize
        
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        playerLayer = AVPlayerLayer(player: player)
        scrollView.layer.addSublayer(playerLayer!)
        adjustLayout()
    }
    
    func pause() {
        if isPlaying {
            player.pause()
            isPlaying = false
            playDelegate?.playerView(self, didPauseAt: player.currentTime())
        }
    }
    func play() {
        if !isPlaying {
            player.play()
            isPlaying = true
            playDelegate?.playerView(self, didPlayAt: player.currentTime())
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
    
    // MARK: public
    
    public func export(_ asset: AVAsset, _ rect: CGRect, _ timeRange: CMTimeRange, _ outputSize: CGSize, _ outputUrl: URL) {
        self.rect = rect
        self.outputSize = outputSize
        self.timeRange = timeRange
        export(asset,outputUrl)
    }
    
    func export(_ asset: AVAsset, _ outputUrl: URL) {
        self.outputUrl = outputUrl
        setupExportSession(asset, outputUrl)
        startExportSession()
    }
    
    func setupExportSession(_ asset: AVAsset,_ outputUrl: URL) {
        // optional settings
        configureOptionalSettings(asset: asset)
        
        // composition
        let composition = createComposition(asset: asset)
        
        // reader
        do {
            reader = try AVAssetReader(asset: composition)
        } catch {
            failedHandler(error: nil)
            return
        }
        readerVideoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: composition.tracks(withMediaType: AVMediaType.video), videoSettings: [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange])
        readerVideoOutput?.alwaysCopiesSampleData = false
        readerVideoOutput?.videoComposition = createVideoComposition(composition: composition)
        reader?.add(readerVideoOutput!)

        // writer
        do {
            writer = try AVAssetWriter(outputURL: outputUrl, fileType: AVFileType(rawValue: fileType ?? AVFileType.mp4.rawValue))
        } catch {
            failedHandler(error: nil)
            return
        }
        writerVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings())
        writer?.add(writerVideoInput!)

        // queue
        videoExportQueue = DispatchQueue(label: "com.worthy.tailor.video")
        
        // audio
        if audioTrackExists {
            readerAudioOutput = AVAssetReaderAudioMixOutput(audioTracks: composition.tracks(withMediaType: AVMediaType.audio), audioSettings: [AVFormatIDKey:kAudioFormatLinearPCM])
            readerAudioOutput?.alwaysCopiesSampleData = false
            reader?.add(readerAudioOutput!)
            writerAudioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings())
            writer?.add(writerAudioInput!)
            audioExportQueue = DispatchQueue(label: "com.worthy.tailor.audio")
        }else {
            audioExprotFinished = true
        }
    }
    
    func startExportSession() {
        reader?.startReading()
        writer?.startWriting()
        writer?.startSession(atSourceTime: kCMTimeZero)
        // video
        writerVideoInput?.requestMediaDataWhenReady(on: videoExportQueue!, using: {
            while self.writerVideoInput!.isReadyForMoreMediaData {
                if let sampleBuffer = self.readerVideoOutput?.copyNextSampleBuffer() {
                    self.writerVideoInput?.append(sampleBuffer)
                    let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    let progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(self.timeRange!.duration)
                    self.progressHandler(progress: CGFloat(progress))
                }else {
                    if !self.videoExportFinished {
                        self.videoExportFinished = true
                        self.writerVideoInput?.markAsFinished()
                        self.checkExportSession()
                        break;
                    }
                }
                
            }
        })
        
        // audio
        if audioTrackExists {
            writerAudioInput?.requestMediaDataWhenReady(on: audioExportQueue!, using: {
                while self.writerAudioInput!.isReadyForMoreMediaData {
                    if let sampleBuffer = self.readerAudioOutput?.copyNextSampleBuffer() {
                        self.writerAudioInput?.append(sampleBuffer)
                    }else {
                        if !self.audioExprotFinished {
                            self.audioExprotFinished = true
                            self.writerAudioInput?.markAsFinished()
                            self.checkExportSession()
                            break;
                        }
                    }
                    
                }
            })
        }
    }
    
    func checkExportSession() {
        if audioExprotFinished && videoExportFinished {
            writer?.finishWriting {
                if let error = self.writer?.error {
                    self.failedHandler(error: error)
                }else {
                    self.successHandler()
                }
            }
        }
    }
    
    func configureOptionalSettings(asset: AVAsset) {
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
        let inputSize = transformedSize(videoTrack!)
        var bitRateRatio: Float = 1.0
        if outputSize == nil {
            outputSize = inputSize
        }else {
            bitRateRatio = Float(outputSize!.width*outputSize!.height/(inputSize.width*inputSize.height))
        }
        if bitRate == nil {
            bitRate = Int64(audioTrack!.estimatedDataRate + videoTrack!.estimatedDataRate * bitRateRatio)
        }
        if timeRange == nil {
            timeRange = videoTrack?.timeRange
        }
        if rect == nil {
            rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
    
    func createComposition(asset: AVAsset) -> AVMutableComposition {
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let sourceVideoTrack = asset.tracks(withMediaType: AVMediaType.video).first
        let sourceAudioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
        
        // add tracks
        if let track = sourceVideoTrack {
            do {
                try compositionVideoTrack?.insertTimeRange(timeRange!, of: track, at: kCMTimeZero)
                compositionVideoTrack?.preferredTransform = track.preferredTransform
            } catch {
            }
        }
        if let track = sourceAudioTrack {
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange!, of: track, at: kCMTimeZero)
            } catch {
                audioTrackExists = false
            }
            audioTrackExists = true
        }else {
            audioTrackExists = false
        }
        return composition
    }
    
    func createVideoComposition(composition: AVMutableComposition) -> AVMutableVideoComposition {
        let videoTrack = composition.tracks(withMediaType: AVMediaType.video).first!
        // transform
        var offsetX, offsetY, rotate: CGFloat
        
        let sourceSize = transformedSize(videoTrack)
        let trackTrans = videoTrack.preferredTransform
        let middleSize = CGSize(width: sourceSize.width * rect!.width, height: sourceSize.height*rect!.height)
        let scale = outputSize!.width / middleSize.width
        
        if trackTrans.b == 1 && trackTrans.c == -1 {            //90 angle
            rotate = CGFloat(Double.pi/2)
            offsetX = (1 - rect!.origin.x) * sourceSize.width;
            offsetY = -rect!.origin.y * sourceSize.height;
        }else if (trackTrans.a == -1 && trackTrans.d == -1) {   //180 angle
            rotate = CGFloat(Double.pi)
            offsetX = (1 - rect!.origin.x) * sourceSize.width;
            offsetY = (1 - rect!.origin.y) * sourceSize.height;
        }else if (trackTrans.b == -1 && trackTrans.c == 1) {    //270 angle
            rotate = CGFloat(Double.pi/2 * 3)
            offsetX = -rect!.origin.x * sourceSize.width
            offsetY = (1-rect!.origin.y) * sourceSize.height
        }else{
            rotate = 0;
            offsetX = -rect!.origin.x * sourceSize.width
            offsetY = -rect!.origin.y * sourceSize.height
        }
        var transform = CGAffineTransform(rotationAngle: rotate)
        transform = transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        transform = transform.concatenating(CGAffineTransform(translationX: offsetX*scale, y: offsetY*scale))
        
        // instruction
        let instruction = AVMutableVideoCompositionInstruction()
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.timeRange = videoTrack.timeRange
        instruction.layerInstructions = [layerInstruction]
        layerInstruction.setTransform(transform, at: kCMTimeZero)
        
        // videoComposition
        let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        videoComposition.renderSize = outputSize!
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(1, Int32(videoTrack.nominalFrameRate))
        
        return videoComposition
    }

    // MARK: tool
    func transformedSize(_ videoTrack: AVAssetTrack) -> CGSize{
        let naturalSize = videoTrack.naturalSize
        var sourceSize = naturalSize
        let trackTrans = videoTrack.preferredTransform
        if (trackTrans.b == 1 && trackTrans.c == -1)||(trackTrans.b == -1 && trackTrans.c == 1) {
            sourceSize = CGSize(width: naturalSize.height, height: naturalSize.width)
        }
        return sourceSize
    }
    
    // MARK: handler
    
    func failedHandler(error: Error?) {
        DispatchQueue.main.async {
            self.cropDelegate?.exportFailed(error: error)
            self.exportFailedHandler?(error)
        }
    }
    
    func successHandler() {
        DispatchQueue.main.async {
            self.cropDelegate?.exportProgress(progress: 1.0)
            self.cropDelegate?.exportSuccess(outputUrl: self.outputUrl!)
            self.exportProgressHandler?(1.0)
            self.exportSuccessHandler?(self.outputUrl!)
        }
    }
    
    func progressHandler(progress: CGFloat) {
        DispatchQueue.main.async {
            self.cropDelegate?.exportProgress(progress: progress)
            self.exportProgressHandler?(progress)
        }
    }
    
    // MARK: configuration
    
    func videoOutputSettings() -> [String: Any] {
        let width = outputSize!.width
        let height = outputSize!.height
        return [AVVideoHeightKey: height,
                AVVideoWidthKey: width,
                AVVideoCodecKey: AVVideoCodecH264,
                AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                AVVideoCompressionPropertiesKey:[AVVideoAverageBitRateKey:bitRate!,
                                                 AVVideoProfileLevelKey: profile ?? AVVideoProfileLevelH264MainAutoLevel,
                                                 AVVideoCleanApertureKey:[
                                                    AVVideoCleanApertureWidthKey:width,
                                                    AVVideoCleanApertureHeightKey:height,
                                                    AVVideoCleanApertureHorizontalOffsetKey:10,
                                                    AVVideoCleanApertureVerticalOffsetKey:10],
                                                 AVVideoPixelAspectRatioKey:[
                                                    AVVideoPixelAspectRatioHorizontalSpacingKey:1,
                                                    AVVideoPixelAspectRatioVerticalSpacingKey:1]
                ]
        ]
    }
    
    func audioOutputSettings() -> [String: Any] {
        var audioChannelLayout = AudioChannelLayout()
        memset(&audioChannelLayout, 0, MemoryLayout<AudioChannelLayout>.size);
        audioChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Mono

        let audioChannelLayoutValue = NSData(bytes: &audioChannelLayout,
               length: MemoryLayout<AudioChannelLayout>.size)
        
        let sampleRate = AVAudioSession.sharedInstance().sampleRate
        return [AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey:sampleRate,
                AVChannelLayoutKey:audioChannelLayoutValue,
                AVNumberOfChannelsKey: 1
        ]
    }
}

//MARK: - call backs
extension VideoCropView {
    
}

//MARK: - delegate or data source
extension VideoCropView: UIScrollViewDelegate {
    
//    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//         //return scrollView.subviews.filter( { $0.isKind(of: UIImageView.self) } ).first
//        return scrollView.subviews.first
//     }
}

//MARK: - other classes
