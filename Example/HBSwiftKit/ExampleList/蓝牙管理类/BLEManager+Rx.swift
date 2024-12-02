//
//  BLEManager+Rx.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/2.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth

extension Reactive where Base: BLEManager {
    
    // MARK: - 中心管理者状态
    /// 中心管理者状态更新
    func managerStateUpdate() -> Observable<CBManagerState> {
        return Observable.create { observer in
            self.base.setOnStateChanged { state in
                observer.onNext(state)
            }
            return Disposables.create { }
        }.asObservable()
    }
        
    // MARK: - 扫描
    /// 扫描状态更新
    func scanStateUpdate() -> Observable<BLEScanState> {
        return Observable.create { observer in
            self.base.setOnScanStateChange { state in
                observer.onNext(state)
            }
            return Disposables.create { }
        }.asObservable()
    }
    
    // MARK: - 发现外设/解析广播包
    /// 常规发现外设
    func peripheralDiscovered() -> Observable<(CBPeripheral, BLEPeripheraData)> {
        return Observable.create { observer in
            self.base.setOnPeripheralDiscovered { peripheral, advData in
                observer.onNext((peripheral, advData))
            }
            return Disposables.create { }
        }.asObservable()
    }

    /// 仅在指定解析器时, 发现外设回调
    func peripheralDiscoveredWithParser<T>() -> Observable<(CBPeripheral, BLEPeripheraData, T?)> {
        return Observable.create { observer in
            self.base.setOnPeripheralDiscoveredWithParser { peripheral, pdata, data in
                observer.onNext((peripheral, pdata, data))
            }
            return Disposables.create { }
        }.asObservable()
    }
    
    // MARK: - 连接
    /// 连接状态更新
    func connectStateUpdate() -> Observable<(BLEConnectionState, CBPeripheral)> {
        return Observable.create { observer in
            self.base.setOnConnectionStateChange { state, peripheral in
                observer.onNext((state, peripheral))
            }
            return Disposables.create { }
        }.asObservable()
    }
    
    /// 重连阶段及结果回调 (成功或失败, 达到最大重连次数)
    func reconnectPhaseUpdate() -> Observable<(CBPeripheral, BLEReconnectState)> {
        return Observable.create { observer in
            self.base.onReconnectPhase { peripheral, state in
                observer.onNext((peripheral, state))
            }
            return Disposables.create { }
        }.asObservable()
    }
    
    // MARK: 数据更新
    func dataReceived() -> Observable<BLECharValueUpdateResult> {
        return Observable.create { observer in
            self.base.setOnDataReceived { result in
                observer.onNext(result)
            }
            return Disposables.create { }
        }.asObservable()
    }
    
    // MARK: 写指令
    /// 写入指令超时
    func writeTimeout() -> Observable<BLEWriteData> {
        return Observable.create { observer in
            self.base.setWriteTimeoutHandle { data in
                observer.onNext(data)
            }
            return Disposables.create { }
        }.asObservable()
    }
}
