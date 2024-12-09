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
    case podcast
    
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
        case .podcast:
            return PodCastListController(viewModel: ViewModel(), navigator: Navigator.default)
        }
    }
}
