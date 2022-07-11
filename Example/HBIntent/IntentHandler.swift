//
//  IntentHandler.swift
//  HBIntent
//
//  Created by abc on 2022/7/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    // 这是默认实现。 如果您希望不同的对象处理不同的意图，
    // 你可以覆盖它并返回你想要的特定意图的处理程序。
    // 是整个 Intents Extension 的入口，当 siri 通过语音指令匹配到对于的 Intent , 该方法就会被执行。
    override func handler(for intent: INIntent) -> Any {
        // 这里我 return 我创建一个 HBEventIntent 类，该类准守 INExtension, HBEventIntentHandling协议。
        // 用来处理匹配到 Intent 后的 UI 显示以及后续操作
        if intent is HBEventIntent {
            return HBEventHandler()
        }
        return self
    }
}
