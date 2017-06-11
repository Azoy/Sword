//
//  VoiceConnection.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

#if !os(iOS)

import Foundation
import Dispatch

import Sockets
import TLS
import URI
import WebSockets

#if os(macOS)
import Sodium
#else
import SodiumLinux
#endif

/// Voice Connection class that handles connection to voice server
public class VoiceConnection: Eventable {

  // MARK: Properties

  /// Whether or not the voice connection is closed
  var isClosed = false

  /// Gets current time in milliseconds
  var currentTime: Int {
    return Int(Date().timeIntervalSince1970 * 1000)
  }

  /// The VoiceEncoder for this connection
  var encoder: Encoder?

  /// Used to block encoder process
  let encoderSema = DispatchSemaphore(value: 1)

  /// URL to connect to WS
  var endpoint: String

  /// Guild that this voice connection is server
  public let guildId: Snowflake

  /// Completion handler function that calls when voice connection is ready
  var handler: (VoiceConnection) -> ()

  /// The Heartbeat to send through WS
  var heartbeat: Heartbeat?

  /// Whether or not the WS is connected
  var isConnected = false

  /// Whether or not the voice connection is playing something
  public var isPlaying = false

  /// Event listeners
  public var listeners = [Event: [(Any) -> ()]]()

  /// Port number for udp client
  var port: Int

  /// Secret key to use to encrypt voice data
  var secret = [UInt8]()

  /// The WS voice connection connects to
  var session: WebSocket?

  /// Whether or not we need to make a new encoder
  var shouldMakeEncoder = true {
    willSet {
      self.encoderSema.wait()
    }

    didSet {
      self.encoderSema.signal()
    }
  }

  /// SSRC used to encrypt voice
  var ssrc: UInt32 = 0

  /// Time we started sending voice through udp
  var startTime = 0

  /// The UDP Client used to send audio through
  var udpClient: UDPInternetSocket?

  /// The dispatch queue that handles reading audio
  var udpReadQueue: DispatchQueue

  /// The dispatch queue that handles sending audio
  var udpWriteQueue: DispatchQueue

  /// The encoder's writePipe to send audio to
  var writer: FileHandle? {
    return self.encoder?.writer.fileHandleForWriting
  }

  /// Used in making of rtp header
  #if os(macOS)
  var sequence = UInt16(arc4random() >> 16)
  var timestamp = UInt32(arc4random())
  #else
  var sequence = UInt16(random() >> 16)
  var timestamp = UInt32(random())
  #endif

  // MARK: Initializer

  /**
   Creates a VoiceConnection object that handles connecting to voice servers

   - parameter endpoint: URL of the voice channel WS needs to connect to
   - parameter guildId: Guild we're connecting to
   - parameter handler: Completion handler to call after we're ready
  */
  init(_ endpoint: String, _ guildId: Snowflake, _ handler: @escaping (VoiceConnection) -> ()) {
    let endpoint = endpoint.components(separatedBy: ":")
    self.endpoint = endpoint[0]
    self.guildId = guildId
    self.port = Int(endpoint[1])!
    self.handler = handler

    self.udpReadQueue = DispatchQueue(label: "gg.azoy.sword.voiceConnection.udpRead.\(guildId)")
    self.udpWriteQueue = DispatchQueue(label: "gg.azoy.sword.voiceConnection.udpWrite.\(guildId)")

    _ = sodium_init()

    signal(SIGPIPE, SIG_IGN)
  }

  /// Called when VoiceConnection needs to free up space
  deinit {
    self.close()
  }

  // MARK: Functions

  /**
   Makes the Thread sleep to keep a constant audio sending rateLimited

   - parameter count: Number in sending sequence of writing data to udp client
  */
  func audioSleep(for count: Int) {
    let inner = (self.startTime + count * 20) - self.currentTime
    let waitTime = Double(20 + inner) / 1000

    guard waitTime > 0 else { return }

    Thread.sleep(forTimeInterval: waitTime)
  }

  /// Closes WS, UDP, and Encoder
  func close() {
    if !self.isClosed {
      self.emit(.connectionClose)
    }

    self.isClosed = true

    try? self.session?.close()

    try? self.udpClient?.close()
    self.encoder = nil
  }

  /// Creates a VoiceEncoder
  func createEncoder(volume: Int = 100) {
    self.shouldMakeEncoder = false

    self.encoder = nil
    self.encoder = Encoder(volume: volume)

    self.readEncoder(for: 1)

    self.shouldMakeEncoder = true
  }

  /**
   Creates a voice packet to send through udp client

   - parameter data: Voice Data to send to client
  */
  func createPacket(with data: [UInt8]) throws -> [UInt8] {
    let header = self.createRTPHeader()
    var nonce = header + [UInt8](repeating: 0x00, count: 12)
    var buffer = data

    #if os(macOS)
    let audioSize = Int(crypto_secretbox_MACBYTES) + data.count
    #else
    let audioSize = 16 + data.count
    #endif
    let audioData = UnsafeMutablePointer<UInt8>.allocate(capacity: audioSize)
    defer {
      free(audioData)
    }

    let encrypted = crypto_secretbox_easy(audioData, &buffer, UInt64(buffer.count), &nonce, &self.secret)

    guard encrypted != -1 else {
      throw VoiceError.encryptionFail
    }

    let encryptedAudioData = Array(UnsafeBufferPointer(start: audioData, count: audioSize))

    return header + encryptedAudioData
  }

  /// Creates the RTP Header to use in a packet
  func createRTPHeader() -> [UInt8] {
    let header = UnsafeMutableRawBufferPointer.allocate(count: 12)

    defer {
      header.deallocate()
    }

    header.storeBytes(of: 0x80, as: UInt8.self)
    header.storeBytes(of: 0x78, toByteOffset: 1, as: UInt8.self)
    header.storeBytes(of: self.sequence.bigEndian, toByteOffset: 2, as: UInt16.self)
    header.storeBytes(of: self.timestamp.bigEndian, toByteOffset: 4, as: UInt32.self)
    header.storeBytes(of: self.ssrc.bigEndian, toByteOffset: 8, as: UInt32.self)

    return Array(header)
  }

  /**
   Decrypts a voice packet from udp client

   - parameter data: Raw data to separate to get rtp header and voice data
  */
  func decryptPacket(with data: Data) throws -> [UInt8] {
    let header = Array(data.prefix(12))
    var nonce = header + [UInt8](repeating: 0x00, count: 12)
    let audioData = Array(data.dropFirst(12))
    #if os(macOS)
    let audioSize = audioData.count - Int(crypto_secretbox_MACBYTES)
    #else
    let audioSize = audioData.count - 16
    #endif
    let unencryptedAudioData = UnsafeMutablePointer<UInt8>.allocate(capacity: audioSize)
    defer {
      free(unencryptedAudioData)
    }

    let unencrypted = crypto_secretbox_open_easy(unencryptedAudioData, audioData, UInt64(data.count - 12), &nonce, &self.secret)

    guard unencrypted != -1 else {
      throw VoiceError.decryptionFail
    }

    return Array(UnsafeBufferPointer(start: unencryptedAudioData, count: audioSize))
  }

  /// Creates a new encoder when old one is done
  func doneReading() {
    self.encoderSema.wait()

    guard self.shouldMakeEncoder else {
      self.encoderSema.signal()
      return
    }

    self.encoderSema.signal()
    self.createEncoder()
  }

  /// Used to tell encoder to close the write pipe
  public func finish() {
    self.encoder?.finish()
  }

  /**
   Handles all WS events

   - parameter payload: Payload that was sent through WS
  */
  func handleWSPayload(_ payload: Payload) {
    guard payload.t != nil else {

      guard let voiceOP = VoiceOP(rawValue: payload.op) else { return }

      guard let data = payload.d as? [String: Any] else {
        self.heartbeat?.received = true
        return
      }

      switch voiceOP {
        case .ready:

          self.heartbeat = Heartbeat(self.session!, "heartbeat.voiceconnection.\(self.guildId)", interval: data["heartbeat_interval"] as! Int, voice: true)
          self.heartbeat?.received = true
          self.heartbeat?.send()

          self.ssrc = data["ssrc"] as! UInt32

          self.startUDPSocket(data["port"] as! Int)

        case .sessionDescription:
          self.secret = data["secret_key"] as! [UInt8]

        default:
          break
      }

      return
    }
  }

  /**
   Moves the bot to a new channel

   - parameter endpoint: New endpoint to connect to
   - parameter identify: New identify to send to WS
   - parameter handler: New completion handler to call once voice connection is ready
  */
  func moveChannels(_ endpoint: String, _ identify: String, _ handler: @escaping (VoiceConnection) -> ()) {
    self.endpoint = endpoint
    self.handler = handler
    self.udpReadQueue = DispatchQueue(label: "gg.azoy.sword.voiceConnection.udpRead.\(guildId)")
    self.udpWriteQueue = DispatchQueue(label: "gg.azoy.sword.voiceConnection.udpWrite.\(guildId)")
    self.isClosed = true

    try? self.session?.close()

    try? self.udpClient?.close()

    self.startWS(identify)
  }

  /**
   Plays a file

   - parameter location: Location of the file to play
  */
  public func play(_ location: String, volume: Int = 100) {
    guard location.contains(".") else {
      print("[Sword] The file you want to play doesn't have an extension.")
      return
    }

    let locationPaths = location.components(separatedBy: ".")

    let process = Process()
    process.launchPath = "/usr/local/bin/ffmpeg"
    process.arguments = [
      "-loglevel", "quiet",
      "-i", location,
      "-f", locationPaths[locationPaths.count - 1],
      "-"
    ]

    self.play(process, volume: volume)
  }

  /**
   Gets a process' info and sets its output to encoder's writePipe, then launches it

   - parameter process: Audio process to play from
  */
  public func play(_ process: Process, volume: Int = 100) {
    guard !process.isRunning else {
      print("[Sword] The audio process passed to play from has already launched. Don't launch the process.")
      return
    }

    var volume = volume

    if volume > 200 {
      print("[Sword] The volume you want to use was considered too loud. Using default: 100.")
      volume = 100
    }

    self.createEncoder(volume: volume)

    process.standardOutput = self.writer

    process.terminationHandler = { [unowned self] _ in
      self.finish()
    }

    process.launch()

    self.on(.connectionClose) { [weak process] _ in
      guard let process = process else { return }
      kill(process.processIdentifier, SIGKILL)
    }
  }

  /**
   Plays a youtube video/youtube-dl related sites

   - parameter youtube: Youtube structure to play
  */
  public func play(_ youtube: Youtube, volume: Int = 100) {
    self.play(youtube.process, volume: volume)
  }

  /**
   Reads data from the encoder

   - parameter amount: Number in sequence of reading encoder
  */
  func readEncoder(for amount: Int) {
    self.encoder?.readFromPipe { [weak self] done, data in
      guard let this = self, this.isConnected else { return }

      this.isPlaying = true

      guard !done else {
        this.doneReading()
        this.isPlaying = false
        return
      }

      if amount == 1 {
        this.startTime = this.currentTime

        this.setSpeaking(to: true)
      }

      this.sendPacket(with: data)
      this.audioSleep(for: amount)
      this.readEncoder(for: amount + 1)
    }
  }

  /// Reads audio data from udp client
  func receiveAudio() {
    self.udpReadQueue.async { [weak self] in
      guard let client = self?.udpClient else { return }

      do {
        let (data, _) = try client.recvfrom(maxBytes: 4096)
        guard let audioData = try self?.decryptPacket(with: Data(bytes: data)) else { return }
        self?.emit(.audioData, with: audioData)
      }catch {
        guard let isConnected = self?.isConnected, !isConnected else { return }

        print("[Sword] Error reading voice connection for audio data.")
        self?.close()

        return
      }

      self?.receiveAudio()
    }
  }

  /**
   Sends a WS event that contains the protocol of audio we're sending, and user IP and Port

   - parameter bytes: Raw data to get user's IP and Port from
  */
  func selectProtocol(_ bytes: [UInt8]) {
    let localIp = String(data: Data(bytes: bytes.dropLast(2)), encoding: .utf8)!.replacingOccurrences(of: "\0", with: "")
    let localPort = Int(bytes[68]) + (Int(bytes[69]) << 8)

    let payload = Payload(voiceOP: .selectProtocol, data: ["protocol": "udp", "data": ["address": localIp, "port": localPort, "mode": "xsalsa20_poly1305"]]).encode()

    try? self.session?.send(payload)

    if self.encoder != nil {
      self.readEncoder(for: 1)
    }

    self.handler(self)

    self.receiveAudio()
  }

  /**
   Sends a voice packet through the udp client

   - parameter data: Encrypted audio to send to udp client
  */
  func sendPacket(with data: [UInt8]) {
    self.udpWriteQueue.async { [unowned self] in
      guard data.count <= 320 else { return }

      do {
        try self.udpClient?.sendto(data: self.createPacket(with: data))
      }catch {
        guard self.isClosed else {
          self.close()
          return
        }

        return
      }

      self.sequence = self.sequence &+ 1
      self.timestamp = self.timestamp &+ 960
    }
  }

  /**
   Sets the bot's speaking toggle

   - parameter value: Whether or not we want to speak
  */
  func setSpeaking(to value: Bool) {
    let payload = Payload(voiceOP: .speaking, data: ["speaking": value, "delay": 0]).encode()

    try? self.session?.send(payload)
  }

  /**
   Creates UDP client to send audio through

   - parameter port: Port to use to connect to client
  */
  func startUDPSocket(_ port: Int) {
    let address = InternetAddress(hostname: self.endpoint, port: Port(port))

    guard let client = try? UDPInternetSocket(address: address) else {
      self.close()

      return
    }

    self.udpClient = client

    do {
      try client.sendto(data: [UInt8](repeating: 0x00, count: 70))
      let (data, _) = try client.recvfrom(maxBytes: 70)

      self.selectProtocol(data)
    } catch {
      self.close()
    }
  }

  /**
   Starts WS used to connect to voice channel

   - parameter identify: Identify to send to give details about our connection
  */
  func startWS(_ identify: String) {
    let gatewayUri = try! URI("wss://\(self.endpoint)")
    let tcp = try! TCPInternetSocket(scheme: "https", hostname: gatewayUri.hostname, port: gatewayUri.port ?? 443)
    let stream = try! TLS.InternetSocket(tcp, TLS.Context(.client))
    try? WebSocket.background(to: "wss://\(self.endpoint)", using: stream) { [unowned self] ws in
      self.session = ws
      self.isConnected = true

      try? ws.send(identify)

      ws.onText = { ws, text in
        self.handleWSPayload(Payload(with: text))
      }

      ws.onClose = { ws, code, _, _ in
        self.session = nil
        self.heartbeat = nil
        self.isConnected = false
      }
    }
  }

}

#endif
