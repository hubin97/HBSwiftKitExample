//
//  NetworkReachability.swift
//  WingToSmart
//
//  Created by Hubin_Huang on 2022/2/22.
//  Copyright © 2020 云图数字. All rights reserved.

import Alamofire

// MARK: NetworkReachability (支持Alamofire 5及更高版本)

final class NetworkReachability {

    static let shared = NetworkReachability()

    private let reachability = NetworkReachabilityManager(host: "www.apple.com")!

    typealias NetworkReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus

    private init() {}

    /// Start observing reachability changes
    func startListening() {
        reachability.startListening { [weak self] status in
            switch status {
            case .notReachable:
                self?.updateReachabilityStatus(.notReachable)
            case .reachable(let connection):
                self?.updateReachabilityStatus(.reachable(connection))
            case .unknown:
                break
            }
        }
    }

    /// Stop observing reachability changes
    func stopListening() {
        reachability.stopListening()
    }

    /// Updated ReachabilityStatus status based on connectivity status
    ///
    /// - Parameter status: `NetworkReachabilityStatus` enum containing reachability status
    private func updateReachabilityStatus(_ status: NetworkReachabilityStatus) {
        switch status {
        case .notReachable:
            print("\(type(of: self)) => Internet not available")
            //CBToast.showToastAction(message: "似乎已断开与互联网的连接")
        case .reachable(.ethernetOrWiFi), .reachable(.cellular):
            print("\(type(of: self)) => Internet available")
            if status == .reachable(.cellular) {
                //CBToast.showToastAction(message: "当前使用移动网络,请注意流量消耗")
            }
        case .unknown:
            break
        }
    }

    /// returns current reachability status
    var isReachable: Bool {
        return reachability.isReachable
    }

    /// returns if connected via cellular
    var isConnectedViaCellular: Bool {
        return reachability.isReachableOnCellular
    }

    /// returns if connected via cellular
    var isConnectedViaWiFi: Bool {
        return reachability.isReachableOnEthernetOrWiFi
    }

    deinit {
        stopListening()
        print("deinit: \(type(of: self))")
    }
}
