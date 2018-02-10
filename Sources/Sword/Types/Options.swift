//
//  Options.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

extension Sword {
  /// Customizable options used when setting up the bot
  public struct Options {
    /// Whether or not Sword will log messages concerning information about bot
    public let willLog: Bool
    
    /// Creates an Options structure
    ///
    /// - parameter willLog: Whether or not Sword will log messages
    public init(
      willLog: Bool = false
    ) {
      self.willLog = willLog
    }
  }
}
