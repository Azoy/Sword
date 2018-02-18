//
//  Snowflake.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
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
    
    /// Init for rawValue conformance
    ///
    /// - parameter rawValue: The raw snowflake number
    public init(rawValue: UInt64) {
      self.rawValue = rawValue
    }
  }
}

extension Sword.Snowflake: ExpressibleByIntegerLiteral {
  public typealias IntegerLiteralType = UInt64
  
  /// Initialize from an integer literal
  public init(integerLiteral value: UInt64) {
    self.rawValue = value
  }
}

extension Sword.Snowflake: CustomStringConvertible {
  /// Description for string conversion
  public var description: String {
    return rawValue.description
  }
}

extension Sword.Snowflake: RawRepresentable, Equatable {
  public typealias RawValue = UInt64
}

extension Sword.Snowflake: Comparable {
  /// Used to compare Snowflakes
  public static func <(lhs: Sword.Snowflake, rhs: Sword.Snowflake) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

extension Sword.Snowflake: Hashable {
  /// The hash value of a Snowflake
  public var hashValue: Int {
    return rawValue.hashValue
  }
}
