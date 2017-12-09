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
  public var commandAliases = [String: (casePreserved: String, target: String)]()

  /// Object pointing command names to their Command Object
  public var commands = [String: Commandable]()

  /// Shield Options structure
  public var shieldOptions: ShieldOptions

  // MARK: Initializer

  /**
   Creates a Shield class to use commands with
   
   - parameter token: The bot's token
   - parameter swordOptions: SwordOptions structure to apply to bot
   - parameter shieldOptions: ShieldOptions structure to apply to command client
  */
  public init(
    token: String,
    with swordOptions: SwordOptions = SwordOptions(),
    and shieldOptions: ShieldOptions = ShieldOptions()
  ) {
    self.shieldOptions = shieldOptions
    
    super.init(token: token, with: swordOptions)
    
    if self.shieldOptions.willDefaultHelp {
      self.registerHelp()
    }
    
    self.on(.ready) { [unowned self] data in
      let bot = data as! User

      if self.shieldOptions.prefixes.contains("@bot") {
        self.shieldOptions.prefixes.remove(
          at: self.shieldOptions.prefixes.index(of: "@bot")!
        )
        self.shieldOptions.prefixes.append("<@!\(bot.id)> ")
        self.shieldOptions.prefixes.append("<@\(bot.id)> ")
      }
      
      _ = self.listeners[.ready]!.remove(at: 0)
    }

    self.on(.messageCreate) { [unowned self] data in
      guard self.commands.count > 0 else { return }
      
      self.handle(message: data)
    }
  }

  // MARK: Functions

  /**
   Handles MESSAGE_CREATE

   - parameter data: The Any that needs to be casted to Message to handle the message
  */
  func handle(message data: Any) {
    let msg = data as! Message

    if self.shieldOptions.willIgnoreBots && msg.author?.isBot == true {
      return
    }

    if !self.shieldOptions.requirements.channels.isEmpty {
      guard !self.shieldOptions.requirements.channels.contains(msg.channel.id) else {
        return
      }
    }
    
    if !self.shieldOptions.requirements.guilds.isEmpty {
      guard let guildChannel = msg.channel as? GuildChannel,
        !self.shieldOptions.requirements.guilds.contains(guildChannel.guild!.id) else {
        return
      }
    }
    
    if !self.shieldOptions.requirements.permissions.isEmpty {
      let permission = self.shieldOptions.requirements.permissions.lazy.map {
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

      let content = String(msg.content[msg.content.range(of: prefix)!.upperBound...])
      var arguments = content.components(separatedBy: " ")

      var commandString = arguments.remove(at: 0)

      let originalCommand = commandString
      var correctCaseAlias: String? = nil
      commandString = commandString.lowercased()
      
      if self.commands[commandString] == nil {
        if let alias = self.commandAliases[commandString] {
          commandString = alias.target
          correctCaseAlias = alias.casePreserved
        }
      }
      
      guard let command = self.commands[commandString] else { return }

      let correctCaseCommand = correctCaseAlias ?? command.name

      if let isCaseSensitive = command.options.isCaseSensitive, isCaseSensitive {
        guard correctCaseCommand == originalCommand else { return }
      } else if self.shieldOptions.willBeCaseSensitive {
        guard correctCaseCommand == originalCommand else { return }
      }

      if !command.options.requirements.channels.isEmpty {
        guard !command.options.requirements.channels.contains(msg.channel.id) else {
          return
        }
      }
      
      if !command.options.requirements.guilds.isEmpty {
        guard let guildChannel = msg.channel as? GuildChannel,
          !command.options.requirements.guilds.contains(guildChannel.guild!.id) else {
            return
        }
      }
      
      if !command.options.requirements.permissions.isEmpty {
        let requiredPermission = command.options.requirements.permissions.lazy.map {
          $0.rawValue
        }.reduce(0, |)

        guard let permissions = msg.member?.permissions,
          permissions & requiredPermission > 0  else { return }
      }

      if !command.options.requirements.users.isEmpty {
        guard let author = msg.author,
          command.options.requirements.users.contains(author.id) else { return }
      }

      command.execute(msg, arguments)
    }
  }
  
  /**
   Registers a command
   
   - parameter command: The structure that conforms to `Commandable`
  */
  public func register(_ command: Commandable) {
    self.commands[command.name.lowercased()] = command
    
    if !command.options.aliases.isEmpty {
      for alias in command.options.aliases {
        self.commandAliases[alias.lowercased()] = (alias, command.name.lowercased())
      }
    }
  }
  
  /**
   Registers a command
   
   - parameter commandName: Name to give command
   - parameter options: Options to give command
   - parameter function: Function to execute once command is sent
  */
  public func register(
    _ commandName: String,
    with options: CommandOptions = CommandOptions(),
    _ function: @escaping (Message, [String]) -> ()
  ) {
    self.commands[commandName.lowercased()] = GenericCommand(
      function: function,
      name: commandName,
      options: options
    )

    if !options.aliases.isEmpty {
      for alias in options.aliases {
        self.commandAliases[alias.lowercased()] = (alias, commandName.lowercased())
      }
    }
  }

  /**
   Registers a command
   
   - parameter commandName: Name to give command
   - parameter options: Options to give command
   - parameter message: String to send on command
  */
  public func register(
    _ commandName: String,
    with options: CommandOptions = CommandOptions(),
    message: String
  ) {
    let function: (Message, [String]) -> () = { msg, args in
      msg.reply(with: message)
    }

    self.commands[commandName.lowercased()] = GenericCommand(
      function: function,
      name: commandName,
      options: options
    )

    if !options.aliases.isEmpty {
      for alias in options.aliases {
        self.commandAliases[alias.lowercased()] = (alias, commandName.lowercased())
      }
    }
  }
  
  /// Creates a default help command for the bot
  func registerHelp() {
    self.register("help") { [unowned self] msg, args in
      var embed = Embed()
      embed.title = "\(self.user!.username!)'s Help"
      
      for command in self.commands.values {
        embed.addField(
          command.name,
          value: command.options.description,
          inline: true
        )
      }
      
      msg.channel.send(embed)
    }
  }
  
  /**
   Unregisters a command
   
   - parameter commandName: Command to get rid of
  */
  public func unregister(_ commandName: String) {
    guard self.commands[commandName] != nil else {
      return
    }

    for (key, value) in self.commandAliases {
      if value.target == commandName {
        self.commandAliases.removeValue(forKey: key)
      }
    }

    self.commands.removeValue(forKey: commandName)
  }

}
