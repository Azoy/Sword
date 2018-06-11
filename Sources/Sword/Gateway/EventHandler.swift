//
//  EventHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Create a nifty Event Emitter in Swift
public protocol EventHandler: AnyObject {
  /// Event Listeners
  var listeners: [Event: [Any]] { get set }
}

extension EventHandler {
  /// Listens for event
  ///
  /// - parameter event: Event to listen for
  func on(_ event: Event, do function: Any) {
    guard listeners.keys.contains(event) else {
      listeners[event] = [function]
      return
    }
    
    listeners[event]?.append(function)
  }
  
  /// Listens for READY events
  public func onReady(do function: @escaping (User) -> ()) {
    on(.ready, do: function)
  }
  
  /// Emits all listeners for READY
  ///
  /// - parameter data: User to emit listener with
  public func emitReady(_ user: User) {
    guard let listeners = listeners[.ready] else { return }
    
    for listener in listeners {
      let listener = listener as! (User) -> ()
      listener(user)
    }
  }
}
