//
//  PodcastApi.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/10.

import Foundation
import Moya
// MARK: - global var and methods

// MARK: - main class
enum PodcastApi: TargetType {
    
    /// 专辑设置为已读 PUT /api/app/podcast/album/read/{albumId}
    case albumRead(albumId: Int)
    /// 获取专辑列表 GET /api/app/podcast/albums
    case albums(pageNum: Int, pageSize: Int)
    /// 获取专辑音频列表 GET /api/app/podcast/albums/{albumId}/items
    case albumItems(albumId: Int)
    /// 获取音频详情 GET /api/app/podcast/albums/item/{id}
    case audioDetail(id: Int)
}

// MARK: - private mothods
extension PodcastApi {
    
    var path: String {
        switch self {
        case .albumRead(albumId: let albumId):
            return "/api/app/podcast/album/read/\(albumId)"
        case .albums:
            return "/api/app/podcast/albums"
        case .audioDetail(id: let id):
            return "/api/app/podcast/albums/item/\(id)"
        case .albumItems(albumId: let albumId):
            return "/api/app/podcast/albums/\(albumId)/items"
        }
    }
  
    var task: Moya.Task {
        switch self {
        case .albumRead:
            return .requestData(Data())
        case .albums(pageNum: let pageNum, pageSize: let pageSize):
            return .requestParameters(parameters: ["pageNum": pageNum, "pageSize": pageSize], encoding: URLEncoding.default)
        case .albumItems, .audioDetail:
            return .requestPlain
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .albumRead:
            return .put
        default:
            return .get
        }
    }
    
    var baseURL: URL {
        return URL(string: "https://xxx")!
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    var sampleData: Data {
        switch self {
        case .albums:
            return
            """
            {"code":"200","message":"ok","traceId":"T2024121210562883057232","result":{"total":3,"pages":1,"code":"200","message":"ok","albumList":[{"id":1,"title":"测试标题","description":"测试描述","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/dc8c181e9b85ab64193145e92decd433.png","createTime":1733817599330,"updateTime":1733826104668,"playCount":13,"new":true},{"id":2,"title":"测试标题2","description":"测试描述","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/dc8c181e9b85ab64193145e92decd433.png","createTime":1733817599330,"updateTime":1733826104668,"playCount":13,"new":false},
                {"id":3,"title":"测试标题3","description":"测试描述","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/dc8c181e9b85ab64193145e92decd433.png","createTime":1733817599330,"updateTime":1733826104668,"playCount":13,"new":false}]}}
            """.data ?? Data()
        case .albumItems:
            return
            """
            {"code":"200","message":"ok","traceId":"T2024121210181607989126","result":{"albumItemList":[{"id":1,"title":"周杰伦1","description":"周杰伦 1","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/ad2aaa6e8b9044dd731bbcef2446fe46.png","resourceUrl":"https://cozy-static-dev.cozyinnov.com/nonpub/970040/C00000001/app/podcast/m1.mp3?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241212T021816Z&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAYS2NUWHM6EBMPEWQ%2F20241212%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=2d5620a13b2e3dd6a4a68d5df43400d7b30795907e5400638f817095765290fe","duration":1000000,"createTime":1733821503577,"updateTime":1733826104648,"playCount":14,"new":true},{"id":2,"title":"周杰伦2","description":"周杰伦 2","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/ad2aaa6e8b9044dd731bbcef2446fe46.png","resourceUrl":"https://cozy-static-dev.cozyinnov.com/nonpub/970040/C00000001/app/podcast/m2.mp3?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241212T021816Z&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAYS2NUWHM6EBMPEWQ%2F20241212%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=c2ed2f2e206f2ee72fbc72e52ebb9338b039bc2f6162112c9bee41b8fbf3db23","duration":1000000,"createTime":1733821503577,"updateTime":1733824509561,"playCount":1,"new":true},{"id":3,"title":"周杰伦3","description":"周杰伦 3","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/ad2aaa6e8b9044dd731bbcef2446fe46.png","resourceUrl":"https://cozy-static-dev.cozyinnov.com/nonpub/970040/C00000001/app/podcast/m3.mp3?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241212T021816Z&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAYS2NUWHM6EBMPEWQ%2F20241212%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=8189badba0280f170a23e9a391daa91da80d55123c6c0d1affd286828e8b9ed9","duration":1000000,"createTime":1733821503577,"updateTime":1733824517396,"playCount":1,"new":true},{"id":4,"title":"周杰伦4","description":"周杰伦 5","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/ad2aaa6e8b9044dd731bbcef2446fe46.png","resourceUrl":"https://cozy-static-dev.cozyinnov.com/nonpub/970040/C00000001/app/podcast/m4.mp3?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241212T021816Z&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAYS2NUWHM6EBMPEWQ%2F20241212%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=0adcdde983d64a91d1efc20188b7401898e75023974f2864aaf97a914de7560b","duration":1000000,"createTime":1733821503577,"updateTime":1733824522788,"playCount":1,"new":true},{"id":5,"title":"真实-长","description":"长","picture":"https://cozy-static-dev.cozyinnov.com/public/970040/C00000001/app/podcast/ad2aaa6e8b9044dd731bbcef2446fe46.png","resourceUrl":"https://cozy-static-dev.cozyinnov.com/nonpub/970040/C00000001/app/podcast/big1.mp3?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241212T021816Z&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAYS2NUWHM6EBMPEWQ%2F20241212%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Expires=3600&X-Amz-Signature=02e49d60a8d26776a5dcaede7028c9ad9b0411284e135df441a5b236655748c2","duration":1000000,"createTime":1733821503577,"updateTime":1733905876601,"playCount":1,"new":true}]}}
            """.data ?? Data()
        default:
            return Data()
        }
    }
}
