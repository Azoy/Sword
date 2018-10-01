//
//  GatewayHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Gateway Handler
extension Shard {

  /**
   Handles all gateway events (except op: 0)

   - parameter payload: Payload sent with event
   */
  func handleGateway(_ payload: Payload) {
    
    guard let op = OP(rawValue: payload.op) else {
      self.sword.log(
        "Received unknown gateway\nOP: \(payload.op)\nData: \(payload.d)"
      )
      return
    }
    
    switch op {

    /// OP: 1
    case .heartbeat:
      self.send(self.heartbeatPayload.encode())

    /// OP: 11
    case .heartbeatACK:
      self.wasAcked = true

    /// OP: 10
    case .hello:
      self.heartbeat(at: (payload.d as! [String: Any])["heartbeat_interval"] as! Int)

      guard !self.isReconnecting else {
        self.isReconnecting = false
        let data: [String: Any] = [
          "token": self.sword.token,
          "session_id": self.sessionId!,
          "seq": self.lastSeq ?? NSNull()
        ]
          
        let payload = Payload(op: .resume, data: data)

        self.send(payload.encode())
        return
      }

      self.identify()

    /// OP: 9
    case .invalidSession:
      self.isReconnecting = payload.d as! Bool
      self.reconnect()

    /// OP: 7
    case .reconnect:
      self.isReconnecting = true
      self.reconnect()

    /// Others~~~
    default:
      break
    }

  }

}
