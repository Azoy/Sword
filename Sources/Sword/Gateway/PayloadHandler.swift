//
//  PayloadHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Shard {
  /// Operates on a given received payload
  ///
  /// - parameter payload: Received payload from gateway
  /// - parameter ws: WebSocket session
  func handlePayload(
    _ payload: PayloadSinData,
    _ data: Data
  ) {
    switch payload.op {
    // Dispatch (OP = 0)
    case .dispatch:
      lastSeq = payload.s
      handleDispatch(payload, data)
      
    // Heartbeat (OP = 1)
    case .heartbeat:
      ackMissed -= 1
      send(heartbeatPayload)
      
    // Invalid session (OP = 9)
    case .invalidSession:
      guard let canReconnect = decode(Bool.self, from: data) else {
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
      guard let hello = decode(GatewayHello.self, from: data) else {
        Sword.log(.error, "Unable to handle HELLO, shutting shard down...")
        disconnect()
        return
      }
      
      // Start heartbeating
      heartbeat(to: hello.heartbeatInterval)
      
      // Make sure we had a session before
      guard isReconnecting, let sessionId = sessionId, let seq = lastSeq else {
        identify()
        return
      }
      
      // Attempt to resume
      let resume = GatewayResume(
        token: sword.token,
        sessionId: sessionId,
        seq: seq
      )
      
      let payload = Payload(d: resume, op: .resume, s: nil, t: nil)
      send(payload)
      
    // Heartbeat Acknowledgement (OP = 11)
    case .ack:
      ackMissed -= 1

    // Unhandled
    default:
      Sword.log(.warning, .unhandledEvent(id, payload.op.rawValue))
    }
  }
}
