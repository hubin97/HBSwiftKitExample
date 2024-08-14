//
//  MQTTTestController.swift
//  HBSwiftKit_Example
//
//  Created by hubin.h on 2024/7/24.
//  Copyright © 2020 路特创新. All rights reserved.

import Foundation
import CocoaMQTT

// MARK: - global var and methods

// MARK: - main class
class MQTTTestController: BaseViewController {
    
    let topic = "/will"
    let defaultHost = "broker.emqx.io"

    lazy var mqttClient: MQTTClient = MQTTClient(host: defaultHost, port: 1883)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "cocoaMQTT5"
        
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        let mqtt5 = CocoaMQTT5(clientID: clientID, host: "broker.emqx.io", port: 1883)

        let connectProperties = MqttConnectProperties()
        connectProperties.topicAliasMaximum = 0
        connectProperties.sessionExpiryInterval = 0
        connectProperties.receiveMaximum = 100
        connectProperties.maximumPacketSize = 500
        mqtt5.connectProperties = connectProperties

        mqtt5.username = "test"
        mqtt5.password = "public"
        //mqtt5.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt5.keepAlive = 60
        //mqtt5.delegate = self
        mqtt5.connect()
        
        mqtt5.didConnectAck = { mqtt5, code, ack in
            print("didConnectAck: \(code)")
        }
        mqtt5.didDisconnect = { mqtt5, error in
            print("didDisconnect: \(error?.localizedDescription ?? "")")
        }
        mqtt5.didReceiveMessage = { mqtt5, message, result, publish in
            print("didReceiveMessage: \(message)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        mqttClient.connect()
//        mqttClient.subscribe(to: topic)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mqttClient.disconnect()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 也可以使用 `publish(topic, withData: messageData, qos: .qos1)`
        //mqtt.publish("/will1", withString: "CocoaMQTT5Message", qos: .qos1, properties: MqttPublishProperties())
        mqttClient.publish(message: "CocoaMQTT5Message", to: "/will1")
    }
}

// MARK: - private mothods
extension MQTTTestController { 
    
    func connect() {
        mqttClient.connect()
    }
}

// MARK: - call backs
extension MQTTTestController { 
}
