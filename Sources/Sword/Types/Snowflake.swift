//
//  Snowflake.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

/// The stored type of a Discord Snowflake ID
public struct Snowflake {
  /// Discord's Epoch
  public static let epoch = Date(timeIntervalSince1970: 1420070400)
  
  /// Number of generated ID's for the process
  public var increment: UInt16 {
    return UInt16(rawValue & 0xFFF)
  }
  
  /// Discord's internal process under worker that generated this snowflake
  public var processId: UInt8 {
    return UInt8((rawValue & 0x1F000) >> 12)
  }
  
  /// The internal value storage for a snowflake
  public let rawValue: UInt64
  
  /// Time when snowflake was created
  public var timestamp: Date {
    return Date(
      timeInterval: Double(
        (rawValue >> 22) / 1000
      ),
      since: Snowflake.epoch
    )
  }
  
  /// Discord's internal worker ID that generated this snowflake
  public var workerId: UInt8 {
    return UInt8((rawValue & 0x3E0000) >> 17)
  }
  
  /// Produces a fake Snowflake with the given time and process ID
  public init() {
    var rawValue: UInt64 = 0
    
    // Setup timestamp (42 bits)
    let now = Date()
    let difference = UInt64(now.timeIntervalSince(Snowflake.epoch) * 1000)
    rawValue |= difference << 22
    
    // Setup worker id (5 bits)
    rawValue |= 16 << 17
    
    // Setup process id (6 bits)
    rawValue |= 1 << 12
    
    // Setup incremented id (11 bits)
    rawValue += 128
    
    self.rawValue = rawValue
  }
  
  /// Init for rawValue conformance
  ///
  /// - parameter rawValue: The raw snowflake number
  public init(rawValue: UInt64) {
    self.rawValue = rawValue
  }
}

extension Snowflake: Encodable {
  /// Encode to JSON
  ///
  /// - parameter encoder: JSONEncoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

extension Snowflake: Decodable {
  /// Decode from JSON
  ///
  /// - parameter decoder: JSONDecoder
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.rawValue = try container.decode(UInt64.self)
  }
}

extension Snowflake: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = UInt64
  
  /// Initialize from an integer literal
  public init(integerLiteral value: UInt64) {
    self.rawValue = value
  }
}

extension Snowflake: CustomStringConvertible {
  /// Description for string conversion
  public var description: String {
    return rawValue.description
  }
}

extension Snowflake: RawRepresentable, Equatable {
  public typealias RawValue = UInt64
}

extension Snowflake: Comparable {
  /// Used to compare Snowflakes
  public static func <(lhs: Snowflake, rhs: Snowflake) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

extension Snowflake: Hashable {
  /// The hash value of a Snowflake
  public var hashValue: Int {
    return rawValue.hashValue
  }
}
