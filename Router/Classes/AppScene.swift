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
public enum TestScene: SceneProvider {
 
    case safari(URL)
    case videoPlayController(url: String, autoPlay: Bool = true)
    case testList
    case webController(url: String, title: String?)

    // MARK: -
    public var getSegue: UIViewController? {
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
        case .testList:
            return TestListController(viewModel: ViewModel())
        case .webController(let url, let title):
            let vc = WKWebController(viewModel: nil)
            vc.setTitle(title)
            vc.loadWeb(urlPath: url)
            return vc
        }
    }
}
