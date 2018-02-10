//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Swift meets Discord
open class Sword {
  /// Customizable options used when setting up the bot
  public var options: Options
  
  /// Bot's Chuck E Cheese token to the magical world of Discord's API
  let token: String
  
  /// Instantiates a Sword instance
  ///
  /// - parameter token: The bot token used to connect to Discord's API
  /// - parameter options: Customizable options used when setting up the bot
  public init(token: String, options: Options) {
    self.options = options
    self.token = token
  }
}
