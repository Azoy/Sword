//
//  Eventer.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Create a nifty Event Emitter in Swift
class Eventer {

  var listeners: [String: [([Any]) -> ()]] = [:]

  /**
   Listens for eventName

   - parameter eventName: Event to listen for
   */
  func on(_ eventName: String, _ completion: @escaping ([Any]) -> ()) {
    guard self.listeners[eventName] != nil else {
      self.listeners[eventName] = [completion]
      return
    }
    self.listeners[eventName]!.append(completion)
  }

  /**
   Emits all listeners for eventName

   - parameter eventName: Event to emit
   - parameter data: Array of stuff to emit listener with
   */
  func emit(_ eventName: String, with data: [Any]) {
    guard let functions = self.listeners[eventName] else { return }
    for function in functions {
      function(data)
    }
  }

}
