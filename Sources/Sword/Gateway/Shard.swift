//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

#if !os(Linux)
import Starscream
#else
import WebSockets
#endif

/// WS class
class Shard: Gateway {

  // MARK: Properties

  /// Gateway URL for gateway
  var gatewayUrl = ""

  /// Global Event Rate Limiter
  let globalBucket: Bucket

  /// Heartbeat worker
  var heartbeat: Heartbeat?

  /// ID of shard
  let id: Int

  /// Whether or not the shard is connected to gateway
  var isConnected = false

  /// The last sequence sent by Discord
  var lastSeq: Int?

  /// Presence Event Rate Limiter
  let presenceBucket: Bucket

  /// Whether or not the shard is reconnecting
  var isReconnecting = false

  /// WS
  var session: WebSocket?

  /// Session ID of gateway
  var sessionId: String?

  /// Amount of shards bot should be connected to
  let shardCount: Int

  /// Parent class
  unowned let sword: Sword

  // MARK: Initializer

  /**
   Creates Shard Handler

   - parameter sword: Parent class
   - parameter id: ID of the current shard
   - parameter shardCount: Total number of shards bot needs to be connected to
  */
  init(_ sword: Sword, _ id: Int, _ shardCount: Int, _ gatewayUrl: String) {
    self.sword = sword
    self.id = id
    self.shardCount = shardCount
    self.gatewayUrl = gatewayUrl

    self.globalBucket = Bucket(
      name: "me.azoy.sword.gateway.global",
      limit: 120,
      interval: 60
    )

    self.presenceBucket = Bucket(
      name: "me.azoy.sword.gateway.presence",
      limit: 5,
      interval: 60
    )
  }

  // MARK: Functions

  /**
   Handles gateway events from WS connection with Discord

   - parameter payload: Payload struct that Discord sent as JSON
  */
  func handlePayload(_ payload: Payload) {
    if let sequenceNumber = payload.s {
      self.heartbeat?.sequence = sequenceNumber
      self.lastSeq = sequenceNumber
    }

    guard payload.t != nil else {
      self.handleGateway(payload)
      return
    }

    guard payload.d is [String: Any] else {
      return
    }
    
    self.handleEvent(payload.d as! [String: Any], payload.t!)
    self.sword.emit(.payload, with: payload.encode())
  }
  
  /**
   Handles gateway disconnects
   
   - parameter code: Close code for the gateway closing
  */
  func handleDisconnect(for code: Int) {
    self.isReconnecting = true
    
    self.sword.emit(.disconnect, with: self.id)
    
    guard let closeCode = CloseOP(rawValue: code) else {
      self.sword.log("Connection closed with unrecognized response \(code).")

      self.reconnect()

      return
    }

    switch closeCode {
      case .authenticationFailed:
        print("[Sword] Invalid Bot Token")

      case .invalidShard:
        print("[Sword] Invalid Shard (We messed up here. Try again.)")

      case .noInternet:
        self.sword.globalQueue.asyncAfter(
          deadline: DispatchTime.now() + .seconds(10)
        ) { [unowned self] in
          self.sword.warn("Detected a loss of internet...")
          self.reconnect()
        }
      
      case .shardingRequired:
        print("[Sword] Sharding is required for this bot to run correctly.")

      default:
        self.reconnect()
    }
  }

  /// Sends shard identity to WS connection
  func identify() {
    #if os(macOS)
    let osName = "macOS"
    #elseif os(Linux)
    let osName = "Linux"
    #elseif os(iOS)
    let osName = "iOS"
    #elseif os(watchOS)
    let osName = "watchOS"
    #elseif os(tvOS)
    let osName = "tvOS"
    #endif

    var data: [String: Any] = [
      "token": self.sword.token,
      "properties": [
        "$os": osName,
        "$browser": "Sword",
        "$device": "Sword"
      ],
      "compress": false,
      "large_threshold": 250,
      "shard": [
        self.id, self.shardCount
      ]
    ]
    
    if let presence = self.sword.presence {
      data["presence"] = presence
    }
    
    let identity = Payload(
      op: .identify,
      data: data
    ).encode()

    self.send(identity)
  }

  #if os(macOS) || os(Linux)

  /**
   Sends a payload to socket telling it we want to join a voice channel

   - parameter channelId: Channel to join
   - parameter guildId: Guild that the channel belongs to
  */
  func joinVoiceChannel(_ channelId: Snowflake, in guildId: Snowflake) {
    let payload = Payload(
      op: .voiceStateUpdate,
      data: [
        "guild_id": guildId.description,
        "channel_id": channelId.description,
        "self_mute": false,
        "self_deaf": false
      ]
    ).encode()

    self.send(payload)
  }

  /**
   Sends a payload to socket telling it we want to leave a voice channel

   - parameter guildId: Guild we want to remove bot from
  */
  func leaveVoiceChannel(in guildId: Snowflake) {
    let payload = Payload(
      op: .voiceStateUpdate,
      data: [
        "guild_id": guildId.description,
        "channel_id": NSNull(),
        "self_mute": false,
        "self_deaf": false
      ]
    ).encode()

    self.send(payload)
  }

  #endif

  /// Used to reconnect to gateway
  func reconnect() {
    #if !os(Linux)
    if let isOn = self.session?.isConnected, isOn {
      self.session?.disconnect()
    }
    #else
    if let isOn = self.session?.state, isOn == .open {
        try? self.session?.close()
    }
    #endif
    
    self.isConnected = false
    self.heartbeat = nil
    
    self.sword.log("Disconnected from gateway... Resuming session")
    
    self.start()
  }

  /// Function to send packet to server to request for offline members for requested guild
  func requestOfflineMembers(for guildId: Snowflake) {
    let payload = Payload(
      op: .requestGuildMember,
      data: [
        "guild_id": guildId.description,
        "query": "",
        "limit": 0
      ]
    ).encode()

    self.send(payload)
  }

  /**
   Sends a payload through WS connection

   - parameter text: JSON text to send through WS connection
   - parameter presence: Whether or not this WS payload updates shard presence
  */
  func send(_ text: String, presence: Bool = false) {
    let item = DispatchWorkItem { [unowned self] in
      #if !os(Linux)
      self.session?.write(string: text)
      #else
      try? self.session?.send(text)
      #endif
    }

    presence ? self.presenceBucket.queue(item) : self.globalBucket.queue(item)
  }

  /// Used to stop WS connection
  func stop() {
    #if !os(Linux)
    self.session?.disconnect()
    #else
    try? self.session?.close()
    #endif
    
    self.heartbeat = nil
    self.isConnected = false
    self.isReconnecting = false

    self.sword.log("Stopping gateway connection...")
  }

}
