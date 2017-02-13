//
//  Eventer.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Create a nifty Event Emitter in Swift
public protocol Eventable: class {

  /// Event Listeners
  var listeners: [Event: [([Any]) -> ()]] { get set }

  /**
   - parameter event: Event to listen for
   */
  func on(_ event: Event, _ completion: @escaping ([Any]) -> ())

  /**
   - parameter event: Event to emit
   - parameter data: Array of stuff to emit listener with
   */
  func emit(_ event: Event, with data: Any...)

}

extension Eventable {

  /**
   Listens for eventName

   - parameter event: Event to listen for
   */
  public func on(_ event: Event, _ completion: @escaping ([Any]) -> ()) {
    guard self.listeners[event] != nil else {
      self.listeners[event] = [completion]
      return
    }
    self.listeners[event]!.append(completion)
  }

  /**
   Emits all listeners for eventName

   - parameter event: Event to emit
   - parameter data: Array of stuff to emit listener with
   */
  public func emit(_ event: Event, with data: Any...) {
    guard let functions = self.listeners[event] else { return }
    for function in functions {
      function(data)
    }
  }

}
