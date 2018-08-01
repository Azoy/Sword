//
//  Shard.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation
import WebSocket
import CNIOZlib

/// Shard - Represents a unique session to a portion of the guilds a bot is
///         connected to.
class Shard: GatewayHandler {
  /// Number of missed heartbeat acks
  var ackMissed = 0
  
  /// Buffer to hold gateway messages
  var buffer: UnsafeMutableBufferPointer<UInt8>? = nil
  
  /// The shard ID
  let id: UInt8
  
  /// The current heartbeat payload
  var heartbeatPayload: Payload<Int?> {
    return Payload(d: lastSeq, op: .heartbeat, s: nil, t: nil)
  }
  
  /// Dispatch queue to manage sending heartbeats
  let heartbeatQueue: DispatchQueue
  
  /// Determines whether or not the current buffer is ready to be unpacked
  var isBufferComplete: Bool {
    guard let buffer = buffer, buffer.count >= 4 else {
      return false
    }
    
    let suffix = buffer.dropFirst(buffer.count - 4)
    return suffix.elementsEqual([0x0, 0x0, 0xFF, 0xFF])
  }
  
  /// Whether or not the shard is currently trying to reconnect
  var isReconnecting = false
  
  /// The last sequence number for this shard
  var lastSeq: Int?
  
  /// The WebSocket session
  var session: WebSocket?
  
  /// Used to resume connections
  var sessionId: String?
  
  /// The parent class
  let sword: Sword
  
  /// Debugging purposes, array of servers we're connected to
  var trace = [String]()
  
  /// Event loop to handle payloads on
  var worker: Worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  
  var stream = z_stream()
  
  /// Instantiates a Shard
  ///
  /// - parameter id: The shard id
  /// - parameter sword: The parent class
  init(id: UInt8, _ sword: Sword) {
    self.id = id
    self.sword = sword
    self.heartbeatQueue = DispatchQueue(label: "sword.shard.\(id).heartbeat")
    
    // Setup inflater
    stream.avail_in = 0
    stream.next_in = nil
    stream.total_out = 0
    stream.zalloc = nil
    stream.zfree = nil
    
    inflateInit2_(
      &stream,
      MAX_WBITS,
      ZLIB_VERSION,
      Int32(MemoryLayout<z_stream>.size)
    )
  }
  
  /// Handles deinitialization of a shard
  deinit {
    inflateEnd(&stream)
    
    do {
      try worker.syncShutdownGracefully()
    } catch {
      Sword.log(.warning, "Unable to shutdown event loop for shard: \(id).")
    }
  }
  
  /// Adds _trace to current list of _trace
  func addTrace(from th: TraceHolder) {
    for trace in th.trace {
      self.trace.append(trace)
    }
  }
  
  func handleBinary(_ data: Data) {
    if buffer == nil {
      buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: data.count)
      _ = buffer!.initialize(from: data)
    } else {
      let backIndex = buffer!.endIndex
      buffer!.realloc(size: buffer!.count + data.count)
      
      // Append new data after old data
      for index in data.indices {
        buffer![backIndex + index] = data[index]
      }
    }
    
    defer {
      buffer!.deallocate()
      buffer = nil
    }
    
    guard isBufferComplete else {
      return
    }
    
    stream.next_in = buffer!.baseAddress
    stream.avail_in = UInt32(buffer!.count)
    
    var inflated = UnsafeMutableBufferPointer<UInt8>.allocate(
      capacity: buffer!.count * 2
    )
    
    defer {
      inflated.deallocate()
    }
    
    stream.total_out = 0
    
    var status: Int32 = 0
    
    while true {
      stream.next_out = inflated.baseAddress?.advanced(by: Int(stream.total_out))
      stream.avail_out = UInt32(inflated.count) - UInt32(stream.total_out)
      
      status = inflate(&stream, Z_SYNC_FLUSH)

      if status == Z_BUF_ERROR && stream.avail_in > 0 {
        inflated.realloc(
          size: inflated.count + min(inflated.count * 2, maxBufSize)
        )
        continue
      } else if status != Z_OK {
        break
      }
    }
    
    let result = String(
      bytesNoCopy: inflated.baseAddress!,
      length: Int(stream.total_out),
      encoding: .utf8,
      freeWhenDone: false
    )
    
    guard let text = result else {
      // Need a better error message here
      Sword.log(.error, "Failed to generate string from binary message")
      return
    }
    
    handleText(text)
  }
  
  /// Handles a sudden gateway close
  ///
  /// - parameter error: The op close code
  func handleClose(_ error: WebSocketErrorCode) {
    if case .normalClosure = error {
      Sword.log(.warning, "Shard \(id) closed, reconnecting...")
      
      reconnect()
      return
    }
    
    guard case let .unknown(code) = error else {
      Sword.log(.warning, "Received unhandled websocket close code: \(error)")
      return
    }
    
    switch code {
    case 4000 ... 4003, 4005 ... 4009:
      reconnect()
      
    case 4004:
      Sword.log(.error, "Shard \(id) has an incorrect token: \(sword.token)")
      
    case 4010:
      Sword.log(.error, "Shard \(id) sent invalid shard information")
      
    case 4011:
      Sword.log(.error, "Shard \(id) has too many guilds, more shards are required")
      
    default:
      Sword.log(.warning, "Received unhandled websocket close code: \(code)")
    }
  }
  
  /// Handles text being sent through the gateway
  ///
  /// - parameter ws: WebSocket session to prevent cycles
  /// - parameter text: String that was sent through the gateway
  func handleText(_ text: String) {
    guard session != nil else {
      return
    }
    
    let data = text.convertToData()
    
    do {
      let payload = try Sword.decoder.decode(PayloadSinData.self, from: data)
      
      handlePayload(payload, data)
    } catch {
      Sword.log(
        .error,
        "Unable to correctly decode payload data. Error: \(error.localizedDescription)"
      )
    }
  }
  
  /// Initiates the heartbeating mode
  func heartbeat(to ms: Int) {
    guard let session = session else {
      return
    }
    
    guard !session.isClosed else {
      Sword.log(.warning, "Tried to heartbeat on closed shard \(id)")
      return
    }
    
    guard ackMissed < 3 else {
      Sword.log(
        .error,
        "Shard \(id) has missed 3 heartbeat acks from Discord. Reconnecting..."
      )
      
      reconnect()
      return
    }
    
    ackMissed += 1
    send(heartbeatPayload)
    
    heartbeatQueue.asyncAfter(
      deadline: .now() + .milliseconds(ms)
    ) { [weak self] in
      guard let this = self else {
        return
      }
      
      this.heartbeat(to: ms)
    }
  }
  
  /// Sends identify payload
  ///
  /// - parameter payload: Hello payload to identify to
  func identify() {
    #if os(macOS)
    let os = "macOS"
    #elseif os(iOS)
    let os = "iOS"
    #elseif os(Linux)
    let os = "Linux"
    #endif
    
    let identify = GatewayIdentify(
      largeThreshold: 50,
      properties: GatewayIdentify.Properties(
        browser: "Sword",
        device: "Sword",
        os: os
      ),
      shard: [id, sword.shardManager.shardCount],
      token: sword.token,
      willCompress: false
    )
    
    let payload = Payload(d: identify, op: .identify, s: nil, t: nil)
    send(payload)
  }
  
  /// Reconnects the shard to Discord
  func reconnect() {
    if let session = session, !session.isClosed {
      disconnect()
    }
    
    guard let host = sword.shardManager.shardHosts[id] else {
      // Unable to get host for this shard for some reason, silently kill this
      return
    }
    
    defer {
      connect(to: host)
    }
    
    guard sessionId != nil else {
      // There was no session to begin with (?). Don't resume.
      return
    }
    
    isReconnecting = true
  }
  
  /// Sends a payload through a websocket session
  func send<T: Codable>(_ payload: Payload<T>) {
    do {
      let data = try Sword.encoder.encode(payload)
      session?.send(data.convert(to: String.self))
    } catch {
      Sword.log(
        .warning,
        "Unable to send payload on shard \(id). Error: \(error.localizedDescription)"
      )
    }
  }
}
