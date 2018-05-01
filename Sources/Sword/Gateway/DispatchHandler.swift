//
//  DispatchHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import WebSocket

extension Shard {
  /// Operates on a given dispatch payload
  ///
  /// - parameter payload: Payload received from gateway
  /// - parameter ws: WebSocket session
  func handleDispatch(_ payload: Payload<JSON>, with ws: WebSocket) {
    // Make sure event data is actual data we can use
    guard case let .dictionary(data) = payload.d else {
      Sword.log(.warning, "Was expecting a JSON object while handling dispatch event")
      return
    }
    
    // Make sure we got an event name
    guard let t = payload.t else {
      Sword.log(.warning, "Received dispatch payload without event name")
      return
    }
    
    // Make sure we can handle this event
    guard let event = Event(rawValue: t) else {
      Sword.log(.warning, "Received unknown dispatch event: \(t)")
      return
    }
    
    // Handle the event
    switch event {
    // READY
    case .ready:
      // Make sure version we're connected to is the same as the version we requested
      guard let v = data["v"]?.int, v == Sword.gatewayVersion else {
        Sword.log(.error, "Shard \(id) connected to wrong version of the gateway")
        disconnect()
        return
      }
      
      // Make sure we got a session id for resuming
      guard let sessionId = data["session_id"]?.string else {
        Sword.log(.error, "Shard \(id) did not receive a session id after READY")
        disconnect()
        return
      }
      
      self.sessionId = sessionId
      let user = User(data)
      sword?.user = user
      
      /// Append _trace
      addTrace(from: payload.d)
    }
  }
}
