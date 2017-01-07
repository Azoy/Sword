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
  }

}
