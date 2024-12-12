//
//  PodcastModel.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import ObjectMapper

struct LTBaseRsp: Mappable {
    
    init?(map: ObjectMapper.Map) {}
    
    mutating func mapping(map: ObjectMapper.Map) {
        code <- map["code"]
        message <- map["message"]
        traceId <- map["traceId"]
        result <- map["result"]
    }
    var code: String?
    var message: String?
    var traceId: Int?
    var result: [String: Any]?
    
    var isOK: Bool {
        return code == "200"
    }
}

/// 专辑列表
struct PodcastAlbumListMeta: Mappable {
    var id: Int = 0
    var title: String = ""
    var description: String = ""
    var picture: String = ""
    var createTime: Int = 0
    var updateTime: Int = 0
    var playCount: Int = 0
    var isNew: Bool = false
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        picture <- map["picture"]
        createTime <- map["createTime"]
        updateTime <- map["updateTime"]
        playCount <- map["playCount"]
        isNew <- map["new"]
    }
    
    var updateTimeStr: String {
        return Date(timeIntervalSince1970: TimeInterval(updateTime/1000)).format(with: LocalizedUtils.dateFormat_YMD)
    }
}

/// 专辑内音频列表
struct PodcastAlbumAudioListMeta: Mappable {
    var id: Int = 0
    var title: String = ""
    var description: String = ""
    var picture: String = ""
    var resourceUrl: String = ""
    var duration: Int = 0
    var createTime: Int = 0
    var updateTime: Int = 0
    var playCount: Int = 0
    var isNew: Bool = false
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        description <- map["description"]
        picture <- map["picture"]
        resourceUrl <- map["resourceUrl"]
        duration <- map["duration"]
        createTime <- map["createTime"]
        updateTime <- map["updateTime"]
        playCount <- map["playCount"]
        isNew <- map["new"]
    }
    
    var updateTimeStr: String {
        return Date(timeIntervalSince1970: TimeInterval(updateTime/1000)).format(with: LocalizedUtils.dateFormat_YMD)
    }
}
