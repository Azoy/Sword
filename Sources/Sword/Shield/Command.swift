//
//  Command.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Defines a new command for Sword to listen for
public protocol Command {
  /// The name of the command
  var name: String { get }
  
  /// Customizable options used to change the command
  var options: Sword.CommandOptions { get set }
  
  /// Executes the command once it has been validated
  ///
  /// - parameter msg: The message which triggered this command
  /// - parameter args: The arguments that followed this command
  func execute(msg: Sword.Message, args: [String])
}
