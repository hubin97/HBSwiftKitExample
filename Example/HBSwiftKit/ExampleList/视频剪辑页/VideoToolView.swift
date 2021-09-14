//
//  VideoToolView.swift
//  HBSwiftKit_Example
//
//  Created by Hubin_Huang on 2021/9/14.
//  Copyright © 2020 Wingto. All rights reserved.

import Foundation
import SnapKit
//MARK: - global var and methods
protocol VideoToolViewDelegate: class {
    func videoToolActionCancel()
    func videoToolActionConfir()
    func videoToolActionPlay(_ isPlay: Bool)
}

//MARK: - main class
class VideoToolView: UIView {

    weak var delegate: VideoToolViewDelegate?
    
    lazy var cancelBtn: UIButton = {
        let _cancelBtn = UIButton.init(type: .system)
        _cancelBtn.setTitle("取消", for: .normal)
        _cancelBtn.setTitleColor(UIColor(hexStr:"#6165C5"), for: .normal)
        _cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        _cancelBtn.addTarget(self, action: #selector(cancelAtion), for: .touchUpInside)
        return _cancelBtn
    }()
    
    lazy var confirBtn: UIButton = {
        let _confirBtn = UIButton.init(type: .system)
        _confirBtn.setTitle("确定", for: .normal)
        _confirBtn.setTitleColor(UIColor(hexStr:"#6165C5"), for: .normal)
        _confirBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        _confirBtn.addTarget(self, action: #selector(confirAtion), for: .touchUpInside)
        return _confirBtn
    }()
    
    lazy var playBtn: UIButton = {
        let _playBtn = UIButton.init(type: .system)
//        _playBtn.setImage(UIImage(named: ""), for: .normal)
//        _playBtn.setImage(UIImage(named: ""), for: .selected)
        _playBtn.setTitle(">", for: .normal)
        _playBtn.setTitle("||", for: .selected)
        _playBtn.addTarget(self, action: #selector(playAtion), for: .touchUpInside)
        return _playBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addSubview(cancelBtn)
        self.addSubview(confirBtn)
        self.addSubview(playBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        confirBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private mothods
extension VideoToolView {
    
}

//MARK: - call backs
extension VideoToolView {
    
    @objc func cancelAtion() {
        delegate?.videoToolActionCancel()
    }
    
    @objc func confirAtion() {
        delegate?.videoToolActionConfir()
    }
    
    @objc func playAtion() {
        playBtn.isSelected = !playBtn.isSelected
        delegate?.videoToolActionPlay(playBtn.isSelected)
    }
}

//MARK: - delegate or data source
extension VideoToolView {
    
}

//MARK: - other classes
