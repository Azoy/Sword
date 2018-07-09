//
//  Payload.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents a message sent to the gateway
struct Payload<T: Codable>: Codable {
  /// Contains the data for the payload
  let d: T
  
  /// The opcode of the payload
  let op: OP
  
  /// The sequence number (present if opcode = .dispatch)
  let s: Int?
  
  /// The event name (present if opcode = .dispatch)
  let t: String?
}

/// Represents a message received from the gateway used to retreive data after
/// inspecting payload without data
struct PayloadData<T : Codable>: Codable {
  /// Contains the data for the payload
  let d: T
}

/// Represents a message received from the gateway used to inspect payload
/// before decoding all keys
struct PayloadSinData: Codable {
  /// The opcode of the payload
  let op: OP
  
  /// The sequence number (present if opcode = .dispatch)
  let s: Int?
  
  /// The event name (present if opcode = .dispatch)
  let t: String?
}
