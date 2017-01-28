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

  /// Interval to send heartbeats
  let interval: Int

  /// The Dispatch Queue to handle heartbeats
  let queue: DispatchQueue

  /// Whether or not the server received our last heartbeat
  var received = false

  /// Last received sequence
  var sequence: Int?

  /// Current websocket
  let session: WebSocket

  /// Whether or not this heartbeat is voice
  let voice: Bool

  // MARK: Initializer

  /**
   Creates the heartbeat

   - parameter ws: Websocket connection
   - parameter interval: Interval to set heartbeats at
   */
  init(_ ws: WebSocket, _ name: String, interval: Int, voice: Bool = false) {
    self.session = ws
    self.queue = DispatchQueue(label: "gg.azoy.sword.\(name)", qos: .userInitiated)
    self.interval = interval
    self.voice = voice
  }

  // MARK: Functions

  /// Starts/Sends heartbeat payload
  func send() {
    let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(self.interval)

    queue.asyncAfter(deadline: deadline) {

      guard self.received else { return }

      if !self.voice {
        let heartbeat = Payload(op: .heartbeat, data: self.sequence ?? NSNull()).encode()

        try? self.session.send(heartbeat)
      }else {
        let heartbeat = Payload(voiceOP: .heartbeat, data: Int(Date().timeIntervalSince1970 * 1000)).encode()

        try? self.session.send(heartbeat)
      }

      self.received = false

      self.send()
    }
  }

}
