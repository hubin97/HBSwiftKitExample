//
//  LTCalendarItem.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/29.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation

// MARK: LTCalendarItem
class LTCalendarItem: UICollectionViewCell {
    
    /// 日期状态
    var state: LTCalendarMeta.DayState = .normal
    
    /// 主题配置
    var themeConfig: LTCalendarThemeConfig = LTCalendarThemeConfig() {
        didSet {
            self.textNormalColor = themeConfig.textNormalColor
            self.textSelectedColor = themeConfig.textSelectedColor
            self.textDisableColor = themeConfig.textDisableColor
            self.itemBackgroundColor = themeConfig.itemBackgroundColor
            self.selectedBackgroundColor = themeConfig.selectedBackgroundColor
            self.todayBackgroundColor = themeConfig.todayBackgroundColor
            self.todayTextColor = themeConfig.todayTextColor
            self.dotColor = themeConfig.dotColor
            self.textNormalFont = themeConfig.textNormalFont
            self.textSelectedFont = themeConfig.textSelectedFont
        }
    }

    /// 文本正常颜色
    private var textNormalColor: UIColor = .black
    /// 文本选中颜色
    private var textSelectedColor: UIColor = .white
    /// 文本不可用颜色
    private var textDisableColor: UIColor = .lightGray
    /// 背景颜色
    private var itemBackgroundColor: UIColor = .white
    /// 选中背景颜色
    private var selectedBackgroundColor: UIColor = .red
    /// 今天背景颜色
    private var todayBackgroundColor: UIColor = .red.withAlphaComponent(0.5)
    /// 今天文本颜色
    private var todayTextColor: UIColor = .red
    /// 点的颜色
    private var dotColor: UIColor = .red
    /// 文本正常大小
    private var textNormalFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// 文本选中大小
    private var textSelectedFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)

    /// 是否显示点
    private var isDotShow: Bool = false
    /// 是否被选中
    private var isTap: Bool = false
    /// 是否可以被点击
    private var isEnable: Bool = false
    /// 是否是今天
    private var markToday: Bool = false

    private let itemWH: CGFloat = 36
    private let dotWH: CGFloat = 4
    private let today = "今"//RLocalizable.string_today_shortening.key.localized

    private lazy var dayLabel: UILabel = {
        let _dayLabel = UILabel()
        _dayLabel.textAlignment = .center
        _dayLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        _dayLabel.setBorder(cornerRadius: itemWH / 2, makeToBounds: true)
        _dayLabel.isUserInteractionEnabled = true
        _dayLabel.backgroundColor = itemBackgroundColor
        //_dayLabel.textColor = textNormalColor
        return _dayLabel
    }()
    
    private lazy var dotView: UIView = {
        let _dotView = UIView()
        _dotView.setBorder(cornerRadius: dotWH / 2, makeToBounds: true)
        _dotView.backgroundColor = dotColor
        return _dotView
    }()
    
    // 选中背景图标 (弃用图片, 这里显示有问题)
    private lazy var itemSelectView: UIImageView = {
        let _dayIconView = UIImageView()
        _dayIconView.image = UIImage(color: .red) //R.image.icon_calendar_item_selected()
        _dayIconView.isHidden = true
        return _dayIconView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(itemSelectView)
        self.contentView.addSubview(dayLabel)
        self.dayLabel.addSubview(dotView)

        self.dayLabel.snp.makeConstraints { (make) in
            make.width.height.equalTo(itemWH)
            make.center.equalToSuperview()
        }
        self.itemSelectView.snp.makeConstraints { (make) in
            make.center.equalTo(dayLabel)
            make.width.height.equalTo(dayLabel)
        }
        self.dotView.snp.makeConstraints { (make) in
            make.width.height.equalTo(dotWH)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        print("prepareForReuse")
//        self.dayLabel.text = ""
//        self.dayLabel.backgroundColor = itemBackgroundColor
//        self.dayLabel.textColor = textNormalColor
//        self.dotView.isHidden = true
//    }

    /// 配置样式
    /// - Parameters:
    ///   - state: 设置状态
    ///   - content: 文案, 如果为nil, 取之前的文案
    ///   - isDotShow: 是否显示点, 如果为nil, 取之前的状态
    func configure(state: LTCalendarMeta.DayState, content: String? = nil, isDotShow: Bool? = nil, showSelectBg: Bool = false) {
        self.state = state
        self.dayLabel.text = state == .today ? today: content
        self.isDotShow = isDotShow ?? self.isDotShow
        self.dotView.backgroundColor = dotColor
        self.dayLabel.font = textNormalFont
        self.itemSelectView.isHidden = true
        self.dotView.isHidden = !self.isDotShow

        switch state {
        case .none:
            dayLabel.backgroundColor = itemBackgroundColor
            //dayLabel.text = ""
            // 非本月日期颜色
            dayLabel.textColor = textNormalColor
        case .normal:
            dayLabel.backgroundColor = itemBackgroundColor
            dayLabel.textColor = textNormalColor
        case .today:
            dayLabel.backgroundColor = todayBackgroundColor
            dayLabel.textColor = todayTextColor
        case .selected:
            // 选中时不显示点
            dotView.isHidden = true
            itemSelectView.isHidden = !showSelectBg
            dayLabel.backgroundColor = showSelectBg ? itemBackgroundColor: selectedBackgroundColor
            dayLabel.textColor = textSelectedColor
            dayLabel.font = textSelectedFont
        case .disable:
            dayLabel.backgroundColor = itemBackgroundColor
            dayLabel.textColor = textDisableColor
        }
        
    }
    
    func configure(with meta: LTCalendarMeta) {
        self.configure(state: meta.state, content: "\(meta.date.day)", isDotShow: meta.isDotShow)
    }
}
