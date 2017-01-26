import Foundation
import Dispatch
import WebSockets
import Socks
import Sodium

public class VoiceConnection {

  public var encoder: Encoder?

  let encoderSema = DispatchSemaphore(value: 1)

  let endpoint: String

  public let guildId: String

  let handler: (VoiceConnection) -> ()

  var heartbeat: Heartbeat?

  var isConnected = false

  var shouldMakeEncoder = true {
    willSet {
      self.encoderSema.wait()
    }

    didSet {
      self.encoderSema.signal()
    }
  }

  let port: Int

  var secret: [UInt8] = []

  var session: WebSocket?

  var ssrc: UInt32 = 0

  var udpClient: UDPClient?

  let udpUrl = ""

  public var writer: FileHandle? {
    return self.encoder?.writer.fileHandleForWriting
  }

  #if !os(Linux)
  let sequence = UInt16(arc4random() >> 16)
  let timestamp = UInt32(arc4random())
  #else
  let sequence = UInt16(random() >> 16)
  let timestamp = UInt32(random())
  #endif

  init(_ endpoint: String, _ guildId: String, _ handler: @escaping (VoiceConnection) -> ()) {
    let endpoint = endpoint.components(separatedBy: ":")
    self.endpoint = endpoint[0]
    self.guildId = guildId
    self.port = Int(endpoint[1])!
    self.handler = handler

    _ = sodium_init()

    signal(SIGPIPE, SIG_IGN)
  }

  deinit {
    self.close()
  }

  func close() {
    self.session = nil
    self.heartbeat = nil
    self.isConnected = false
    self.udpClient = nil
  }

  func createEncoder() {
    self.shouldMakeEncoder = false

    self.encoder = nil
    self.encoder = Encoder()

    self.readEncoder(for: 1)

    self.shouldMakeEncoder = true
  }

  func createPacket(with data: [UInt8]) throws -> [UInt8] {
    let header = self.createRTPHeader()
    var nonce = header + [UInt8](repeating: 0x00, count: 12)
    var buffer = data

    let audioSize = Int(crypto_secretbox_MACBYTES) + 320
    let audioData = UnsafeMutablePointer<UInt8>.allocate(capacity: audioSize)
    let audioDataCount = Int(crypto_secretbox_MACBYTES) + data.count

    let encrypted = crypto_secretbox_easy(audioData, &buffer, UInt64(buffer.count), &nonce, &self.secret)

    guard encrypted != -1 else {
      throw VoiceError.encryptionFail
    }

    let encryptedAudioData = Array(UnsafeBufferPointer(start: audioData, count: audioDataCount))

    return header + encryptedAudioData
  }

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

  func doneReading() {
    self.encoderSema.wait()

    guard self.shouldMakeEncoder else {
      self.encoderSema.signal()
      return
    }

    self.encoderSema.signal()
    self.createEncoder()
  }

  func handleWSPayload(_ payload: Payload) {
    guard payload.t != nil else {

      guard let voiceOP = VoiceOPCode(rawValue: payload.op) else { return }

      let data = payload.d as! [String: Any]

      switch voiceOP {
        case .ready:

          self.heartbeat = Heartbeat(self.session!, "heartbeat.voiceconnection.\(self.guildId)", interval: data["heartbeat_interval"] as! Int)
          self.heartbeat?.send()

          self.ssrc = data["ssrc"] as! UInt32

          self.startUDPSocket(data["port"] as! Int)

          break
        default:
          break
      }

      return
    }
  }

  func readEncoder(for amount: Int) {
    self.encoder?.readFromPipe { done, data in

      guard !done else {
        self.doneReading()

        return
      }

      print("Received \(data.count) bytes.")

      if amount == 1 {
        self.setSpeaking(to: true)
      }

      self.sendPacket(with: data)
      self.readEncoder(for: amount + 1)
    }
  }

  func selectProtocol(_ bytes: [UInt8]) {
    let localIp = String(data: Data(bytes: bytes.dropLast(2)), encoding: .utf8)!.replacingOccurrences(of: "\0", with: "")
    let localPort = Int(bytes[68]) + (Int(bytes[69]) << 8)

    let payload = Payload(voiceOP: .selectProtocol, data: ["protocol": "udp", "data": ["address": localIp, "port": localPort, "mode": "xsalsa20_poly1305"]]).encode()

    try? self.session?.send(payload)

    self.createEncoder()

    self.handler(self)
  }

  func sendPacket(with data: [UInt8]) {
    guard data.count <= 320 else { return }

    do {
      try self.udpClient?.send(bytes: self.createPacket(with: data))
    }catch {
      self.close()

      return
    }

    self.sequence = self.sequence &+ 1
    self.timestamp = self.timestamp &+ 960
  }

  func setSpeaking(to value: Bool) {
    let payload = Payload(voiceOP: .speaking, data: ["speaking": value, "delay": 0]).encode()

    try? self.session?.send(payload)
  }

  func startUDPSocket(_ port: Int) {
    let address = InternetAddress(hostname: self.endpoint, port: Port(port))

    guard let client = try? UDPClient(address: address) else {
      self.close()

      return
    }

    self.udpClient = client

    do {
      try client.send(bytes: [UInt8](repeating: 0x00, count: 70))
      let (data, _) = try client.receive(maxBytes: 70)

      self.selectProtocol(data)
    } catch {
      self.close()
    }
  }

  func startWS(_ identify: String) {

    try? WebSocket.background(to: "wss://\(self.endpoint)") { ws in
      self.session = ws
      self.isConnected = true

      try? ws.send(identify)

      ws.onText = { ws, text in
        self.handleWSPayload(Payload(with: text))
      }

      ws.onClose = { ws, code, something, somethingagain in
        self.heartbeat = nil
        self.isConnected = false
      }
    }

  }

}
