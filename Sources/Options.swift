//
//  Options.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Sword Options structure
open struct SwordOptions {

  // MARK: Properties

  /// Whether or not caching offline members is allowed
  open var isCacheAllMembers: Bool

  /// Array of event names to disable
  open var disabledEvents: [Event]

  /// Whether or not this bot is sharded
  open var isSharded: Bool

}

/// Shield Options structure
open struct ShieldOptions {

  // MARK: Properties

  /// Array of prefixes commands should start with
  open var prefixes: [String]

}

/// Command Options structure
open struct CommandOptions {

  // MARK: Properties

  /// Array of command aliases
  open var aliases: [String]

}
