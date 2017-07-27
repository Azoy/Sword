//
//  Command.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Command Interface
public protocol Commandable {
  
  /// The name of this command
  var name: String { get set }
  
  /// Set of command options
  var options: CommandOptions { get set }
  
  /// The actual function called when someone does a command
  func execute(_ msg: Message, _ args: [String])
  
}

/// Used for dynamically added commands
public struct GenericCommand: Commandable {
  
  /// Used as setting the action
  public var function: (Message, [String]) -> ()
  
  /// The name of the command
  public var name: String
  
  /// Set of command options
  public var options: CommandOptions
  
  /// This is what is called on a successful command request
  public func execute(_ msg: Message, _ args: [String]) {
    self.function(msg, args)
  }
  
}
