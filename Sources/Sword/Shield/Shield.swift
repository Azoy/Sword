//
//  Shield.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

// RIP Shield
extension Sword {
  /// Registers a command
  ///
  /// - parameter command: Command structure to register
  public func registerCommand(_ command: Command) {
    commandMap[command.name.lowercased()] = command
    
    for alias in command.options.aliases {
      commandMap[alias.lowercased()] = command
    }
  }
}
