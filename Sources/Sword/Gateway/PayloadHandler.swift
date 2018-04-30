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
      guard let heartbeatMS = payload.d["heartbeat_interval"]?.int else {
        Sword.log(
          .error,
          "Did not receive heartbeat_interval during hello"
        )
        return
      }
      
      //heartbeat(to: heartbeatMS, on: ws)
      identify(from: payload, on: ws)
      
      /// Append _trace
      if let _trace = payload.d["_trace"], case let .array(traces) = _trace {
        for trace in traces {
          guard let traceString = trace.string else {
            Sword.log(.warning, "Received a deformed trace: \(trace)")
            return
          }
          
          self.trace.append(traceString)
        }
      } else {
        Sword.log(.warning, "Did not receive _trace during hello")
      }
      
    // Heartbeat Acknowledgement (OP = 11)
    case .ack:
      print("Received heartbeat ack")
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
