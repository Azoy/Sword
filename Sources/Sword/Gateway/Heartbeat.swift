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
extension Gateway {
  func heartbeat(at interval: Int) {
    guard self.isConnected else {
      return
    }
    
    guard self.acksMissed < 3 else {
      print("[Sword] Did not receive ACK from server, reconnecting...")
      self.reconnect()
      return
    }
    
    self.acksMissed += 1
    
    self.send(self.heartbeatPayload.encode(), presence: false)
    
    self.heartbeatQueue.asyncAfter(
      deadline: .now() + .milliseconds(interval)
    ) { [unowned self] in
      self.heartbeat(at: interval)
    }
  }
}
