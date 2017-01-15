//
//  Heartbeat.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch
import WebSockets

/// <3
class Heartbeat {

  // MARK: Properties

  /// Current websocket
  let session: WebSocket

  /// Interval to send heartbeats
  let interval: Int

  /// Last received sequence
  var sequence: Int?

  /// Whether or not the server received our last heartbeat
  var received = false

  /// The Dispatch Queue to handle heartbeats
  let queue: DispatchQueue

  // MARK: Initializer

  /**
   Creates the heartbeat

   - parameter ws: Websocket connection
   - parameter interval: Interval to set heartbeats at
   */
  init(_ ws: WebSocket, _ name: String, interval: Int) {
    self.session = ws
    self.queue = DispatchQueue(label: "gg.azoy.sword.\(name)", qos: .userInitiated)
    self.interval = interval
  }

  // MARK: Functions

  /// Starts/Sends heartbeat payload
  func send() {
    let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(self.interval)

    queue.asyncAfter(deadline: deadline) {
      let heartbeat = Payload(op: .heartbeat, data: self.sequence ?? NSNull()).encode()

      try? self.session.send(heartbeat)
      self.received = false

      self.send()
    }
  }

}
