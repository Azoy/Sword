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

  /// Array of event names to disable
  public var disabledEvents = [Event]()

  /// Whether or not caching offline members is allowed
  public var isCachingAllMembers = false

  /// Whether or not the bot will log to console
  public var isLogging = false

  /// Whether or not this bot is sharded
  public var isSharded = true

  /// Max amount of messages to cache in channels
  public var messageLimit = 0

  /// MARK: Initializer

  /// Creates a default SwordOptions
  public init() {}

}

/// Shield Options structure
public struct ShieldOptions {

  // MARK: Properties

  /// Whether or not to ignore commands from bots
  public var ignoreBots = true

  /// Array of prefixes commands should start with
  public var prefixes = ["@bot"]

  /// Default requirement for commands
  public var requirements = CommandRequirements()

  // MARK: Initializer

  /// Creates a default ShieldOptions
  public init() {}

}

/// Command Options structure
public struct CommandOptions {

  // MARK: Properties

  /// Array of command aliases
  public var aliases = [String]()

  /// Required command options
  public var requirements = CommandRequirements()

  // MARK: Initializer

  /// Creates a default CommandOptions
  public init() {}

}

/// Command requirements, such as permissions, users, roles, etc
public struct CommandRequirements {

  /// Array of required permissions in order to use command
  public var permissions = [Permission]()

  /// Array of users that can use this command
  public var users = [String]()

}
