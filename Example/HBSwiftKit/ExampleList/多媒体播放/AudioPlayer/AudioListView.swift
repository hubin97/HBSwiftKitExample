//
//  AudioListView.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/27.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class AudioListCell: TableViewCell {
    
    // 歌曲标题
    lazy var titleLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        _label.textColor = .black
        return _label
    }()
    
    // 艺术人
    lazy var artistLabel: UILabel = {
        let _label = UILabel()
        _label.font = UIFont.systemFont(ofSize: 14)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        artistLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(-10)
        }
    }
    
    func configure(with item: AVPlaylistItem) {
        titleLabel.text = item.title
        artistLabel.text = item.artist
    }
}
