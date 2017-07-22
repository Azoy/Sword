//
//  Snowflake.swift
//  Sword
//

import Foundation

/// The stored type of a Discord Snowflake ID.
public struct Snowflake {
  
  /// Discord's epoch
  public static let epoch = Date(timeIntervalSince1970: 1420070400)
  
  /// Number of generated ID's for the process
  public var numberInProcess: Int {
    return Int(rawValue & 0xFFF)
  }
  
  /// Discord's internal process under worker that generated this snowflake
  public var processId: Int {
    return Int((rawValue & 0x1F000) >> 12)
  }
  
  /// The internal value storage for a snowflake
  public let rawValue: UInt64

  /// Time when snowflake was created
  public var timestamp: Date {
    return Date(timeInterval: Double((rawValue & 0xFFFFFFFFFFC00000) >> 22) / 1000, since: Snowflake.epoch)
  }
  
  /// For backwards compatibility, use .rawValue instead
  @available(*, deprecated: 0.7, renamed: "rawValue")
  public var value: UInt64 {
    return rawValue
  }
  
  /// Discord's internal worker ID that generated this snowflake
  public var workerId: Int {
    return Int((rawValue & 0x3E0000) >> 17)
  }
  
  /// Initialize from a UInt64
  public init(_ snowflake: UInt64) {
    self.rawValue = snowflake
  }
  
  /// Initialize from a String
  public init?(_ string: String) {
    guard let snowflake = UInt64(string) else { return nil }
    self.init(snowflake)
  }
  
  /// Initialize from a String? (returns nil if the input was nil or if it failed to initialize)
  public init?(_ optionalString: String?) {
    guard let string = optionalString else { return nil }
    self.init(string)
  }
  
  /**
   Creates a fake snowflake that would have been created at the specified date
   Useful for things like the messages before/after/around endpoint
   
   - parameter date: The date to make a fake snowflake for
   - returns: A fake snowflake with the specified date, or nil if the specified date will not make a valid snowflake
  */
  public static func fakeSnowflake(date: Date) -> Snowflake? {
    let intervalSinceDiscordEpoch = Int64(date.timeIntervalSince(Snowflake.epoch) * 1000)
    guard intervalSinceDiscordEpoch > 0 else { return nil }
    guard intervalSinceDiscordEpoch < (1 << 41) else { return nil }
    return Snowflake(UInt64(intervalSinceDiscordEpoch) << 22)
  }
}

// MARK: Snowflake Conformances

/// Snowflake conformance to ExpressibleByIntegerLiteral
extension Snowflake : ExpressibleByIntegerLiteral {
  
  public typealias IntegerLiteralType = UInt64
  
  /// Initialize from an integer literal
  public init(integerLiteral value: UInt64) {
    self.rawValue = value
  }
}

/// Snowflake conformance to CustomStringConvertible
extension Snowflake : CustomStringConvertible {

  /// Description for string Conversion
  public var description: String {
    return self.rawValue.description
  }

}

/// Snowflake conformance to RawRepresentable
extension Snowflake : RawRepresentable, Equatable {

  public typealias RawValue = UInt64
  
  /// Init for rawValue conformance
  public init(rawValue: UInt64) {
    self.rawValue = rawValue
  }
  
}

/// Snowflake conformance to Comparable
extension Snowflake: Comparable {

  /// Used to compare Snowflakes (which is useful because a greater Snowflake was made later)
  public static func <(lhs: Snowflake, rhs: Snowflake) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }

}

/// Snowflake conformance to Hashable
extension Snowflake: Hashable {

  /// The hash value of the Snowflake
  public var hashValue: Int {
    return self.rawValue.hashValue
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
