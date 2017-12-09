//
//  Gateway.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

#if !os(Linux)
import Starscream
#else
import Sockets
import TLS
import URI
import WebSockets
#endif

protocol Gateway: class {

  var gatewayUrl: String { get set }

  var heartbeat: Heartbeat? { get set }

  var isConnected: Bool { get set }
  
  var session: WebSocket? { get set }
  
  #if os(macOS) || os(Linux)
  func handleConnect()
  #endif
  
  func handleDisconnect(for code: Int)
  
  func handlePayload(_ payload: Payload)
  
  func reconnect()
  
  func send(_ text: String, presence: Bool)
  
  func start()

  func stop()

}

extension Gateway {
  
  /// Handles what to do on connect to gateway
  #if !os(iOS)
  func handleConnect() {}
  #endif
  
  /// Starts the gateway connection
  func start() {
    #if !os(Linux)
    if self.session == nil {
      self.session = WebSocket(url: URL(string: self.gatewayUrl)!)
      
      self.session?.onConnect = { [unowned self] in
        self.isConnected = true
        
        #if os(macOS) || os(Linux)
        self.handleConnect()
        #endif
      }
      
      self.session?.onText = { [unowned self] text in
        self.handlePayload(Payload(with: text))
      }
      
      self.session?.onDisconnect = { [unowned self] error in
        self.heartbeat = nil
        self.isConnected = false
        
        guard let error = error else { return }
        
        self.handleDisconnect(for: (error as NSError).code)
      }
    }

    self.session?.connect()
    #else
    do {
      let gatewayUri = try URI(self.gatewayUrl)
      let tcp = try TCPInternetSocket(
        scheme: "https",
        hostname: gatewayUri.hostname,
        port: gatewayUri.port ?? 443
      )
      let stream = try TLS.InternetSocket(tcp, TLS.Context(.client))
      try WebSocket.connect(to: gatewayUrl, using: stream) {
        [unowned self] ws in
        
        self.session = ws
        self.isConnected = true
        
        self.handleConnect()
        
        ws.onText = { _, text in
          self.handlePayload(Payload(with: text))
        }

        ws.onClose = { _, code, _, _ in
          self.heartbeat = nil
          self.isConnected = false

          guard let code = code else { return }

          self.handleDisconnect(for: Int(code))
        }
      }
    }catch {
      print("[Sword] \(error.localizedDescription)")
      self.start()
    }
    #endif
  }

}
