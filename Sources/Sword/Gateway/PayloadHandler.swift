//
//  PayloadHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import WebSocket

extension Shard {
  /// Operates on a given received payload
  ///
  /// - parameter payload: Received payload from gateway
  /// - parameter ws: WebSocket session
  func handlePayload(_ payload: Payload<JSON>, with ws: WebSocket) {
    switch payload.op {
    // Dispatch (OP = 0)
    case .dispatch:
      lastSeq = payload.s
      handleDispatch(payload, with: ws)
      
    // Heartbeat (OP = 1)
    case .heartbeat:
      ackMissed -= 1
      send(heartbeatPayload, through: ws)
      
    // Invalid session (OP = 9)
    case .invalidSession:
      if let canResume = payload.d.bool, !canResume {
        sessionId = nil
      }
      
      reconnect()
      
    // HELLO (OP = 10)
    case .hello:
      guard let heartbeatMS = payload.d.heartbeat_interval?.int else {
        Sword.log(.error, .missing(id, "heartbeat_interval", "HELLO"))
        return
      }
      
      // Start heartbeating
      heartbeat(to: heartbeatMS, on: ws)
      
      if !isReconnecting {
        // Identify
        identify(from: payload, on: ws)
      }
      
      /// Append _trace
      addTrace(from: payload.d)
      
    // Heartbeat Acknowledgement (OP = 11)
    case .ack:
      ackMissed -= 1

    // Unhandled
    default:
      Sword.log(.warning, .unhandledEvent(id, payload.op.rawValue))
    }
  }
}
