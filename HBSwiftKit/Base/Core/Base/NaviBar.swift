//
//  NaviBar.swift
//  Momcozy
//
//  Created by hubin.h on 2024/3/11.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import SnapKit

// MARK: - global var and methods
protocol NaviBarDelegate: AnyObject {
    func backAction()
    func rightAction()
}

extension NaviBarDelegate {
    func rightAction() {}
    func backAction() {}
}

// MARK: - main class
public class NaviBar: UIView {
    
    public var title: String? {
        didSet {
            titleView.title = title
        }
    }
    
    weak var delegate: NaviBarDelegate?
        
    public var leftView: UIView?
    public var rightView: UIView?

    public lazy var backButton: UIButton = {
        let _backButton = UIButton(type: .custom)
        _backButton.setImage(UIImage.bundleImage(named: "icon_back")?.adaptRTL, for: .normal)
        _backButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return _backButton
    }()

    lazy var titleView: LTTitleView = {
        let _titleView = LTTitleView()
        return _titleView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kNavBarAndSafeHeight))
        self.backgroundColor = .white
        self.addSubview(backButton)
        self.addSubview(titleView)
        self.leftView = backButton
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.width.height.equalTo(kNavBarHeight)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.leading.equalTo(backButton.snp.trailing).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
    }
    
    @objc func backAction(_ sender: UIButton) {
        delegate?.backAction()
    }
    
    @objc func rightAction(_ sender: UIButton) {
        delegate?.rightAction()
    }
    
    func setBackButton() {}
    
    //
    public func setLeftView(_ tmpView: UIView) {
        self.leftView?.removeFromSuperview()
        self.addSubview(tmpView)
        
        let sizeH = tmpView.height
        let oX = tmpView.origin.x == 0 ? 10 : tmpView.origin.x
        let oY = kStatusBarHeight + (kNavBarHeight - sizeH)/2
        
        tmpView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(oX)
            make.top.equalToSuperview().offset(oY)
            make.size.equalTo(tmpView.frame.size)
        }
        
        titleView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.leading.equalTo(tmpView.snp.trailing).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
        
        self.leftView = tmpView
    }
    
    public func setRightView(_ tmpView: UIView?) {
        self.rightView?.removeFromSuperview()
        guard let tmpView = tmpView else {
            self.rightView = nil
            return
        }
        self.addSubview(tmpView)
        
        let sizeH = tmpView.height
        let oX = tmpView.origin.x == 0 ? 10 : tmpView.origin.x
        let oY = kStatusBarHeight + (kNavBarHeight - sizeH)/2

        tmpView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(oX)
            make.top.equalToSuperview().offset(oY)
            make.size.equalTo(tmpView.frame.size)
        }
        
        self.rightView = tmpView
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // FIXME: 保证titleView对称居中, (仅当左右视图都存在时 才需要调整)
        if let leftView = leftView, let rightView = rightView {
            let marign_left = leftView.frame.minX + leftView.width
            let marign_right = bounds.width - rightView.frame.minX
            let margin_max = max(marign_left, marign_right)
            let offsetX = margin_max - marign_left + 5
            // print("marign_left: \(marign_left) marign_right: \(marign_right)")
            
            titleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(kStatusBarHeight)
                make.leading.equalTo(leftView.snp.trailing).offset(offsetX)
                make.centerX.equalToSuperview()
                make.height.equalTo(kNavBarHeight)
            }
        }
    }
}

// MARK: - private mothods
extension NaviBar { 
}

// MARK: - call backs
extension NaviBar { 
}

// MARK: - delegate or data source
extension NaviBar { 
    
    class LTTitleView: UIView {
        
        var title: String? {
            didSet {
                titleLabel.text = title
            }
        }
        
        lazy var titleLabel: UILabel = {
            let _titleLabel = UILabel()
            _titleLabel.frame = bounds
            _titleLabel.textColor = .black
            _titleLabel.textAlignment = .center
            _titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            return _titleLabel
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.addSubview(titleLabel)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.titleLabel.frame = bounds
        }
    }
}

// MARK: - other classes
