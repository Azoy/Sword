//
//  GatewayHandler.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import WebSocket

/// Represents a WebSocket session for Discord
protocol GatewayHandler : AnyObject {
  /// Internal WebSocket session
  var session: WebSocket? { get set }

  /// Sword class
  var sword: Sword? { get set }
  
  /// Event loop to handle payloads on
  var worker: Worker { get set }
  
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to host: String)
  
  /// Disconnects the handler from the gateway
  func disconnect()
  
  /// Defines what to do when data is received as text
  ///
  /// - parameter ws: WebSocket session to prevent cycles
  /// - parameter text: The String that was received from the gateway
  func handleText(_ ws: WebSocket, _ text: String)
  
  /// Defines what to do when the gateway closes on us
  func handleClose(_ error: WebSocketErrorCode)
  
  /// Reconnects the handler to the gateway
  func reconnect()
}

extension GatewayHandler {
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to urlString: String) {
    guard let url = URL(string: urlString), let host = url.host else {
      Sword.log(
        .error,
        "Unable to form proper url to connect gateway handler: \(urlString)"
      )
      return
    }
    
    let path = url.path.isEmpty ? "/" : url.path
    
    do {
      session = try HTTPClient.webSocket(
        scheme: .wss,
        hostname: host,
        port: url.port,
        path: path,
        on: worker
      ).wait()
      
      session?.onText { [weak self] ws, text in
        guard let this = self else {
          Sword.log(
            .error,
            "Unable to capture a gateway handler to handle a text payload."
          )
          return
        }
        
        this.handleText(ws, text)
      }
      
      session?.onCloseCode { [weak self] code in
        guard let this = self else {
          Sword.log(
            .error,
            "Unable to capture a gateway handler to handle closing the connection."
          )
          return
        }
        
        this.handleClose(code)
      }
    } catch {
      Sword.log(
        .error,
        "Unable to connect to gateway: \(error.localizedDescription)"
      )
    }
  }
  
  /// Disconnects the handler from the gateway
  func disconnect() {
    session?.close()
  }
}
