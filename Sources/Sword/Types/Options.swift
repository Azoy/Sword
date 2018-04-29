//
//  Options.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Customizable options used when setting up the bot
public struct Options {
  /// Customizable requirements that must be met in order to execute command
  public var commandRequirements: [CommandRequirement]
  
  /// An array of command prefixes
  public var prefixes: [String]
  
  /// Whether Sword will log messages concerning information about bot
  public var willLog: Bool
  
  /// Creates an Options structure
  ///
  /// - parameter prefixes: An array of command prefixes
  /// - parameter willLog: Whether or not Sword will log messages
  public init(
    commandRequirements: [CommandRequirement] = [],
    prefixes: [String] = ["@bot"],
    willLog: Bool = false
    ) {
    self.commandRequirements = commandRequirements
    self.prefixes = prefixes
    self.willLog = willLog
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
