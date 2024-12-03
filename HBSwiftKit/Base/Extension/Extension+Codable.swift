//
//  Extension+Codable.swift
//  HBSwiftKit
//
//  Created by Hubin_Huang on 2021/12/17.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation

// MARK: - global var and methods
fileprivate typealias Extension_Encodable = Encodable
fileprivate typealias Extension_Decodable = Decodable

// MARK: - private mothods
extension Extension_Encodable {

    /// 模型转json
    public func objToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return String(decoding: jsonData, as: UTF8.self)
    }
}

// MARK: - other classes
extension Extension_Decodable {

}
