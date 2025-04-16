//
//  ReachabilityManager.swift
//  Momcozy
//
//  Created by hubin.h on 2024/5/14.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import Alamofire
import RxSwift
import RxRelay

public typealias NetworkReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus
public func connectedToInternet() -> Observable<NetworkReachabilityStatus> {
    return ReachabilityManager.shared.reach
}

// 获取网络类型, 区分 WiFi和蜂窝网络
public func globalNetworkType() -> BehaviorRelay<String> {
    let networkStatusRelay = BehaviorRelay<String>(value: "Unknown")
    let disposeBag = DisposeBag()
    connectedToInternet()
        .map { status in
            switch status {
            case .notReachable:
                return "No Connection"
            case .unknown:
                return "Unknown"
            case .reachable(.ethernetOrWiFi):
                return "WiFi"
            case .reachable(.cellular):
                return TelephonyNetwork.cellularNetworkType
            }
        }
        .distinctUntilChanged()
        .bind(to: networkStatusRelay)
        .disposed(by: disposeBag) // 确保你有一个 disposeBag
    return networkStatusRelay
}

// 获取蜂窝网络运营商
public func globalCarrier() -> BehaviorRelay<String> {
    let networkCarrierRelay = BehaviorRelay<String>(value: "Unknown")
    let disposeBag = DisposeBag()
    connectedToInternet()
        .filter({ $0 != .notReachable && $0 != .unknown })
        .map { _ in TelephonyNetwork.carrierName }
        .distinctUntilChanged()
        .bind(to: networkCarrierRelay)
        .disposed(by: disposeBag) // 确保你有一个 disposeBag
    return networkCarrierRelay
}

// MARK: NetworkReachability (支持Alamofire 5及更高版本)
final class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
   
    let reachSubject = ReplaySubject<NetworkReachabilityStatus>.create(bufferSize: 1)
    var reach: Observable<NetworkReachabilityStatus> {
        return reachSubject.asObserver()
    }
    
    override init() {
        super.init()
        NetworkReachabilityManager.default?.startListening { [weak self] status in
            self?.reachSubject.onNext(status)
        }
    }
}
