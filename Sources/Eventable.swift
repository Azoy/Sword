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

  var on: EventListener { get }

  /**
   - parameter event: Event to emit
   - parameter data: Array of stuff to emit listener with
   */
  func emit(_ event: Event, with data: Any...)

}

extension Eventable {

  /**
   Emits all listeners for eventName

   - parameter event: Event to emit
   - parameter data: Array of stuff to emit listener with
   */
  public func emit(_ event: Event, with data: Any...) {
    guard let functions = self.on.listeners[event] else { return }

    for function in functions {
      switch event {
        case .messageCreate:
          (function as! (Message) -> ())(data[0] as! Message)
          break
        default:
          break
      }
    }
  }

}
