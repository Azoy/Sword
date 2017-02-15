//
//  Options.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Sword Options structure
public struct SwordOptions {

  // MARK: Properties

  /// Whether or not caching offline members is allowed
  public var isCachingAllMembers = false

  /// Array of event names to disable
  public var disabledEvents: [Event] = []

  /// Whether or not this bot is sharded
  public var isSharded = true

  // MARK: Initializer

  /// Creates a default SwordOptions structure
  public init() {}

}

/// Shield Options structure
public struct ShieldOptions {

  // MARK: Properties

  /// Array of prefixes commands should start with
  public var prefixes = ["@bot"]

  // MARK: Initializer

  /// Creates a default ShieldOptions structure
  public init() {}

}

/// Command Options structure
public struct CommandOptions {

  // MARK: Properties

  /// Array of command aliases
  public var aliases: [String] = []

  // MARK: Initializer

  /// Creates a default CommandOptions structure
  public init() {}

}
