//
//  VideoPlayController.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/29.
//  Copyright © 2020 Wingto. All rights reserved.

import UIKit
import Foundation
import AVFoundation
//MARK: - global var and methods

//MARK: - main class
class VideoPlayController: BaseViewController {

    override func setupUi() {
        
        //构建ui
        let backView = UIView.init(frame: CGRect(x: 0, y: 100, width: 400, height: 400))
        view.addSubview(backView)
        backView.setRoundCorners(borderColor: .blue, borderWidth: 1, raddi: 2, corners: .allCorners, isDotted: true, lineDashPattern: [2, 4])
        // 初始化播放器item
        let urlStr = "http://rts-atlas-dev.wingto.com:18100/hls/755d38e6d163e820edda070141c443aa49480052/2021/09/28/101143.m3u8?bucket=wingto-test&time=1632795103-1632795703&expires=1632907774&sign=88a0965f4732586c19621d50cd6eb51e"
        let playerItem = AVPlayerItem.init(url: URL.init(string: urlStr)!)
        let player = AVPlayer.init(playerItem: playerItem)
        
        // 初始化播放器的Layer
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = backView.bounds
        backView.layer.insertSublayer(playerLayer, at: 0)
        player.play()
        
        DDLogVerbose("哈哈哈测试一下")
    }
}

//MARK: - private mothods
extension VideoPlayController {
    
}

//MARK: - call backs
extension VideoPlayController {
    
}

//MARK: - delegate or data source
extension VideoPlayController {
    
}

//MARK: - other classes
