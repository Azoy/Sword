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
    guard let data = payload.d.dict else {
      Sword.log(.warning, .dispatchJSON)
      return
    }
    
    // Make sure we got an event name
    guard let t = payload.t else {
      Sword.log(.warning, .dispatchName(id))
      return
    }
    
    // Make sure we can handle this event
    guard let event = Event(rawValue: t) else {
      Sword.log(.warning, .unknownEvent(t))
      return
    }
    
    // Handle the event
    switch event {
    // READY
    case .ready:
      // Make sure version we're connected to is the same as the version we requested
      guard let v = data.v?.int, v == Sword.gatewayVersion else {
        Sword.log(.error, .invalidVersion(id))
        disconnect()
        return
      }
      
      // Make sure we got a session id for resuming
      guard let sessionId = data.session_id?.string else {
        Sword.log(.error, .missing(id, "session_id", "READY"))
        disconnect()
        return
      }
      
      self.sessionId = sessionId
      
      // Make sure we got the bot's user object
      guard let userData = data.user?.dict else {
        Sword.log(.error, .missing(id, "user", "READY"))
        disconnect()
        return
      }
      
      let user = User(userData)
      sword?.user = user
      
      /// Append _trace
      addTrace(from: payload.d)
      
      // Make sure there wasn't a problem in creating the user so we can emit
      guard let userEmit = user else {
        return
      }
      
      sword?.emitReady(userEmit)
      
    case .resumed:
      /// Append _trace
      addTrace(from: payload.d)
      
      isReconnecting = false
      
    default:
      break
    }
  }
}
