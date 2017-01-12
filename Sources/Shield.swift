//
//  Shield.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Shield class that extends Sword
public class Shield: Sword {

  // MARK: Properties

  /// Shield Options structure
  var shieldOptions: [String: Any]

  // MARK: Initializer

  /**
   Creates a Shield class to use commands with

   - parameter token: The bot's token
   - parameter swordOptions: SwordOptions structure to apply to bot
   - parameter shieldOptions: ShieldOptions structure to apply to command client
  */
  public init(token: String, swordOptions: [String: Any] = [:], commandOptions shieldOptions: [String: Any] = [:]) {

    var baseOptions: [String: Any] = [
      "prefixes": ["@bot "]
    ]

    for (key, value) in shieldOptions {
      if baseOptions[key] != nil {
        baseOptions[key] = value
      }
    }

    self.shieldOptions = baseOptions

    super.init(token: token, with: swordOptions)

    self.on("messageCreate") { data in
      let msg = data[0] as! Message

      for prefix in (self.shieldOptions["prefixes"] as! [String]) {
        if msg.content.hasPrefix(prefix) {
          bot.send("\(msg.author.username) entered command: \(msg.content)")
        }
      }

    }
  }

  // MARK: Functions

  public func register(_ commandName: String, function: (Message, [String]) -> (), with options: [String: Any]) {

  }

}
