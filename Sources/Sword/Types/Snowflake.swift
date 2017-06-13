//
//  Snowflake.swift
//  Sword
//


/// The stored type of a Discord Snowflake ID.
public typealias Snowflake = UInt64

extension Snowflake {
  init?(_ optionalString: String?) {
    guard let string = optionalString else { return nil }
    guard let snowflake = Snowflake(string) else { return nil }
    self = snowflake
  }
}

/// Used to check whether a string equals a Snowflake
public func ==(lhs: Snowflake, rhs: String) -> Bool {
  return lhs == Snowflake(rhs)
}

/// Used to check whether a string equals a Snowflake
public func ==(lhs: Snowflake?, rhs: String) -> Bool {
  guard let lhs = lhs else { return false }
  return lhs == Snowflake(rhs)
}

/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: Snowflake, rhs: String) -> Bool {
  return lhs != Snowflake(rhs)
}

/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: Snowflake?, rhs: String) -> Bool {
  guard let lhs = lhs else { return false }
  return lhs != Snowflake(rhs)
}

/// Used to check whether a string equals a Snowflake
public func ==(lhs: String, rhs: Snowflake) -> Bool {
  return Snowflake(lhs) == rhs
}

/// Used to check whether a string equals a Snowflake
public func ==(lhs: String, rhs: Snowflake?) -> Bool {
  guard let rhs = rhs else { return false }
  return Snowflake(lhs) == rhs
}

/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: String, rhs: Snowflake) -> Bool {
  return Snowflake(lhs) != rhs
}

/// Used to check whether a string does not equals a Snowflake
public func !=(lhs: String, rhs: Snowflake?) -> Bool {
  guard let rhs = rhs else { return false }
  return Snowflake(lhs) != rhs
}
