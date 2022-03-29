//
//  NetworkApi.swift
//  HBSwiftKit_Tests
//
//  Created by Hubin_Huang on 2022/3/28.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import Moya
// MARK: - global var and methods

// MARK: - main class
enum NetworkApi: TargetType {

    // https://api.wmdb.tv/api/v1/top?type=Imdb&skip=0&limit=20&lang=Cn
    case in_theaters
}

// MARK: - private mothods
extension NetworkApi {

    var baseURL: URL {
        return URL(string: "https://api.wmdb.tv/api/v1/top?type=Imdb&skip=0&limit=20&lang=Cn")!
       // return URL(string: "https://api.wmdb.tv/api/v1/top")!
    }

    var path: String {
        switch self {
        case .in_theaters:
            return "" // "type=Imdb&skip=0&limit=20&lang=Cn"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .in_theaters:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json; charset=utf-8"]
    }
}
