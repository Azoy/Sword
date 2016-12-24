//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation
import WebSockets

/// WS class
class Shard {

  // MARK: Properties
  
  /// ID of shard
  let id: Int
  
  /// Amount of shards bot should be connected to
  let shardCount: Int
  
  /// Session ID of gateway
  var sessionId: String?
  
  /// Heartbeat worker
  var heartbeat: Heartbeat?

  /// Gateway URL for gateway
  var gatewayUrl = ""
  
  /// WS
  var session: WebSocket?
  
  /// Parent class
  let sword: Sword
  
  /// Global Event Rate Limiter
  let globalBucket: Bucket
  
  /// Presence Event Rate Limiter
  let presenceBucket: Bucket

  /// Whether or not the shard is connected to gateway
  var connected: Bool = false
  
  /// The last sequence sent by Discord
  var lastSeq: Int?

  // MARK: Initializer
  
  /**
   Creates Shard Handler
   
   - parameter sword: Parent class
   - parameter id: ID of the current shard
   - parameter shardCount: Total number of shards bot needs to be connected to
  */
  init(_ sword: Sword, _ id: Int, _ shardCount: Int) {
    self.sword = sword
    self.id = id
    self.shardCount = shardCount

    self.globalBucket = Bucket(name: "gg.azoy.sword.gateway.global", limit: 120, interval: 60)
    self.presenceBucket = Bucket(name: "gg.azoy.sword.gateway.presence", limit: 5, interval: 60)
  }

  // MARK: Functions
  
  /**
   Starts WS connection with Discord
   
   - parameter gatewayUrl: URL that WS should connect to
  */
  func startWS(_ gatewayUrl: String, reconnect: Bool = false, reconnectPayload: String? = nil) {
    self.gatewayUrl = gatewayUrl

    try? WebSocket.connect(to: gatewayUrl) { ws in
      self.session = ws
      self.connected = true

      if reconnect {
        self.send(reconnectPayload!)
      }

      ws.onText = { ws, text in
        self.event(Payload(with: text))
      }

      ws.onClose = { ws, code, _, _ in
        self.connected = false
        switch CloseCode(rawValue: Int(code!))! {
          case .authenticationFailed:
            print("[Sword] - Invalid Bot Token")
            break
          default:
            self.startWS(gatewayUrl)
            break
        }
      }
    }
  }

  /**
   Used to reconnect to gateway
   
   - parameter payload: Reconnect payload to send to connection
  */
  func reconnect(_ payload: Payload) {
    try? self.session!.close()
    self.connected = false
    self.heartbeat = nil

    self.startWS(self.gatewayUrl, reconnect: true, reconnectPayload: payload.encode())
  }

  /// Used to stop WS connection
  func stop() {
    try? self.session!.close()
    self.connected = false
    self.heartbeat = nil
  }

  /**
   Sends a payload through WS connection
   
   - parameter text: JSON text to send through WS connection
   - parameter presence: Whether or not this WS payload updates shard presence
  */
  func send(_ text: String, presence: Bool = false) {
    let item = DispatchWorkItem {
      try? self.session!.send(text)
    }
    presence ? self.presenceBucket.queue(item) : self.globalBucket.queue(item)
  }

  /// Sends shard identity to WS connection
  func identify() {
    #if os(macOS)
    let os = "macOS"
    #else
    let os = "Linux"
    #endif
    let identity = Payload(op: .identify, data: ["token": self.sword.token, "properties": ["$os": os, "$browser": "Sword", "$device": "Sword"], "compress": false, "large_threshold": 50, "shard": [self.id, self.shardCount]]).encode()

    try? self.session?.send(identity)
  }

  /**
   Handles gateway events from WS connection with Discord
   
   - parameter payload: Payload struct that Discord sent as JSON
  */
  func event(_ payload: Payload) {
    if let sequenceNumber = payload.s {
      self.heartbeat?.sequence = sequenceNumber
      self.lastSeq = sequenceNumber
    }

    guard payload.t != nil else {
      self.handleGateway(payload)
      return
    }

    self.handleEvents(payload.d as! [String: Any], payload.t!)
  }

}
