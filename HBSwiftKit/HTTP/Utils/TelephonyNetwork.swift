//
//  TelephonyNetwork.swift
//  Momcozy
//
//  Created by hubin.h on 2024/9/10.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CoreTelephony

// MARK: - global var and methods

// MARK: - main class
public struct TelephonyNetwork {
    
    /// 获取运营商名称
    public static var carrierName: String {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value.carrierName {
            return carrier
        } else {
            return "Unknown"
        }
    }
    
    /// 获取蜂窝网络类型
    public static var cellularNetworkType: String {
        let networkInfo = CTTelephonyNetworkInfo()
        // 获取所有服务的当前无线接入技术
        let radioAccessTechnologies = networkInfo.serviceCurrentRadioAccessTechnology
        // 只处理第一个可用的服务
        if let currentRadioAccessTechnology = radioAccessTechnologies?.values.first {
            switch currentRadioAccessTechnology {
            case CTRadioAccessTechnologyGPRS:
                return "2G"
            case CTRadioAccessTechnologyEdge:
                return "2.5G"
            case CTRadioAccessTechnologyWCDMA:
                return "3G"
            case CTRadioAccessTechnologyHSDPA:
                return "3.5G"
            case CTRadioAccessTechnologyHSUPA:
                return "3.5G"
            case CTRadioAccessTechnologyCDMA1x:
                return "2G"
            case CTRadioAccessTechnologyCDMAEVDORev0:
                return "3G"
            case CTRadioAccessTechnologyCDMAEVDORevA:
                return "3G"
            case CTRadioAccessTechnologyCDMAEVDORevB:
                return "3G"
            case CTRadioAccessTechnologyLTE:
                return "4G"
            default:
                // 检查是否在 iOS 14.1 或更高版本中
                if #available(iOS 14.1, *), currentRadioAccessTechnology == CTRadioAccessTechnologyNRNSA || currentRadioAccessTechnology == CTRadioAccessTechnologyNR {
                    return "5G"
                }
                return "Unknown"
            }
        } else {
            return "No cellular connection"
        }
    }
}
