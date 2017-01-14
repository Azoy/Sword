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
  public var isCacheAllMembers: Bool

  /// The cache limit for messages (hold the last 10 messages for example)
  public var cacheMessageLimit: Int

  /// Array of event names to disable
  public var disabledEvents: [String]

  /// Whether or not this bot is sharded
  public var isSharded: Bool

  // MARK: Initializer

  /**
   Creates Sword Options structure

   - parameter cacheAllMembers: Whether or not to cache offline members
   - parameter cacheMessageLimit: The cache limit for messages to store
   - parameter disabledEvents: Array of event names to disable (improve performance)
   - parameter sharded: Whether or not the bot should be sharded
  */
  public init(cacheAllMembers: Bool = false, cacheMessageLimit: Int = 50, disabledEvents: [String] = [], sharded: Bool = true) {
    self.isCacheAllMembers = cacheAllMembers
    self.cacheMessageLimit = cacheMessageLimit
    self.disabledEvents = disabledEvents
    self.isSharded = sharded
  }

}

/// Shield Options structure
public struct ShieldOptions {

  // MARK: Properties

  /// Array of prefixes commands should start with
  public var prefixes: [String]

  // MARK: Initializer

  /**
   Creates a Shield Options structure

   - parameter prefixes: Array of prefixes commands should start with
  */
  public init(prefixes: [String] = ["@bot"]) {
    self.prefixes = prefixes
  }

}

/// Command Options structure
public struct CommandOptions {

  // MARK: Properties

  /// Array of command aliases
  public var aliases: [String]

  // MARK: Initializer

  /**
   Creates Command Options structure

   - parameter aliases: Array of command aliases
  */
  public init(aliases: [String] = []) {
    self.aliases = aliases
  }

}
