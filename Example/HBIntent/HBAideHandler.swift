//
//  HBAideHandler.swift
//  HBIntent
//
//  Created by Hubin_Huang on 2022/7/11.
//  Copyright © 2020 云图数字. All rights reserved.

/**
 #1. 关于Siri
 Dear Developer,
 We identified one or more issues with a recent delivery for your app, "APP" 2.5.3 (1). Please correct the following issues, then upload again.
 ITMS-90626: Invalid Siri Support - Custom intent title 'APP Siri' cannot contain 'siri'
 ITMS-90626: Invalid Siri Support - Custom intent subtitle 'Siri cmd' cannot contain 'siri'
 Best regards,
 The App Store Team
 */
import Intents

// MARK: - global var and methods

// MARK: - main class
class HBAideHandler: INExtension, HBAideIntentHandling {
    func handle(intent: HBAideIntent, completion: @escaping (HBAideIntentResponse) -> Void) {
        self.exeuteFast(intent.sid) { response in
            completion(response)
        }
    }
    // func handle(intent: HBAideIntent) async -> HBAideIntentResponse {}
}

// MARK: - private mothods
extension HBAideHandler {
    
    func exeuteFast(_ sid: String?, completeHandle: @escaping ((_ response: HBAideIntentResponse) -> Void)) {
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
    func setUpSiriIntentResponse(title: String?, code: HBAideIntentResponseCode) -> HBAideIntentResponse {
        let response = HBAideIntentResponse(code: code, userActivity: nil)
        response.title = title
        return response
    }
}

// MARK: - call backs
extension HBAideHandler {
}

// MARK: - delegate or data source
extension HBAideHandler {
}

// MARK: - other classes
