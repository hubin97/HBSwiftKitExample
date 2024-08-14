//
//  MQTTClient.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/7/29.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CocoaMQTT

//    MQTT5 比 MQTT3.1.1 增加了一些新特性，比如：
//
//    会话保持：用于持久化会话状态。
//    遗嘱消息：用于客户端异常断开时的消息处理。
//    用户属性和服务器响应代码：用于更多的控制和调试。

// MARK: - main class
class MQTTClient: NSObject {
    
    private var mqttClient: CocoaMQTT5
    
    /// 连接属性
    lazy var connectProperties: MqttConnectProperties = {
        let _connectProperties = MqttConnectProperties()
        _connectProperties.topicAliasMaximum = 0
        _connectProperties.sessionExpiryInterval = 0
        _connectProperties.receiveMaximum = 100
        _connectProperties.maximumPacketSize = 500
        return _connectProperties
    }()
    
    /// 发布属性
    lazy var publishProperties: MqttPublishProperties = {
        let _publishProperties = MqttPublishProperties()
        _publishProperties.contentType = "JSON"
        return _publishProperties
    }()
    
    lazy var lastWillMessage: CocoaMQTT5Message = {
        let _lastWillMessage = CocoaMQTT5Message(topic: "/will", string: "dieout")
        _lastWillMessage.contentType = "JSON"
        _lastWillMessage.willExpiryInterval = .max
        _lastWillMessage.willDelayInterval = 0
        _lastWillMessage.qos = .qos1
        return _lastWillMessage
    }()
    
    init(host: String, port: UInt16) {
        let clientID = "CocoaMQTT-MQTTClient-" + String(ProcessInfo().processIdentifier)
        self.mqttClient = CocoaMQTT5(clientID: clientID, host: host, port: port)
        super.init()
        self.mqttClient.delegate = self
        self.mqttClient.logLevel = .debug
        //self.mqttClient.keepAlive = 10
        //self.mqttClient.connectProperties = connectProperties
        //self.mqttClient.willMessage = lastWillMessage
    }
}

// MARK: - private mothods
extension MQTTClient {
    
    func connect() {
        _ = mqttClient.connect()
    }
    
    func disconnect() {
        mqttClient.disconnect()
    }
    
    func subscribe(to topic: String) {
        mqttClient.subscribe(topic)
    }
    
    func publish(message: String, qos: CocoaMQTTQoS = .qos1, to topic: String) {
        mqttClient.publish(topic, withString: message, qos: qos, properties: publishProperties)
    }
}

// MARK: - delegate or data source
extension MQTTClient: CocoaMQTT5Delegate {
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didConnectAck ack: CocoaMQTTCONNACKReasonCode, connAckData: MqttDecodeConnAck?) {
        print("Connected with ack: \(ack)")
    }
    
    func mqtt5DidDisconnect(_ mqtt5: CocoaMQTT5, withError err: (any Error)?) {
        print("Disconnected with error: \(String(describing: err))")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveMessage message: CocoaMQTT5Message, id: UInt16, publishData: MqttDecodePublish?) {
        print("didReceiveMessage: \(message.string ?? "") on topic: \(message.topic) publishData:\(publishData ?? MqttDecodePublish())")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishMessage message: CocoaMQTT5Message, id: UInt16) {
        print("didPublishMessage message: \(message.string ?? "") on topic: \(message.topic)")
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didSubscribeTopics success: NSDictionary, failed: [String], subAckData: MqttDecodeSubAck?) {
        
    }
    
    // MARK: - other
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishAck id: UInt16, pubAckData: MqttDecodePubAck?) {
        
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didPublishRec id: UInt16, pubRecData: MqttDecodePubRec?) {
        
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didUnsubscribeTopics topics: [String], unsubAckData: MqttDecodeUnsubAck?) {
        
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveDisconnectReasonCode reasonCode: CocoaMQTTDISCONNECTReasonCode) {
        
    }
    
    func mqtt5(_ mqtt5: CocoaMQTT5, didReceiveAuthReasonCode reasonCode: CocoaMQTTAUTHReasonCode) {
        
    }
    
    func mqtt5DidPing(_ mqtt5: CocoaMQTT5) {
        
    }
    
    func mqtt5DidReceivePong(_ mqtt5: CocoaMQTT5) {
        
    }
}
