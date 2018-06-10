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
      send(heartbeatPayload, through: ws)
      
    // HELLO (OP = 10)
    case .hello:
      guard let heartbeatMS = payload.d.heartbeat_interval?.int else {
        Sword.log(
          .error,
          "Did not receive heartbeat_interval during hello"
        )
        return
      }
      
      // Start heartbeating
      heartbeat(to: heartbeatMS, on: ws)
      
      // Identify
      identify(from: payload, on: ws)
      
      /// Append _trace
      addTrace(from: payload.d)
      
    // Heartbeat Acknowledgement (OP = 11)
    case .ack:
      ackMissed -= 1

    // Unhandled
    default:
      Sword.log(
        .warning,
        "Received unhandled payload event: \(payload)"
      )
    }
  }
}
