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

  /// Whether or not the application is a bot or oauth bearer
  public var isBot = true

  /// Whether or not this bot will distribute it's shards across multiple process/machines
  public var isDistributed = false
  
  /// Array of event names to disable
  public var disabledEvents = [Event]()

  /// Whether or not caching offline members is allowed
  public var willCacheAllMembers = false

  /// Whether or not the bot will log to console
  public var willLog = false

  /// Whether or not this bot is sharded
  public var willShard = true

  /// MARK: Initializer

  /// Creates a default SwordOptions
  public init() {}

}

/// Shield Options structure
public struct ShieldOptions {

  // MARK: Properties
  
  /// Array of prefixes commands should start with
  public var prefixes = ["@bot"]

  /// Default requirement for commands
  public var requirements = CommandRequirements()

  /// Wether or not the bot will use case sensitive commands
  public var willBeCaseSensitive = true
  
  /// Whether or not to automatically create a help command
  public var willDefaultHelp = true
  
  /// Whether or not to ignore commands from bots
  public var willIgnoreBots = true

  // MARK: Initializer

  /// Creates a default ShieldOptions
  public init() {}

}

/// Command Options structure
public struct CommandOptions {

  // MARK: Properties

  /// Array of command aliases
  public var aliases = [String]()
  
  /// Used to describe the action of the command
  public var description = "No description"
  
  /// Wether or not the command is case sensitive or not
  public var isCaseSensitive: Bool? = nil

  /// Required command options
  public var requirements = CommandRequirements()

  /// Defines the separator used when parsing a command
  // public var separator = " "
  
  // MARK: Initializer

  /// Creates a default CommandOptions
  public init() {}

}

/// Command requirements, such as permissions, users, roles, etc
public struct CommandRequirements {

  /// Array of channels that can use this command
  public var channels = [Snowflake]()
  
  /// Array of guilds that can use this command
  public var guilds = [Snowflake]()
  
  /// Array of required permissions in order to use command
  public var permissions = [Permission]()

  /// Array of users that can use this command
  public var users = [Snowflake]()

}
