//
//  Eventer.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Create a nifty Event Emitter in Swift
public protocol Eventable: class {

  /// Event Listeners
  var listeners: [Event: [(Any) -> ()]] { get set }

  /**
   - parameter event: Event to listen for
   */
  func on(
    _ event: Event,
    do function: @escaping (Any) -> ()
  ) -> Int

  /**
   - parameter event: Event to emit
   - parameter data: Array of stuff to emit listener with
   */
  func emit(
    _ event: Event,
    with data: Any
  )
  
  /**
   - parameter event: Event to remove a listener from
   - parameter position: Position of listener callback
  */
  func removeListener(
    from event: Event,
    at position: Int
  )
  
}

extension Eventable {

  /**
   Listens for eventName

   - parameter event: Event to listen for
  */
  @discardableResult
  public func on(
    _ event: Event,
    do function: @escaping (Any) -> ()
  ) -> Int {
    guard self.listeners[event] != nil else {
      self.listeners[event] = [function]
      return 0
    }

    self.listeners[event]!.append(function)
    
    return self.listeners[event]!.count - 1
  }

  /**
   Emits all listeners for eventName

   - parameter event: Event to emit
   - parameter data: Stuff to emit listener with
  */
  public func emit(
    _ event: Event,
    with data: Any = ()
  ) {
    guard let listeners = self.listeners[event] else { return }

    for listener in listeners {
      listener(data)
    }
  }
  
  /**
   Removes a listener from an event
   
   - parameter event: Event to remove a listener from
   - parameter position: Position of listener callback
  */
  public func removeListener(
    from event: Event,
    at position: Int
  ) {
    _ = self.listeners[event]?.remove(at: position)
  }
  
}
