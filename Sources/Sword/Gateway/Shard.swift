//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import WebSocket

/// Shard - Represents a unique session to a portion of the guilds a bot is
///         connected to.
class Shard : GatewayHandler {
  /// Number of missed heartbeat acks
  var ackMissed = 0
  
  /// The shard ID
  let id: UInt8
  
  /// The current heartbeat payload
  var heartbeatPayload: Payload<Int?> {
    return Payload(d: lastSeq, op: .heartbeat, s: nil, t: nil)
  }
  
  /// Dispatch queue to manage sending heartbeats
  let heartbeatQueue: DispatchQueue
  
  /// Whether or not the shard is currently trying to reconnect
  var isReconnecting = false
  
  /// The last sequence number for this shard
  var lastSeq: Int?
  
  /// The WebSocket session
  var session: WebSocket?
  
  /// Used to resume connections
  var sessionId: String?
  
  /// The parent class
  weak var sword: Sword?
  
  /// Debugging purposes, array of servers we're connected to
  var trace = [String]()
  
  /// Event loop to handle payloads on
  var worker: Worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  
  /// Instantiates a Shard
  ///
  /// - parameter id: The shard id
  /// - parameter sword: The parent class
  init(id: UInt8, _ sword: Sword?) {
    self.id = id
    self.sword = sword
    self.heartbeatQueue = DispatchQueue(label: "sword.shard.\(id).heartbeat")
  }
  
  /// Handles deinitialization of a shard
  deinit {
    do {
      try worker.syncShutdownGracefully()
    } catch {
      Sword.log(.warning, "Unable to shutdown event loop for shard: \(id).")
    }
  }
  
  /// Adds _trace to current list of _trace
  func addTrace(from json: JSON) {
    if let _trace = json._trace, let traces = _trace.array {
      for trace in traces {
        guard let traceString = trace.string else {
          Sword.log(.warning, "Received a deformed trace: \(trace)")
          return
        }
        
        self.trace.append(traceString)
      }
    } else {
      Sword.log(.warning, .missing(id, "_trace", nil))
    }
  }
  
  /// Handles text being sent through the gateway
  ///
  /// - parameter ws: WebSocket session to prevent cycles
  /// - parameter text: String that was sent through the gateway
  func handleText(_ ws: WebSocket, _ text: String) {
    let data = text.convertToData()
    
    do {
      let payload = try Sword.decoder.decode(Payload<JSON>.self, from: data)
      
      handlePayload(payload, with: ws)
    } catch {
      Sword.log(
        .error,
        "Unable to correctly decode payload data. Error: \(error.localizedDescription)"
      )
    }
  }
  
  /// Handles a sudden gateway close
  ///
  /// - parameter error: The op close code
  func handleClose(_ error: WebSocketErrorCode) {
    if case .normalClosure = error {
      reconnect()
      return
    }
    
    guard case let .unknown(code) = error else {
      Sword.log(.warning, "Received unhandled websocket close code: \(error)")
      return
    }
    
    switch code {
    case 4000 ... 4003, 4005 ... 4009:
      reconnect()
      
    case 4004:
      guard let token = sword?.token else {
        Sword.log(.error, "Shard \(id) has a missing token")
        return
      }
      
      Sword.log(.error, "Shard \(id) has an incorrect token: \(token)")
      
    case 4010:
      Sword.log(.error, "Shard \(id) sent invalid shard information")
      
    case 4011:
      Sword.log(.error, "Shard \(id) has too many guilds, more shards are required")
      
    default:
      break
    }
  }
  
  /// Initiates the heartbeating mode
  func heartbeat(to ms: Int, on ws: WebSocket) {
    guard !ws.isClosed else {
      Sword.log(.warning, "Tried to heartbeat on closed shard \(id)")
      return
    }
    
    guard ackMissed < 3 else {
      Sword.log(
        .error,
        "Shard \(id) has missed 3 heartbeat acks from Discord. Reconnecting..."
      )
      
      reconnect()
      return
    }
    
    ackMissed += 1
    send(heartbeatPayload, through: ws)
    
    heartbeatQueue.asyncAfter(
      deadline: .now() + .milliseconds(ms)
    ) { [weak self, weak ws] in
      guard let this = self else {
        return
      }
      
      guard let ws = ws else {
        return
      }
      
      this.heartbeat(to: ms, on: ws)
    }
  }
  
  /// Sends identify payload
  ///
  /// - parameter payload: Hello payload to identify to
  func identify(from payload: Payload<JSON>, on ws: WebSocket) {
    guard let sword = sword else {
      return
    }
    
    #if os(macOS)
    let os = "macOS"
    #endif
    
    let identify = GatewayIdentify(
      largeThreshold: 50,
      properties: GatewayIdentify.Properties(
        browser: "Sword",
        device: "Sword",
        os: os
      ),
      shard: [id, sword.shardManager.shardCount],
      token: sword.token,
      willCompress: false
    )
    
    let payload = Payload(d: identify, op: .identify, s: nil, t: nil)
    send(payload, through: ws)
  }
  
  /// Reconnects the shard to Discord
  func reconnect() {
    if let session = session, !session.isClosed {
      disconnect()
    }
    
    guard let sword = sword else {
      // Assume the bot is dead somehow and just kill this shard instance
      disconnect()
      return
    }
    
    isReconnecting = true
    
    guard let host = sword.shardManager.shardHosts[id] else {
      // Unable to get host for this shard for some reason, silently kill this
      return
    }
    
    guard let sessionId = sessionId else {
      // There was no session to begin with (?)
      isReconnecting = false
      connect(to: host)
      return
    }
    
    // Get last sequence number before reconnecting, just in case
    let seq = lastSeq
    
    connect(to: host)
    
    guard let session = session else {
      return
    }
    
    let resume = GatewayResume(
      token: sword.token,
      sessionId: sessionId,
      seq: seq
    )
    
    let payload = Payload(d: resume, op: .resume, s: nil, t: nil)
    send(payload, through: session)
  }
  
  /// Sends a payload through a websocket session
  func send<T: Codable>(_ payload: Payload<T>, through ws: WebSocket) {
    do {
      let data = try Sword.encoder.encode(payload)
      ws.send(data.convert(to: String.self))
    } catch {
      Sword.log(
        .warning,
        "Unable to send payload on shard \(id). Error: \(error.localizedDescription)"
      )
    }
  }
}
