//
//  Shield.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Shield class that extends Sword
open class Shield: Sword {

  // MARK: Properties

  /// Object pointing command aliases to their respected full name
  public var commandAliases = [String: String]()

  /// Object pointing command names to their Command Object
  public var commands = [String: Command]()

  /// Shield Options structure
  public var shieldOptions: ShieldOptions

  // MARK: Initializer

  /**
   Creates a Shield class to use commands with

   - parameter token: The bot's token
   - parameter swordOptions: SwordOptions structure to apply to bot
   - parameter shieldOptions: ShieldOptions structure to apply to command client
  */
  public init(token: String, with swordOptions: SwordOptions = SwordOptions(), and shieldOptions: ShieldOptions = ShieldOptions()) {
    self.shieldOptions = shieldOptions
    super.init(token: token, with: swordOptions)

    self.on(.ready) { data in
      let bot = data[0] as! User

      if self.shieldOptions.prefixes.contains("@bot") {
        self.shieldOptions.prefixes.remove(at: self.shieldOptions.prefixes.index(of: "@bot")!)
        self.shieldOptions.prefixes.append("<@!\(bot.id)> ")
        self.shieldOptions.prefixes.append("<@\(bot.id)> ")
      }
    }

    self.on(.messageCreate, do: handle)
  }

  // MARK: Functions

  /**
   Handles MESSAGE_CREATE

   - parameter data: The [Any] that needs to be casted to Message to handle the message
  */
  func handle(message data: [Any]) {
    let msg = data[0] as! Message

    if self.shieldOptions.ignoreBots && msg.author?.isBot == true {
      return
    }

    if !self.shieldOptions.requirements.permissions.isEmpty {
      let permission = self.shieldOptions.requirements.permissions.map {
        $0.rawValue
      }.reduce(0, |)

      guard let permissions = msg.member?.permissions,
            permissions & permission > 0 else { return }
    }

    if !self.shieldOptions.requirements.users.isEmpty {
      guard let author = msg.author,
            self.shieldOptions.requirements.users.contains(author.id) else { return }
    }

    for prefix in self.shieldOptions.prefixes {
      guard msg.content.hasPrefix(prefix) else { continue }

      let content = msg.content.replacingOccurrences(of: prefix, with: "")
      var arguments = content.components(separatedBy: " ")

      var command = arguments.remove(at: 0)

      guard self.commands[command] != nil || self.commandAliases[command] != nil else { return }

      if self.commandAliases[command] != nil {
        command = self.commandAliases[command]!
      }

      if !self.commands[command]!.options.requirements.permissions.isEmpty {
        let permission = self.commands[command]!.options.requirements.permissions.map {
          $0.rawValue
        }.reduce(0, |)
        guard let permissions = msg.member?.permissions,
              permissions & permission > 0  else { return }
      }

      if !self.commands[command]!.options.requirements.users.isEmpty {
        guard let author = msg.author,
              self.commands[command]!.options.requirements.users.contains(author.id) else { return }
      }

      self.commands[command]!.function(msg, arguments)
    }
  }

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
