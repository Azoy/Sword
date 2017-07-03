//
//  Snowflake.swift
//  Sword
//

import Foundation

/// The stored type of a Discord Snowflake ID.
public struct Snowflake {
  
  /// Number of generated ID's for the process
  public let numberInProcess: UInt16
  
  /// Discord's internal process under worker that generated this snowflake
  public let processId: UInt8
  
  /// Time when snowflake was created
  public let timestamp: Date
  
  /// The internal value storage for a snowflake
  public let value: UInt64
  
  /// Discord's internal worker ID that generated this snowflake
  public let workerId: UInt8
  
  /// Initialize from a UInt64
  public init(_ snowflake: UInt64) {
    self.value = snowflake
    self.numberInProcess = UInt16(snowflake & 4095)
    self.processId = UInt8((snowflake & 61440) >> 12)
    self.workerId = UInt8((snowflake & 983040) >> 17)
    self.timestamp = Date(timeIntervalSince1970: (Double(((snowflake & 18446744073705357312) >> 22)) + Double(1420070400000)) / 1000)
  }
  
  /// Initialize from a String
  init?(_ string: String) {
    guard let snowflake = UInt64(string) else { return nil }
    self.init(snowflake)
  }
  
  /// Initialize from a String? (returns nil if the input was nil or if it failed to initialize)
  init?(_ optionalString: String?) {
    guard let string = optionalString else { return nil }
    self.init(string)
  }
}

// MARK: Snowflake Typealiases

/// A Snowflake ID representing a Guild
public typealias GuildID = Snowflake

/// A Snowflake ID representing a Channel
public typealias ChannelID = Snowflake

/// A Snowflake ID representing a User
public typealias UserID = Snowflake

/// A Snowflake ID representing a Role
public typealias RoleID = Snowflake

/// A Snowflake ID representing a Message
public typealias MessageID = Snowflake

/// A Snowflake ID representing a Webhook
public typealias WebhookID = Snowflake

/// A Snowflake ID representing a Permissions Overwrite
public typealias OverwriteID = Snowflake

/// A Snowflake ID representing an Emoji
public typealias EmojiID = Snowflake

/// A Snowflake ID representing an Integration
public typealias IntegrationID = Snowflake

/// A Snowflake ID representing an Attachment
public typealias AttachmentID = Snowflake

// MARK: Snowflake Conformances

/// Snowflake conformance to CustomStringConvertible
extension Snowflake : CustomStringConvertible {

  /// Description for string Conversion
  public var description: String {
    return self.value.description
  }

}

/// Snowflake conformance to Comparable
extension Snowflake: Comparable {

  /// Used to check whether two Snowflakes are equal
  public static func ==(lhs: Snowflake, rhs: Snowflake) -> Bool {
    return lhs.value == rhs.value
  }

  /// Used to compare Snowflakes (which is useful because a greater Snowflake was made later)
  public static func <(lhs: Snowflake, rhs: Snowflake) -> Bool {
    return lhs.value < rhs.value
  }

}

/// Snowflake conformance to Hashable
extension Snowflake: Hashable {

  /// The hash value of the Snowflake
  public var hashValue: Int {
    return self.value.hashValue
  }

}

// MARK: Snowflake-String Comparison

/// :nodoc:
/// Used to check whether a string equals a Snowflake
public func ==(lhs: Snowflake, rhs: String) -> Bool {
  return lhs == Snowflake(rhs)
}

/// :nodoc:
/// Used to check whether a string equals a Snowflake
public func ==(lhs: Snowflake?, rhs: String) -> Bool {
  guard let lhs = lhs else { return false }
  return lhs == Snowflake(rhs)
}

/// :nodoc:
/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: Snowflake, rhs: String) -> Bool {
  return lhs != Snowflake(rhs)
}

/// :nodoc:
/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: Snowflake?, rhs: String) -> Bool {
  guard let lhs = lhs else { return false }
  return lhs != Snowflake(rhs)
}

/// :nodoc:
/// Used to check whether a string equals a Snowflake
public func ==(lhs: String, rhs: Snowflake) -> Bool {
  return Snowflake(lhs) == rhs
}

/// :nodoc:
/// Used to check whether a string equals a Snowflake
public func ==(lhs: String, rhs: Snowflake?) -> Bool {
  guard let rhs = rhs else { return false }
  return Snowflake(lhs) == rhs
}

/// :nodoc:
/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: String, rhs: Snowflake) -> Bool {
  return Snowflake(lhs) != rhs
}

/// :nodoc:
/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: String, rhs: Snowflake?) -> Bool {
  guard let rhs = rhs else { return false }
  return Snowflake(lhs) != rhs
}
