//
//  AppScene.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/3.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import HBSwiftKit
import AVKit

// MARK: - global var and methods
enum AppScene: SceneProvider {
 
    case safari(URL)
    case videoPlayController(url: String, autoPlay: Bool = true)
    case tabs(viewModel: TabBarViewModel)
    
    case mediaList
    case audioList(viewModel: AudioListViewModel)
    case audioPlayer(viewModel: AudioPlayerViewModel)
    
    case videoList(viewModel: VideoListViewModel)
    case videoPlayer(viewModel: VideoPlayerViewModel)

    // MARK: -
    var getSegue: UIViewController? {
        switch self {
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        case .videoPlayController(let url, let autoPlay):
            let vc = AVPlayerViewController()
            if let playUrl = URL(string: url) {
                let player = AVPlayer(url: playUrl)
                vc.player = player
                if autoPlay {
                    player.play()
                }
            }
            return vc
        case .tabs(let viewModel):
            let tabBarVc = TabBarController(viewModel: viewModel)
            tabBarVc.setAppearance(normalColor: UIColor.lightGray, selectColor: UIColor.black)
            return tabBarVc
        case .mediaList:
            return MediaListController(viewModel: ViewModel())
        case .audioList(viewModel: let viewModel):
            return AudioListController(viewModel: viewModel)
        case .audioPlayer(viewModel: let viewModel):
            return AudioPlayerController(viewModel: viewModel)
        case .videoList(viewModel: let viewModel):
            return VideoListController(viewModel: viewModel)
        case .videoPlayer(viewModel: let viewModel):
            return VideoPlayerController(viewModel: viewModel)
        }
    }
}
