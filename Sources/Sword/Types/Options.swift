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

  /// Whether or not caching offline members is allowed
  public var willCacheAllMembers = false

  /// Whether or not the bot will log to console
  public var willLog = false

  /// Whether or not to shard this bot
  public var willShard = true

  /// MARK: Initializer

  /// Creates a default SwordOptions
  public init(
    isBot: Bool = true,
    isDistributed: Bool = false,
    willCacheAllMembers: Bool = false,
    willLog: Bool = false,
    willShard: Bool = true
  ) {
    self.isBot = isBot
    self.isDistributed = isDistributed
    self.willCacheAllMembers = willCacheAllMembers
    self.willLog = willLog
    self.willShard = willShard
  }

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
  public init(
    prefixes: [String] = ["@bot"],
    requirements: CommandRequirements = CommandRequirements(),
    willBeCaseSensitive: Bool = true,
    willDefaultHelp: Bool = true,
    willIgnoreBots: Bool = true
  ) {
    self.prefixes = prefixes
    self.requirements = requirements
    self.willBeCaseSensitive = willBeCaseSensitive
    self.willDefaultHelp = willDefaultHelp
    self.willIgnoreBots = willIgnoreBots
  }
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
  public init(
    aliases: [String] = [],
    description: String = "No description",
    isCaseSensitive: Bool? = nil,
    requirements: CommandRequirements = CommandRequirements()
  ) {
    self.aliases = aliases
    self.description = description
    self.isCaseSensitive = isCaseSensitive
    self.requirements = requirements
  }

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

  // MARK: Initializer
  
  /// Creates a default CommandRequirements
  public init(
    channels: [Snowflake] = [],
    guilds: [Snowflake] = [],
    permissions: [Permission] = [],
    users: [Snowflake] = []
  ) {
    self.channels = channels
    self.guilds = guilds
    self.permissions = permissions
    self.users = users
  }
  
}
