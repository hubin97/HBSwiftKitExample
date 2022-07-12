//
//  HBDonateHandler.swift
//  HBIntent
//
//  Created by Hubin_Huang on 2022/7/12.
//  Copyright © 2020 云图数字. All rights reserved.

import Foundation
import Intents
// MARK: - global var and methods

// MARK: - main class
class HBDonateHandler: INExtension, HBDonateIntentHandling {
    func handle(intent: HBDonateIntent, completion: @escaping (HBDonateIntentResponse) -> Void) {
        self.exeuteFast(intent.sid) { response in
            completion(response)
        }
    }
}

// MARK: - private mothods
extension HBDonateHandler {
    
    func exeuteFast(_ sid: String?, completeHandle: @escaping ((_ response: HBDonateIntentResponse) -> Void)) {
        // 此处为业务逻辑代码, 根据业务需求而定
        let errorCode = "0"
        if errorCode == "0" {
            let rsp = self.setUpSiriIntentResponse(title: "场景执行成功!", code: .success)
            completeHandle(rsp)
        } else { // "{\"errorCode\":\"701\",\"errorMsg\":\"该情景不存在\",\"transNo\":\"0df0b55de76dbd00\"}"
            let rsp = self.setUpSiriIntentResponse(title: "执行失败: #errorMsg#", code: .failure)
            completeHandle(rsp)
        }
    }
    
    /// 构建返回意图响应
    /// - Parameters:
    ///   - title: 标题
    ///   - code: 状态码
    /// - Returns: response
    func setUpSiriIntentResponse(title: String?, code: HBDonateIntentResponseCode) -> HBDonateIntentResponse {
        let response = HBDonateIntentResponse(code: code, userActivity: nil)
        response.title = title
        return response
    }
}

// MARK: - call backs
extension HBDonateHandler { 
}

// MARK: - delegate or data source
extension HBDonateHandler { 
}

// MARK: - other classes
