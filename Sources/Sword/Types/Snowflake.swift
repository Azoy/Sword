//
//  Snowflake.swift
//  Sword
//


/// The stored type of a Discord Snowflake ID.
public struct Snowflake {
  /// The internal ID storage for a snowflake
  public let id: UInt64
  
  /// Initialize from a UInt64
  public init(_ snowflake: UInt64) {
    self.id = snowflake
  }
  
  /// Initialize from a string
  public init?(_ string: String) {
    guard let snowflake = UInt64(string) else { return nil }
    self.id = snowflake
  }
  
  /// Initialize from an optional string (returns nil if the input was nil or if it failed to initialize)
  init?(_ optionalString: String?) {
    guard let string = optionalString else { return nil }
    guard let snowflake = Snowflake(string) else { return nil }
    self = snowflake
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
    return self.id.description
  }
  
}

/// Snowflake conformance to Comparable
extension Snowflake : Comparable {
  
  /// Used to check whether two Snowflakes are equal
  public static func ==(lhs: Snowflake, rhs: Snowflake) -> Bool {
    return lhs.id == rhs.id
  }

  /// Used to compare Snowflakes (which is useful because a greater Snowflake was made later)
  public static func <(lhs: Snowflake, rhs: Snowflake) -> Bool {
    return lhs.id < rhs.id
  }
  
}

/// Snowflake conformance to Hashable
extension Snowflake : Hashable {
  
  /// The hash value of the Snowflake
  public var hashValue: Int {
    return self.id.hashValue
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
