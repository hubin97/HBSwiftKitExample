//
//  EventBus.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/12/23.

import Foundation

// 定义通用的事件协议
protocol Event {
//    associatedtype EventType  // 让事件类型成为关联类型
//    var type: EventType { get }
}

// 定义事件总线
class EventBus {
    static let shared = EventBus()
    
    private var events = [String: [(Any) -> Void]]()

    // 注册事件监听
    func on<T: Event>(event: T.Type, listener: @escaping (T) -> Void) {
        let eventName = String(describing: T.self)
        
        if events[eventName] == nil {
            events[eventName] = []
        }
        
        // 添加监听器
        events[eventName]?.append({ event in
            if let event = event as? T {
                listener(event)
            }
        })
    }

    // 触发事件
    func post<T: Event>(event: T) {
        let eventName = String(describing: T.self)
        events[eventName]?.forEach { listener in
            listener(event)
        }
    }

    // 移除事件监听
    func removeListener(forEvent event: Event.Type) {
        let eventName = String(describing: event)
        events[eventName] = nil
    }
}
