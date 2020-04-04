//
//  GatewayHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import NIO
import Starscream

/// Represents a WebSocket session for Discord
protocol GatewayHandler : AnyObject {
  /// Internal WebSocket session
  var session: WebSocketClient.Socket? { get set }

  /// Sword class
  var sword: Sword { get }
  
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to host: String)
  
  /// Disconnects the handler from the gateway
  func disconnect()
  
  /// Defines what to when data is received as binary
  ///
  /// - parameter data: The data that was received from the gateway
  func handleBinary(_ data: ByteBuffer)
  
  /// Defines what to do when the gateway closes on us
  func handleClose(_ error: WebSocketErrorCode)
  
  /// Defines what to do when data is received as text
  ///
  /// - parameter text: The String that was received from the gateway
  func handleText(_ text: String)
  
  /// Reconnects the handler to the gateway
  func reconnect()
}

extension GatewayHandler {
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to urlString: String) {
    guard let url = URL(string: urlString) else {
      Sword.log(.error, .invalidURL(urlString))
      return
    }
    
    DispatchQueue.global().async {
      do {
        try self.sword.gateway.connect(
          host: url.absoluteString,
          port: url.port ?? 443
        ) { [unowned self] ws in
          self.session = ws
          
          ws.onBinary {
            self.handleBinary($1)
          }
          
          ws.onCloseCode {
            self.handleClose($0)
          }
          
          ws.onText {
            self.handleText($1)
          }
        }.wait()
      } catch {
        Sword.log(.error, .gatewayConnectFailure(error.localizedDescription))
      }
    }
  }
  
  /// Disconnects the handler from the gateway
  func disconnect() {
    session?.close(promise: nil)
    session = nil
  }
}
