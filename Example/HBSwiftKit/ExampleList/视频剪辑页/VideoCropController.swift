//
//  VideoCropController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/8.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import AVFoundation
import MobileCoreServices

//MARK: - global var and methods

//MARK: - main class
class VideoCropController: BaseViewController {

    var playTimer: DispatchSourceTimer?
    var autoPlay: Bool = true
    
    lazy var cropView: VideoCropView = {
        let _cropView = VideoCropView.init(frame: CGRect(x: 0, y: 20, width: kScreenW, height: kScreenW * 4/3))
        _cropView.playDelegate = self
        _cropView.cropDelegate = self
        return _cropView
    }()
    
    lazy var timeView: VideoTimeView = {
        let _timeView = VideoTimeView.init(frame: CGRect(x: 0, y: kScreenH - kNavBarAndSafeHeight - kTabBarAndSafeHeight - 70, width: kScreenW, height: 65))
        _timeView.delegate = self
        return _timeView
    }()
    
    lazy var toolView: VideoToolView = {
        let _toolView = VideoToolView.init(frame: CGRect(x: 0, y: kScreenH - kNavBarAndSafeHeight - kTabBarAndSafeHeight, width: kScreenW, height: kTabBarAndSafeHeight))
        _toolView.delegate = self
        return _toolView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "视频剪辑"
        self.view.backgroundColor = .black
        
        view.addSubview(cropView)
        view.addSubview(timeView)
        view.addSubview(toolView)
    }
}

//MARK: - private mothods
extension VideoCropController {
    
    func cropConfig(asset: AVAsset, whRatio: Float = 3.0/4, autoPlay: Bool = true) {
        self.autoPlay = autoPlay
        let showWidth = UIScreen.main.bounds.width
        let showHeight = showWidth / CGFloat(whRatio)
        self.cropView.frame = CGRect(x: 0, y: 20, width: showWidth, height: showHeight)
        self.cropView.load(asset: asset, cropSize: CGSize(width: 480, height: 640))
        
        self.timeView.configData(avAsset: asset)
    }
}

//MARK: - call backs
extension VideoCropController {
    
 
}

//MARK: - delegate or data source
extension VideoCropController {
}


// MARK: VideoPlayerViewDelegate
extension VideoCropController: VideoPlayerViewDelegate {
    func playerView(_ playerView: VideoCropView, didPlayAt time: CMTime) {
        timeView.startLineAnimation(at: time)
    }
    func playerView(_ playerView: VideoCropView, didPauseAt time: CMTime) {
        timeView.stopLineAnimation()
    }
    func playerView(_ playerViewReadyForDisplay: VideoCropView) {
//        if firstPlay {
//            croppingAction()
//            firstPlay = false
//        }
        if autoPlay {
            self.startPlayTimer()
            self.cropView.resetPlay()
            self.timeView.updateTimeLabels()
            self.timeView.resetValidRect()
        }
    }
}

//MARK: VideoCropDelegate
extension VideoCropController: VideoCropViewDelegate {
    func exportFailed(error: Error?) {
        print("exportFailed:\(error?.localizedDescription ?? "")")
    }
    
    func exportSuccess(outputUrl: URL) {
        print("exportSuccess:\(outputUrl)")
    }
    
    func exportProgress(progress: CGFloat) {
        print("exportProgress:\(progress)")
    }
}

//MARK: - VideoTimeViewDelegate
extension VideoCropController: VideoTimeViewDelegate {
    func timeView(_ timeView: VideoTimeView, didChangedValidRectAt time: CMTime) {
        pausePlay(at: time)
    }
    
    func timeView(_ timeView: VideoTimeView, endChangedValidRectAt time: CMTime) {
        startPlay(at: time)
    }
    
    func timeView(_ timeView: VideoTimeView, didScrollAt time: CMTime) {
        pausePlay(at: time)
    }
    
    func timeView(_ timeView: VideoTimeView, endScrollAt time: CMTime) {
        startPlay(at: time)
    }
    
    func timeView(_ timeView: VideoTimeView, progressLineDragBeganAt time: CMTime) {
    }
    
    func timeView(_ timeView: VideoTimeView, progressLineDragChangedAt time: CMTime) {
    }
    
    func timeView(_ timeView: VideoTimeView, progressLineDragEndAt time: CMTime) {
    }
    
    //MARK:-
    func pausePlay(at time: CMTime) {
        //if state == .cropping && !orientationDidChange {
        stopPlayTimer()
        cropView.shouldPlay = false
        cropView.playStartTime = time
        cropView.pause()
        cropView.seek(to: time)
        timeView.stopLineAnimation()
        //}
    }
    func startPlay(at time: CMTime) {
        //if state == .cropping && !orientationDidChange {
        cropView.playStartTime = time
        cropView.playEndTime = timeView.getEndTime(real: true)
        cropView.resetPlay()
        cropView.shouldPlay = true
        startPlayTimer()
        //}
    }
    func startPlayTimer(reset: Bool = true) {
        startPlayTimer(reset: reset, startTime: timeView.getStartTime(real: true), endTime: timeView.getEndTime(real: true))
    }
    func startPlayTimer(reset: Bool = true, startTime: CMTime, endTime: CMTime) {
        stopPlayTimer()
        let playTimer = DispatchSource.makeTimerSource()
        var microseconds: Double
        if reset {
            microseconds = (endTime.seconds - startTime.seconds) * 1000000
        }else {
            microseconds = (cropView.player.currentTime().seconds - timeView.getStartTime(real: true).seconds) * 1000000
        }
        playTimer.schedule(deadline: .now(), repeating: .microseconds(Int(microseconds)), leeway: .microseconds(0))
        playTimer.setEventHandler(handler: {
            DispatchQueue.main.sync {
                self.cropView.resetPlay()
            }
        })
        playTimer.resume()
        self.playTimer = playTimer
    }
    func stopPlayTimer() {
        if let playTimer = playTimer {
            playTimer.cancel()
            self.playTimer = nil
        }
    }
}

//MARK: - VideoToolViewDelegate
extension VideoCropController: VideoToolViewDelegate {
    func videoToolActionCancel() {
        cropView.pause()
        timeView.stopLineAnimation()
        toolView.playBtn.isSelected = false
    }
    
    func videoToolActionConfir() {
        // 完成处理
        
        /**
         (lldb) po timeView.getEndDuration()
         11.0

         (lldb) po timeView.getStartDuration()
         2.7164852915290387

         (lldb) po timeView.getMiddleDuration()
         8.149455874587117
         */
        
        /// 可行
        //let start = CMTimeMakeWithSeconds(4, 600)
        //let end = CMTimeMakeWithSeconds(8, 600)
        let root = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let path = root!+"/out.mp4"
        if FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.removeItem(atPath: path)
        }
        cropView.export(timeView.avAsset, cropView.cropRect(), CMTimeRange(start: timeView.getStartTime(), end: timeView.getEndTime()), cropView.outputSize ?? cropView.size, URL(fileURLWithPath: path))
    }
    
    func videoToolActionPlay(_ isPlay: Bool) {
        if isPlay {
            cropView.play()
            timeView.startLineAnimation(at: cropView.player.currentTime())
        } else {
            cropView.pause()
            timeView.stopLineAnimation()
        }
    }
}

//MARK: - other classes
