//
//  TableViewCell.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/23.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: - global var and methods
class TableViewCellViewModel: NSObject {}

/// 自定义next Cell
class TableViewCell: UITableViewCell {
    
    lazy var nextImgView: UIImageView = {
        let _nextImgView = UIImageView(image: R.image.next_month_normal()?.adaptRTL)
        _nextImgView.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        _nextImgView.contentMode = .scaleAspectFit
        return _nextImgView
    }()
    
    // 固定accessoryView位置
    override func layoutSubviews() {
        super.layoutSubviews()
        if let accessoryView = self.accessoryView {
            var tFrame = accessoryView.frame
            tFrame.origin.x = isRTL ? 15: frame.size.width - 30
            accessoryView.frame = tFrame
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryView = nextImgView
        self.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(to viewModel: TableViewCellViewModel) {}
}
