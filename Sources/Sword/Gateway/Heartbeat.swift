//
//  Heartbeat.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

#if !os(Linux)
import Starscream
#else
import WebSockets
#endif

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
  weak var gateway: Gateway?

  /// Whether or not this heartbeat is voice
  let isVoice: Bool

  // MARK: Initializer

  /**
   Creates the heartbeat

   - parameter ws: Websocket connection
   - parameter interval: Interval to set heartbeats at
   */
  init(_ gateway: Gateway, _ name: String, interval: Int, voice: Bool = false) {
    self.gateway = gateway
    self.queue = DispatchQueue(
      label: "me.azoy.sword.\(name)",
      qos: .userInitiated
    )
    self.interval = interval
    self.isVoice = voice
  }

  // MARK: Functions

  /// Starts/Sends heartbeat payload
  func send() {
    let deadline = DispatchTime.now()
      + DispatchTimeInterval.milliseconds(self.interval)

    self.queue.asyncAfter(deadline: deadline) { [weak self] in

      guard let this = self else { return }

      guard this.received else {
        print("[Sword] Did not receive ACK from server, reconnecting...")
        this.gateway?.reconnect()
        return
      }

      var heartbeat = Payload(
        op: .heartbeat,
        data: this.sequence ?? NSNull()
      )

      if this.isVoice {
        heartbeat.op = VoiceOP.heartbeat.rawValue
        heartbeat.d = Int(Date().timeIntervalSince1970 * 1000)
      }

      this.gateway?.send(heartbeat.encode(), presence: false)

      this.received = false

      this.send()
    }
  }

}
