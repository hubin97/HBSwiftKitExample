//
//  PodcastRequest.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import PromiseKit
import ObjectMapper

// MARK: - main class
class PodcastRequest {

    /// 获取专辑列表
    static func albums(pageNum: Int = 1, pageSize: Int = 100) -> Promise<[PodcastAlbumListMeta]> {
        return Promise.init { resolver in
            fetchTargetMeta(targetType: PodcastApi.self, target: .albums(pageNum: pageNum, pageSize: pageSize), metaType: LTBaseRsp.self, plugins: PTEnum.noloadings()).done { baseRsp in
                if let dict = baseRsp.result, let listMap = dict.value(forKey: "albumList") as? [[String: Any]], baseRsp.isOK {
                    let array = Mapper<PodcastAlbumListMeta>().mapArray(JSONArray: listMap)
                    resolver.fulfill(array)
                } else {
                    resolver.reject(NetworkError.exception(msg: baseRsp.message ?? ""))
                }
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    /// 获取专辑音频列表
    static func albumItems(albumId: Int) -> Promise<[PodcastAlbumAudioListMeta]> {
        return Promise.init { resolver in
            fetchTargetMeta(targetType: PodcastApi.self, target: .albumItems(albumId: albumId), metaType: LTBaseRsp.self, plugins: PTEnum.noloadings()).done { baseRsp in
                if let dict = baseRsp.result, let listMap = dict.value(forKey: "albumItemList") as? [[String: Any]], baseRsp.isOK {
                    let array = Mapper<PodcastAlbumAudioListMeta>().mapArray(JSONArray: listMap)
                    resolver.fulfill(array)
                } else {
                    resolver.reject(NetworkError.exception(msg: baseRsp.message ?? ""))
                }
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    /// 专辑设置为已读
//    @discardableResult
//    static func albumRead(albumId: Int) -> Promise<LTBaseRsp> {
//        return Promise.init { resolver in
//            fetchTargetMeta(targetType: PodcastApi.self, target: .albumRead(albumId: albumId), metaType: LTBaseRsp.self, plugins: PTEnum.noloadings()).done { baseRsp in
//                resolver.fulfill(baseRsp)
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
    
    /// 获取音频详情
//    static func audioDetail(id: Int) -> Promise<PodcastAlbumAudioListMeta> {
//        return Promise.init { resolver in
//            fetchTargetMeta(targetType: PodcastApi.self, target: .audioDetail(id: id), metaType: LTBaseRsp.self, plugins: PTEnum.noloadings()).done { baseRsp in
//                if let dict = baseRsp.result, let meta = Mapper<PodcastAlbumAudioListMeta>().map(JSON: dict), baseRsp.isOK {
//                    resolver.fulfill(meta)
//                } else {
//                    resolver.reject(NetworkError.exception(msg: baseRsp.message ?? ""))
//                }
//            }.catch { error in
//                resolver.reject(error)
//            }
//        }
//    }
}
