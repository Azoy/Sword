//
//  Options.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Customizable options used when setting up the bot
public struct Options {
  /// Customizable requirements that must be met in order to execute all
  /// commands
  public var commandRequirements: [CommandRequirement]
  
  /// Whether Sword will log messages concerning information about bot
  public var logging: Bool
  
  /// Whether or not Shards will ask for `"compress": true` in initial
  /// identify with gateway
  public var payloadCompression: Bool
  
  /// An array of command prefixes
  public var prefixes: [String]
  
  /// Whether or not Shards will ask for `&compress=zlib-stream` in initial
  /// gateway handshake
  public var transportCompression: Bool
  
  /// Creates an Options structure
  ///
  /// - parameter commandRequirements: An array of command requirements
  /// - parameter logging: Whether or not Sword will log messages
  /// - parameter payloadCompression: `"compress: true"` or not in identify
  /// - parameter prefixes: An array of command prefixes
  /// - parameter transportCompression: `&compress=zlib-stream` or not in ws url
  public init(
    commandRequirements: [CommandRequirement] = [],
    logging: Bool = false,
    payloadCompression: Bool = true,
    prefixes: [String] = ["@bot"],
    transportCompression: Bool = true
  ) {
    self.commandRequirements = commandRequirements
    self.logging = logging
    self.payloadCompression = payloadCompression
    self.prefixes = prefixes
    self.transportCompression = transportCompression
  }
}

/// Customizable options used when setting up a command
public struct CommandOptions {
  /// An array of command aliases ("?" for "help")
  public let aliases: [String]
  
  /// Whether this command is case sensitive
  public var isCaseSensitive: Bool
  
  /// Customizable requirements that must be met in order to execute command
  public var requirements: [CommandRequirement]
  
  /// Creates a CommandOptions structure
  ///
  /// - parameter aliases: An array of command aliases
  /// - parameter isCaseSensitive: Whether this command is case sensitive
  public init(
    aliases: [String] = [],
    isCaseSensitive: Bool = false,
    requirements: [CommandRequirement] = []
  ) {
    self.aliases = aliases
    self.isCaseSensitive = isCaseSensitive
    self.requirements = requirements
  }
}
