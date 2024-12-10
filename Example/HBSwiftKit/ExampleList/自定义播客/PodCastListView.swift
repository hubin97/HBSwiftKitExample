//
//  PodCastListView.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import Foundation
import RxSwift

class PodCastPosterView: UIView {
    
    // 背景图
    lazy var bgView: UIImageView = {
        let _imgView = UIImageView()
        _imgView.contentMode = .scaleAspectFill
        _imgView.clipsToBounds = true
        return _imgView
    }()
    
    // 音频标题
    lazy var titleLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        _label.textColor = .white
        _label.textAlignment = .center
        return _label
    }()
    
    // 音频描述
    lazy var descLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        _label.textColor = .white
        _label.textAlignment = .center
        _label.numberOfLines = 0
        return _label
    }()
    
    // 播放量
    lazy var playCountLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        _label.textColor = .white
        _label.textAlignment = .center
        return _label
    }()
    
    // 更新时间
    lazy var updateTimeLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        _label.textColor = .white
        _label.textAlignment = .center
        return _label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(bgView)
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(playCountLabel)
        addSubview(updateTimeLabel)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(kTopSafeHeight + 15)
            make.leading.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(titleLabel.snp.leading)
            make.centerX.equalToSuperview()
        }
        
        playCountLabel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.leading.equalTo(titleLabel.snp.leading)
            make.centerX.equalToSuperview()
        }
        
        updateTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(playCountLabel.snp.bottom).offset(10)
            make.leading.equalTo(titleLabel.snp.leading)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(snp.bottom).offset(-10)
        }
    }
}

extension PodCastPosterView {
    
    func configure(with model: PodCastModel) {
        titleLabel.text = model.title
        descLabel.text = model.desc
        playCountLabel.text = "播放量: \(model.playCount)"
        updateTimeLabel.text = "更新时间: \(model.updateTime)"
        bgView.kf.setImage(with: URL(string: model.artwork))
    }
}

// MARK: PodCastListCell
class PodCastListCell: TableViewCell {
    
    // 歌曲封面图标
    lazy var iconView: UIImageView = {
        let _imgView = UIImageView()
        _imgView.contentMode = .scaleAspectFill
        _imgView.setBorder(cornerRadius: 8, makeToBounds: true)
        _imgView.isUserInteractionEnabled = true
        _imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapIconView)))
        return _imgView
    }()
    
    // 歌曲标题
    lazy var titleLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        _label.textColor = .black
        return _label
    }()
    
    // 歌曲简介
    lazy var descLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        _label.numberOfLines = 2
        _label.textColor = .gray
        return _label
    }()
    
    // 播放按钮
    lazy var playImgView: UIImageView = {
        let _playImgView = UIImageView(image: R.image.play())
        return _playImgView
    }()
    
    // 播放量
    lazy var playCountLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        _label.textColor = .gray
        return _label
    }()
    
    // 播放时长
    lazy var durationLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        _label.textColor = .gray
        return _label
    }()
    
    // 更新时间
    lazy var updateTimeLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        _label.textColor = .gray
        return _label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryView = nil
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(playImgView)
        contentView.addSubview(playCountLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(updateTimeLabel)
        
        iconView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.leading.equalTo(contentView).offset(10)
            make.width.height.equalTo(80)
            make.centerY.equalTo(contentView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.top)
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).offset(-10)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
        
        playImgView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.center.equalTo(iconView)
        }
        
        playCountLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(descLabel.snp.bottom).offset(5)
            make.bottom.equalTo(iconView.snp.bottom)
            make.leading.equalTo(titleLabel.snp.leading)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playCountLabel.snp.centerY)
            make.leading.equalTo(playCountLabel.snp.trailing).offset(10)
        }
        
        updateTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playCountLabel.snp.centerY)
            make.leading.equalTo(durationLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
  
    var viewModel: PodCastListCellViewModel?
    override func bind(to viewModel: TableViewCellViewModel) {
        super.bind(to: viewModel)
        guard let viewModel = viewModel as? PodCastListCellViewModel else { return }
        self.viewModel = viewModel
        
        viewModel.titleRelay.bind(to: titleLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.descRelay.bind(to: descLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.playCountRelay.bind(to: playCountLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.durationRelay.bind(to: durationLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.updateTimeRelay.bind(to: updateTimeLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.artworkRelay.bind(to: iconView.rx.image).disposed(by: rx.disposeBag)
    }
    
    @objc func tapIconView() {
        viewModel?.tapIconView()
    }
}
