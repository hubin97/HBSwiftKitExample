//
//  HBEventHandler.swift
//  HBIntent
//
//  Created by Hubin_Huang on 2022/7/8.
//  Copyright © 2020 云图数字. All rights reserved.

import Intents
import IntentsUI

// MARK: - main class
class HBEventHandler: INExtension, HBEventIntentHandling {
    
//    func confirm(intent: HBEventIntent, completion: @escaping (HBEventIntentResponse) -> Void) {
//        let userActivity = NSUserActivity(activityType: NSStringFromClass(HBEventIntent.self))
//        let response = HBEventIntentResponse.init(code: .ready, userActivity: userActivity)
//        completion(response)
//    }

    func handle(intent: HBEventIntent, completion: @escaping (HBEventIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(HBEventIntent.self))
        let response = HBEventIntentResponse.init(code: .success, userActivity: userActivity)
        completion(response)
    }
}

// MARK: - private mothods
extension HBEventHandler { 
}

// MARK: - call backs
extension HBEventHandler { 
}

// MARK: - delegate or data source
extension HBEventHandler { 
}

// MARK: - other classes
