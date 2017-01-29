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

    switch OPCode(rawValue: payload.op)! {

      /// OP: 11
      case .heartbeatACK:
        self.heartbeat?.received = true
        break

      /// OP: 10
      case .hello:
        self.heartbeat = Heartbeat(self.session!, "heartbeat.shard.\(self.id)",interval: (payload.d as! [String: Any])["heartbeat_interval"] as! Int)
        self.heartbeat?.received = true
        self.heartbeat?.send()
        self.identify()
        break

      /// OP: 9
      case .invalidSession:
        self.stop()
        sleep(2)
        self.startWS(self.gatewayUrl)
        break

      /// OP: 7
      case .reconnect:
        var data: [String: Any] = ["token": self.sword.token, "session_id": self.sessionId!, "seq": NSNull()]
        if self.lastSeq != nil {
          data.updateValue(self.lastSeq!, forKey: "seq")
        }
        let payload = Payload(op: .resume, data: data)
        self.reconnect(payload)
        break

      /// Others~~~
      default:
        break
    }

  }

}
