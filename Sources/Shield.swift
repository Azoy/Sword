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
  var shieldOptions: ShieldOptions

  // MARK: Initializer

  /**
   Creates a Shield class to use commands with

   - parameter token: The bot's token
   - parameter swordOptions: SwordOptions structure to apply to bot
   - parameter shieldOptions: ShieldOptions structure to apply to command client
  */
  public init(token: String, swordOptions: SwordOptions = SwordOptions(), commandOptions shieldOptions: ShieldOptions = ShieldOptions()) {
    self.shieldOptions = shieldOptions
    super.init(token: token, with: swordOptions)

    self.on("messageCreate") { data in
      let msg = data[0] as! Message

      if self.shieldOptions.prefixes.contains("@bot") {
        self.shieldOptions.prefixes[self.shieldOptions.prefixes.index(of: "@bot")!] = "<@!\(self.user!.id)>"
      }

      for prefix in self.shieldOptions.prefixes {
        guard msg.content.hasPrefix(prefix) else { continue }

      }

    }
  }

  // MARK: Functions

  public func register(_ commandName: String, function: (Message, [String]) -> (), with options: [String: Any]) {

  }

}
