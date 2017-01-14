//
//  Command.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Command structure
public struct Command {

  // MARK: Properties

  /// Function to execute once command is called
  public let function: (Message, [String]) -> ()

  /// Name of the command
  public let name: String

  /// Options of the command
  public let options: CommandOptions

  // MARK: Initializer

  /**
   Creates command structure

   - parameter name: Name of the command
   - parameter function: Function to be called once command is called
   - parameter options: Options to give the command
  */
  init(name: String, function: @escaping (Message, [String]) -> (), options: CommandOptions) {
    self.function = function
    self.name = name
    self.options = options
  }

}
