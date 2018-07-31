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
  var sword: Sword { get }
  
  /// Event loop to handle payloads on
  var worker: Worker { get set }
  
  /// Connects the handler to a specific gateway URL
  ///
  /// - parameter host: The gateway URL that this shard needs to connect to
  func connect(to host: String)
  
  /// Disconnects the handler from the gateway
  func disconnect()
  
  /// Defines what to when data is received as binary
  ///
  /// - parameter data: The data that was received from the gateway
  //func handleBinary(_ data: Data)
  
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
    guard let url = URL(string: urlString), let host = url.host else {
      Sword.log(.error, .invalidURL(urlString))
      return
    }
    
    let path = url.path.isEmpty ? "/" : url.path + "?" + url.query!
    
    let futureWs = HTTPClient.webSocket(
      scheme: .wss,
      hostname: host,
      port: url.port,
      path: path,
      on: worker
    )
    
    futureWs.whenSuccess { [weak self] ws in
      guard let this = self else {
        return
      }
      
      this.session = ws
      
      /*
      ws.onBinary { _, data in
        this.handleBinary(data)
      }
      */
      
      ws.onCloseCode { code in
        this.handleClose(code)
      }
      
      ws.onText { _, text in
        this.handleText(text)
      }
    }
    
    // Makes sure we aren't in an event loop when we try to reconnect in the future
    DispatchQueue.main.async {
      do {
        _ = try futureWs.wait()
      } catch {
        Sword.log(.error, .gatewayConnectFailure(error.localizedDescription))
      }
    }
  }
  
  /// Disconnects the handler from the gateway
  func disconnect() {
    session?.close()
    session = nil
  }
}
