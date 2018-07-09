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
  func handlePayload(
    _ payload: PayloadSinData,
    with ws: WebSocket,
    _ data: Data
  ) {
    switch payload.op {
    // Dispatch (OP = 0)
    case .dispatch:
      lastSeq = payload.s
      handleDispatch(payload, with: ws, data)
      
    // Heartbeat (OP = 1)
    case .heartbeat:
      ackMissed -= 1
      send(heartbeatPayload, through: ws)
      
    // Invalid session (OP = 9)
    case .invalidSession:
      guard let canReconnect = decodePayload(Bool.self, from: data) else {
        Sword.log(.warning, "Unable to handle invalid session, reconnecting...")
        sessionId = nil
        reconnect()
        return
      }
      
      if !canReconnect {
        sessionId = nil
      }
      
      reconnect()
      
    // HELLO (OP = 10)
    case .hello:
      guard let hello = decodePayload(GatewayHello.self, from: data) else {
        Sword.log(.error, "Unable to handle HELLO, shutting shard down...")
        disconnect()
        return
      }
      
      // Start heartbeating
      heartbeat(to: hello.heartbeatInterval, on: ws)
      
      if !isReconnecting {
        // Identify
        identify(on: ws)
      }
      
      /// Append _trace
      addTrace(from: hello)
      
    // Heartbeat Acknowledgement (OP = 11)
    case .ack:
      ackMissed -= 1

    // Unhandled
    default:
      Sword.log(.warning, .unhandledEvent(id, payload.op.rawValue))
    }
  }
}
