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

    queue.asyncAfter(deadline: deadline) { [weak self] in

      guard let this = self else { return }

      guard this.received else { return }

      var heartbeat = Payload(
        op: .heartbeat,
        data: this.sequence ?? NSNull()
      )

      if this.voice {
        heartbeat.op = VoiceOP.heartbeat.rawValue
        heartbeat.d = Int(Date().timeIntervalSince1970 * 1000)
      }

      try? this.session.send(heartbeat.encode())

      this.received = false

      this.send()
    }
  }

}
