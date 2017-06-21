//
//  Payload.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Payload Type
struct Payload {

  // MARK: Properties

  /// OP Code for payload
  var op: Int

  /// Data for payload
  var d: Any

  /// Sequence number from payload
  let s: Int?

  /// Event name from payload
  let t: String?

  // MARK: Initializers

  /**
   Creates a payload from JSON String

   - parameter text: JSON String
  */
  init(with text: String) {
    let data = text.decode() as! [String: Any]
    self.op = data["op"] as! Int
    self.d = data["d"]!
    self.s = data["s"] as? Int
    self.t = data["t"] as? String
  }

  /**
   Creates a payload from either an Array | Dictionary

   - parameter op: OP code to dispatch
   - parameter data: Either an Array | Dictionary to dispatch under the payload.d
  */
  init(op: OP, data: Any) {
    self.op = op.rawValue
    self.d = data
    self.s = nil
    self.t = nil
  }

  /**
   Creates a payload from either an Array | Dictionary

   - parameter voiceOP: VoiceOP code to dispatch
   - parameter data: Either an Array | Dictionary to dispatch under the payload.d
  */
  init(voiceOP: VoiceOP, data: Any) {
    self.op = voiceOP.rawValue
    self.d = data
    self.s = nil
    self.t = nil
  }

  // MARK: Functions

  /// Returns self as a String
  func encode() -> String {
    var payload = ["op": self.op, "d": self.d]
    
    if self.t != nil {
      payload["s"] = self.s!
      payload["t"] = self.t!
    }
    
    return payload.encode()
  }

}
