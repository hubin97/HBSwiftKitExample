//
//  VideoTimeView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/14.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AVKit

// MARK: - global var and methods
protocol VideoTimeViewDelegate: NSObjectProtocol {
    func timeView(_ timeView: VideoTimeView, didChangedValidRectAt time: CMTime)
    func timeView(_ timeView: VideoTimeView, endChangedValidRectAt time: CMTime)
    func timeView(_ timeView: VideoTimeView, progressLineDragBeganAt time: CMTime)
    func timeView(_ timeView: VideoTimeView, progressLineDragChangedAt time: CMTime)
    func timeView(_ timeView: VideoTimeView, progressLineDragEndAt time: CMTime)
    func timeView(_ timeView: VideoTimeView, didScrollAt time: CMTime)
    func timeView(_ timeView: VideoTimeView, endScrollAt time: CMTime)
}

// MARK: 长度剪辑预览视图
class VideoTimeView: UIView {

    weak var delegate: VideoTimeViewDelegate?

    var avAsset: AVAsset!

    var videoFrameCount = 0
    /// 一个item代表多少秒
    var interval: CGFloat = -1
    var itemWidth: CGFloat = 0
    var itemHeight: CGFloat = 40 // 60
    let imageWidth: CGFloat = 8
    var validRectX: CGFloat = 30
    var contentWidth: CGFloat = 0
    var lineDidAnimate = false

    var videoFrameMap: [Int: CGImage] = [:]
    var imageGenerator: AVAssetImageGenerator?

    lazy var startTimeLb: UILabel = {
        let startTimeLb = UILabel.init()
        startTimeLb.font = UIFont.systemFont(ofSize: 12)
        startTimeLb.textColor = .white
        return startTimeLb
    }()
    lazy var endTimeLb: UILabel = {
        let endTimeLb = UILabel.init()
        endTimeLb.textAlignment = .right
        endTimeLb.font = UIFont.systemFont(ofSize: 12)
        endTimeLb.textColor = .white
        return endTimeLb
    }()
    lazy var totalTimeLb: UILabel = {
        let totalTimeLb = UILabel.init()
        totalTimeLb.textAlignment = .center
        totalTimeLb.font = UIFont.systemFont(ofSize: 12)
        totalTimeLb.textColor = .white
        return totalTimeLb
    }()

    lazy var progressLineView: UIView = {
        let lineView = UIView.init()
        lineView.backgroundColor = .white
        lineView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        lineView.layer.shadowOpacity = 0.5
        lineView.isHidden = true
        return lineView
    }()

    lazy var frameMaskView: VideoFrameView = {
        let frameMaskView = VideoFrameView.init()
        frameMaskView.delegate = self
        return frameMaskView
    }()

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        return flowLayout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(VideoEditorCropViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(VideoEditorCropViewCell.self))
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        addSubview(frameMaskView)
        addSubview(progressLineView)
        addSubview(startTimeLb)
        addSubview(endTimeLb)
        addSubview(totalTimeLb)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 20, width: width, height: itemHeight)

        startTimeLb.frame = CGRect(x: validRectX, y: 0, width: 100, height: 20)
        endTimeLb.frame = CGRect(x: width - validRectX - 100, y: 0, width: 100, height: 20)
        totalTimeLb.frame = CGRect(x: 0, y: 0, width: 100, height: 20)
        totalTimeLb.centerX = width * 0.5

        frameMaskView.frame = collectionView.frame
        if frameMaskView.validRect.equalTo(.zero) {
            resetValidRect()
        }
    }

    deinit {
        imageGenerator?.cancelAllCGImageGeneration()
        videoFrameMap.removeAll()
    }
}

// MARK: function
extension VideoTimeView {

    func startLineAnimation(at time: CMTime) {
        if lineDidAnimate {
            return
        }
        lineDidAnimate = true
//        let duration = getEndDuration() - CGFloat(time.seconds)
        let duration = getEndDuration(real: true) - CGFloat(time.seconds)
        let mixX = frameMaskView.leftControl.frame.maxX
        var x: CGFloat
        if time.seconds == getStartTime(real: true).seconds {
            x = mixX
        } else {
            x = CGFloat(time.seconds / avAsset.duration.seconds) * contentWidth - collectionView.contentOffset.x
        }
        setLineAnimation(x: x, duration: TimeInterval(duration))
    }
    func setLineAnimation(x: CGFloat, duration: TimeInterval) {
        progressLineView.layer.removeAllAnimations()
        let maxX = frameMaskView.validRect.maxX - 2 - imageWidth * 0.5
        progressLineView.frame = CGRect(x: x, y: collectionView.frame.minY, width: 2, height: collectionView.height)
        progressLineView.isHidden = false
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear]) {
            self.progressLineView.frame.origin.x = maxX
        } completion: { (isFinished) in
            if self.lineDidAnimate && isFinished {
                let mixX = self.frameMaskView.leftControl.frame.maxX
                let duration = self.getEndDuration(real: true) - self.getStartDuration(real: true)
                self.setLineAnimation(x: mixX, duration: TimeInterval(duration))
            }
        }
    }
    func stopLineAnimation() {
        lineDidAnimate = false
        progressLineView.isHidden = true
        progressLineView.layer.removeAllAnimations()
    }

    // MARK: 
    func getMiddleDuration(real: Bool = false) -> CGFloat {
        let validWidth = frameMaskView.validRect.width - imageWidth
        let second = validWidth / contentWidth * videoDuration(real: real)
        return second
    }
    func getStartDuration(real: Bool = false) -> CGFloat {
        var offsetX = collectionView.contentOffset.x + collectionView.contentInset.left
        let validX = frameMaskView.validRect.minX + imageWidth * 0.5 - collectionView.contentInset.left
        let maxOfssetX = contentWidth - (collectionView.width - collectionView.contentInset.left * 2.0)
        if offsetX > maxOfssetX {
            offsetX = maxOfssetX
        }
        var second = (offsetX + validX) / contentWidth * videoDuration(real: real)
        if second < 0 {
            second = 0
        } else if second > videoDuration(real: real) {
            second = videoDuration(real: real)
        }
        return second
    }
    func getStartTime(real: Bool = false) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(getStartDuration(real: real)), avAsset.duration.timescale)
    }
    func getEndDuration(real: Bool = false) -> CGFloat {
        let videoSecond = videoDuration(real: real)
        let validWidth = frameMaskView.validRect.width - imageWidth * 0.5
        var second = getStartDuration(real: real) + validWidth / contentWidth * videoSecond
        if second > videoSecond {
            second = videoSecond
        }
        return second
    }
    func getEndTime(real: Bool = false) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(getEndDuration(real: real)), avAsset.duration.timescale)
    }
    func stopScroll() {
        let inset = collectionView.contentInset
        var offset = collectionView.contentOffset
        let maxOffsetX = contentWidth - (collectionView.width - inset.left)
        if offset.x < -inset.left {
            offset.x = -inset.left
        } else if offset.x > maxOffsetX {
            offset.x = maxOffsetX
        }
        collectionView.setContentOffset(offset, animated: false)
    }
    func videoDuration(real: Bool = false) -> CGFloat {
        if real {
            return CGFloat(avAsset.duration.seconds)
        }
        return CGFloat(round(avAsset.duration.seconds))
    }

    func updateTimeLabels() {
        if avAsset == nil {
            return
        }
        let startDuration = getStartDuration(real: true)
        let endDuration = getEndDuration()
        let totalDuration = round(endDuration - startDuration)
        endTimeLb.text = transformVideoDurationToString(duration: TimeInterval(round(endDuration)))
        totalTimeLb.text = transformVideoDurationToString(duration: TimeInterval(totalDuration))
        startTimeLb.text = transformVideoDurationToString(duration: TimeInterval(round(endDuration) - totalDuration))
    }

    /// 转换视频时长为 mm:ss 格式的字符串
    func transformVideoDurationToString(duration: TimeInterval) -> String {
        let time = Int(round(Double(duration)))
        if time < 10 {
            return String.init(format: "00:0%d", arguments: [time])
        } else if time < 60 {
            return String.init(format: "00:%d", arguments: [time])
        } else {
            let min = Int(time / 60)
            let sec = time - (min * 60)
            if sec < 10 {
                return String.init(format: "%d:0%d", arguments: [min, sec])
            } else {
                return String.init(format: "%d:%d", arguments: [min, sec])
            }
        }
    }
}

// MARK: - private mothods
extension VideoTimeView {

    // swiftlint:disable function_body_length
    func configData(avAsset: AVAsset) {
        self.avAsset = avAsset
        imageGenerator?.cancelAllCGImageGeneration()
        videoFrameMap.removeAll()

        var videoSecond: CGFloat = CGFloat(avAsset.duration.seconds)
        let videoSize = getVideoThumbnailImage(avAsset: avAsset, atTime: 0.1)?.size ?? .zero
        collectionView.contentInset = UIEdgeInsets(top: 2, left: validRectX + imageWidth, bottom: 2, right: validRectX + imageWidth)
        let cellHeight = itemHeight - 4
        itemWidth = cellHeight / 16 * 9
        var imgWidth = videoSize.width
        let imgHeight = videoSize.height
        imgWidth = cellHeight / imgHeight * imgWidth
        if imgWidth > itemWidth {
            itemWidth = cellHeight / imgHeight * videoSize.width
            if itemWidth > imgHeight / 9 * 16 {
                itemWidth = imgHeight / 9 * 16
            }
        }
        resetValidRect()

        if videoSecond <= 0 {
            videoSecond = 1
        }
        let maxWidth = width - validRectX * 2 - imageWidth * 2
        var singleItemSecond: CGFloat
        var videoMaximumCropDuration: CGFloat = 10
        if videoMaximumCropDuration < 1 {
            videoMaximumCropDuration = 1
        }
        if videoSecond <= 10 {
            let itemCount = maxWidth / itemWidth
            singleItemSecond = videoSecond / itemCount
            contentWidth = maxWidth
            videoFrameCount = Int(ceilf(Float(itemCount)))
            interval = singleItemSecond
        } else {
            let singleSecondWidth = maxWidth / videoMaximumCropDuration
            singleItemSecond = itemWidth / singleSecondWidth
            contentWidth = singleSecondWidth * videoSecond
            videoFrameCount = Int(ceilf(Float(contentWidth / itemWidth)))
            interval = singleItemSecond
        }
        if round(videoSecond) <= 0 {
            frameMaskView.minWidth = contentWidth
        } else {
            let scale = 1 / videoSecond
            frameMaskView.minWidth = contentWidth * scale
        }
        collectionView.reloadData()
        getVideoFrame(avAsset: avAsset)
    }

    func getVideoFrame(avAsset: AVAsset) {
        imageGenerator = AVAssetImageGenerator.init(asset: avAsset)
        imageGenerator?.maximumSize = CGSize(width: itemWidth * 2, height: itemHeight * 2)
        imageGenerator?.appliesPreferredTrackTransform = true
        imageGenerator?.requestedTimeToleranceAfter = kCMTimeZero
        imageGenerator?.requestedTimeToleranceBefore = kCMTimeZero

        var times: [NSValue] = []
        for index in 0..<videoFrameCount {
            let time = getVideoCurrentTime(avAsset: avAsset, for: index)
            times.append(NSValue.init(time: time))
        }
        var index: Int = 0
        var hasError = false
        var errorIndex: [Int] = []
        imageGenerator?.generateCGImagesAsynchronously(forTimes: times) {[weak self] (_, cgImage, _, result, _) in
            if result != .cancelled {
                if let cgImage = cgImage {
                    self?.videoFrameMap[index] = cgImage
                    if hasError {
                        for index in errorIndex {
                            self?.setCurrentCell(image: UIImage.init(cgImage: cgImage), index: index)
                        }
                        errorIndex.removeAll()
                        hasError = false
                    }
                    self?.setCurrentCell(image: UIImage.init(cgImage: cgImage), index: index)
                } else {
                    if let cgImage = self?.videoFrameMap[index - 1] {
                        self?.setCurrentCell(image: UIImage.init(cgImage: cgImage), index: index)
                    } else {
                        errorIndex.append(index)
                        hasError = true
                    }
                }
                index += 1
            }
        }
    }

    func getVideoCurrentTime(avAsset: AVAsset, for index: Int) -> CMTime {
        var second: CGFloat
        let maxIndex = videoFrameCount - 1
        if index == 0 {
            second = 0.1
        } else if index >= maxIndex {
            if avAsset.duration.seconds < 1 {
                second = CGFloat(avAsset.duration.seconds - 0.1)
            } else {
                second = CGFloat(avAsset.duration.seconds - 0.5)
            }
        } else {
            if avAsset.duration.seconds < 1 {
                second = 0
            } else {
                second = CGFloat(index) * interval + interval * 0.5
            }
        }
        let time = CMTimeMakeWithSeconds(Float64(second), avAsset.duration.timescale)
        return time
    }

    /// 根据视频地址获取视频封面
    func getVideoThumbnailImage(videoURL: URL?, atTime: TimeInterval) -> UIImage? {
        guard let videoURL = videoURL else { return nil }
        let urlAsset = AVURLAsset.init(url: videoURL)
        return getVideoThumbnailImage(avAsset: urlAsset as AVAsset, atTime: atTime)
    }

    /// 根据avAsset获取视频封面
    func getVideoThumbnailImage(avAsset: AVAsset?, atTime: TimeInterval) -> UIImage? {
        guard let avAsset = avAsset else { return nil }
        let assetImageGenerator = AVAssetImageGenerator.init(asset: avAsset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.apertureMode = .encodedPixels
        let thumbnailImageTime: CFTimeInterval = atTime
        do {
            let thumbnailImageRef = try assetImageGenerator.copyCGImage(at: CMTime(value: CMTimeValue(thumbnailImageTime), timescale: avAsset.duration.timescale), actualTime: nil)
            let image = UIImage.init(cgImage: thumbnailImageRef)
            return image
        } catch {
            return nil
        }
    }

    /// 根据视频地址获取视频时长
    func getVideoDuration(videoURL: URL?) -> TimeInterval {
        guard let videoURL = videoURL else { return 0 }
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: false]
        let urlAsset = AVURLAsset.init(url: videoURL, options: options)
//        let second = TimeInterval(urlAsset.duration.value) / TimeInterval(urlAsset.duration.timescale)
        return TimeInterval(round(urlAsset.duration.seconds))
    }

    func resetValidRect() {
        let imgWidth = imageWidth * 0.5
        frameMaskView.validRect = CGRect(x: validRectX + imgWidth, y: 0, width: width - (validRectX + imgWidth) * 2, height: itemHeight)
    }
}

extension VideoTimeView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoFrameCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(VideoEditorCropViewCell.self), for: indexPath) as! VideoEditorCropViewCell
        return item
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item < videoFrameCount - 1 {
            return CGSize(width: itemWidth, height: itemHeight - 4)
        }
        let itemW = contentWidth - CGFloat(indexPath.item) * itemWidth
        return CGSize(width: itemW, height: itemHeight - 4)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cgImage = videoFrameMap[indexPath.item] {
            // swiftlint:disable force_cast
            let myCell = cell as! VideoEditorCropViewCell
            myCell.image = UIImage.init(cgImage: cgImage)
        }
    }

    func setCurrentCell(image: UIImage, index: Int) {
        DispatchQueue.main.async {
            let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoEditorCropViewCell
            cell?.image = image
        }
    }
}

extension VideoTimeView: VideoFrameViewDelegate {
    func frameMaskView(validRectDidChanged frameMaskView: VideoFrameView) {
        delegate?.timeView(self, didChangedValidRectAt: getStartTime(real: true))
        updateTimeLabels()
    }
    func frameMaskView(validRectEndChanged frameMaskView: VideoFrameView) {
        delegate?.timeView(self, endChangedValidRectAt: getStartTime(real: true))
        updateTimeLabels()
    }

    // MARK: 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if videoFrameCount > 0 {
            delegate?.timeView(self, didScrollAt: getStartTime(real: true))
            updateTimeLabels()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            delegate?.timeView(self, endScrollAt: getStartTime(real: true))
            updateTimeLabels()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.timeView(self, endScrollAt: getStartTime(real: true))
        updateTimeLabels()
    }
}

/// 时间轴图片
class VideoEditorCropViewCell: UICollectionViewCell {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // imageView.frame = bounds
        self.contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}

// MARK: - private mothods
extension VideoTimeView {

}

// MARK: - call backs
extension VideoTimeView {

}

// MARK: - delegate or data source
extension VideoTimeView {

}

// MARK: - other classes
