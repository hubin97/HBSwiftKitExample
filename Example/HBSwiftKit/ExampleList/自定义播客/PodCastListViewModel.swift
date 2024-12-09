//
//  PodCastListViewModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/9.

import Foundation

// MARK: - global var and methods

// MARK: - main class
class PodCastListViewModel: ViewModel {
    
    let podCastList: [PodCastItem] = [
        PodCastItem(title: "五音Jw-明月天涯", artist: "五音Jw", artwork: "https://bkimg.cdn.bcebos.com/pic/91ef76c6a7efce1bfaf3ea92a051f3deb58f6589?x-bce-process=image/format,f_auto/quality,Q_70/resize,m_lfit,limit_1,w_512", audioUrl: Bundle.main.url(forResource: "五音Jw-明月天涯", withExtension: "mp3"), desc: "五音Jw-明月天涯", playCount: "1000", updateTime: "2024-12-09"),
        PodCastItem(title: "萧忆情Alex - 不谓侠", artist: "萧忆情Alex", artwork: "https://i.kfs.io/album/global/121624025,0v1/fit/500x500.jpg", audioUrl: Bundle.main.url(forResource: "萧忆情Alex - 不谓侠", withExtension: "mp3"), desc: "萧忆情Alex - 不谓侠", playCount: "1000", updateTime: "2024-12-09"),
        PodCastItem(title: "李荣浩 - 老街", artist: "李荣浩", artwork: "https://static.fotor.com.cn/assets/stickers/freelancer_hyx_1016_06/763c2917-7e80-4514-8434-ff0e2671b55c_medium_thumb.jpg", audioUrl: Bundle.main.url(forResource: "李荣浩 - 老街", withExtension: "mp3"), desc: "李荣浩 - 老街", playCount: "1000", updateTime: "2024-12-09"),
    ]
    
    let posterViewHeight: CGFloat = 216
    let rowHeight: CGFloat = 100
    var contentSize: CGSize {
        return CGSize(width: 0, height: CGFloat(podCastList.count) * rowHeight + posterViewHeight)
    }
}

// MARK: - private mothods
extension PodCastListViewModel { 
}

// MARK: - call backs
extension PodCastListViewModel { 
}

// MARK: - delegate or data source
extension PodCastListViewModel { 
}

// MARK: - other classes
struct PodCastItem {
    let title: String
    let artist: String
    let artwork: String
    let audioUrl: URL?
    
    let desc: String
    let playCount: String
    let updateTime: String
}

struct PodCastModel {
    let artwork: String
    let title: String
    let desc: String
    let playCount: String
    let updateTime: String
    let item: PodCastItem? = nil
}
