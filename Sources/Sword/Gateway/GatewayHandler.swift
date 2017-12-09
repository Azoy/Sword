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
      self.heartbeat?.received = true
      let heartbeat = Payload(
        op: .heartbeat,
        data: self.lastSeq ?? NSNull()
      ).encode()
      self.send(heartbeat)

    /// OP: 11
    case .heartbeatACK:
      self.heartbeat?.received = true

    /// OP: 10
    case .hello:
      self.heartbeat = Heartbeat(
        self,
        "heartbeat.shard.\(self.id)",
        interval: (payload.d as! [String: Any])["heartbeat_interval"] as! Int
      )
      self.heartbeat?.received = true
      self.heartbeat?.send()

      guard !self.isReconnecting else {
        self.isReconnecting = false
        var data: [String: Any] = [
          "token": self.sword.token,
          "session_id": self.sessionId!,
          "seq": NSNull()
        ]
          
        if let lastSeq = self.lastSeq {
          data["seq"] = lastSeq
        }
          
        let payload = Payload(
          op: .resume,
          data: data
        ).encode()

        self.send(payload)
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
