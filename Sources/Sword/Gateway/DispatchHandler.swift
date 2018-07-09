//
//  DispatchHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import WebSocket

extension Shard {
  /// Operates on a given dispatch payload
  ///
  /// - parameter payload: Payload received from gateway
  /// - parameter ws: WebSocket session
  func handleDispatch(
    _ payload: PayloadSinData,
    with ws: WebSocket,
    _ data: Data
  ) {
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
      guard let ready = decodePayload(GatewayReady.self, from: data) else {
        Sword.log(.warning, "Unable to handle ready, disconnect")
        disconnect()
        return
      }
      
      // Make sure version we're connected to is the same as the version we requested
      guard ready.version == Sword.gatewayVersion else {
        Sword.log(.error, .invalidVersion(id))
        disconnect()
        return
      }
      
      sessionId = ready.sessionId
      sword?.user = ready.user
      
      addTrace(from: ready)
      
      sword?.emitReady(ready.user)
      
    case .resumed:
      guard let resumed = decodePayload(GatewayResumed.self, from: data) else {
        Sword.log(.warning, "Unable to retreive _trace from resumed, resuming anyways")
        return
      }
      
      addTrace(from: resumed)
      
      isReconnecting = false
      
    default:
      break
    }
  }
}
