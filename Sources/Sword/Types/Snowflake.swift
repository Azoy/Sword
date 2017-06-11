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
