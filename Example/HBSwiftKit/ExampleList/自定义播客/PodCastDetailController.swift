//
//  PodCastDetailController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import HBSwiftKit

// MARK: - global var and methods

// MARK: - main class
class PodCastDetailController: ViewController, ViewModelProvider {
    typealias ViewModelType = PodCastDetailViewModel
    
    // 背景图
    lazy var bgImageView: UIImageView = {
        let _bgImageView = UIImageView(image: UIImage(color: .gray))
        _bgImageView.contentMode = .scaleAspectFill
        _bgImageView.clipsToBounds = true
        return _bgImageView
    }()
    
    // 高斯蒙层
    lazy var blurView: UIVisualEffectView = {
        let _blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return _blurView
    }()
    
    // 返回按钮
    lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.setImage(R.image.ib_back()?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(tapBackAction), for: .touchUpInside)
        return _backButton
    }()
    
    // 工具栏
//    lazy var toolBar: PodCastDetailToolBar = {
//        let _toolBar = PodCastDetailToolBar()
//        return _toolBar
//    }()
    
    override func setupLayout() {
        super.setupLayout()
        view.addSubview(bgImageView)
        view.addSubview(blurView)
        view.addSubview(backButton)
        
        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalTo(10)
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
}

// MARK: - private mothods
extension PodCastDetailController { 
}

// MARK: - call backs
extension PodCastDetailController {
    
    @objc func tapBackAction() {
        backAction()
    }
}

// MARK: - delegate or data source
extension PodCastDetailController { 
}

// MARK: - other classes
