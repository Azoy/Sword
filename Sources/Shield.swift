//
//  Shield.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Shield class that extends Sword
open class Shield: Sword {

  // MARK: Properties

  /// Object pointing command aliases to their respected full name
  public var commandAliases: [String: String] = [:]

  /// Object pointing command names to their Command Object
  public var commands: [String: Command] = [:]

  /// Shield Options structure
  public var shieldOptions: ShieldOptions

  // MARK: Initializer

  /**
   Creates a Shield class to use commands with

   - parameter token: The bot's token
   - parameter swordOptions: SwordOptions structure to apply to bot
   - parameter shieldOptions: ShieldOptions structure to apply to command client
  */
  public init(token: String, swordOptions: SwordOptions = SwordOptions(), shieldOptions: ShieldOptions = ShieldOptions()) {
    self.shieldOptions = shieldOptions
    super.init(token: token, with: swordOptions)

    self.on(.messageCreate) { data in
      let msg = data[0] as! Message

      if self.shieldOptions.prefixes.contains("@bot") {
        self.shieldOptions.prefixes[self.shieldOptions.prefixes.index(of: "@bot")!] = "<@!\(self.user!.id)>"
        self.shieldOptions.prefixes[self.shieldOptions.prefixes.index(of: "@bot")!] = "<@\(self.user!.id)>"
      }

      for prefix in self.shieldOptions.prefixes {
        guard msg.content.hasPrefix(prefix) else { continue }

        var content = msg.content.substring(from: msg.content.index(msg.content.startIndex, offsetBy: prefix.characters.count))
        if content.hasPrefix(" ") {
          content = content.substring(from: content.index(content.startIndex, offsetBy: 1))
        }
        var command = content.components(separatedBy: " ")

        var commandName = command[0]
        command.remove(at: 0)

        guard self.commands[commandName] != nil || self.commandAliases[commandName] != nil else { return }

        if self.commandAliases[commandName] != nil {
          commandName = self.commandAliases[commandName]!
        }

        self.commands[commandName]!.function(msg, command)
      }

    }
  }

  // MARK: Functions

  /**
   Registers a command

   - parameter commandName: Name to give command
   - parameter options: Options to give command
   - parameter function: Function to execute once command is sent
  */
  public func register(_ commandName: String, with options: CommandOptions = CommandOptions(), _ function: @escaping (Message, [String]) -> ()) {
    self.commands[commandName] = Command(name: commandName, function: function, options: options)

    if !options.aliases.isEmpty {
      for alias in options.aliases {
        self.commandAliases[alias] = commandName
      }
    }
  }

  /**
   Registers a command

   - parameter commandName: Name to give command
   - parameter options: Options to give command
   - parameter message: String to send on command
  */
  public func register(_ commandName: String, with options: CommandOptions = CommandOptions(), message: String) {
    let function: (Message, [String]) -> () = { msg, args in
      self.send(message, to: msg.channel.id)
    }

    self.commands[commandName] = Command(name: commandName, function: function, options: options)

    if !options.aliases.isEmpty {
      for alias in options.aliases {
        self.commandAliases[alias] = commandName
      }
    }
  }

  /**
   Unregisters a command

   - parameter commandName: Command to get rid of
  */
  public func unregister(_ commandName: String) {
    for (key, value) in self.commandAliases {
      if value == commandName {
        self.commandAliases.removeValue(forKey: key)
      }
    }
    self.commands.removeValue(forKey: commandName)
  }

}
