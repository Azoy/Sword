//
//  CommandRequirement.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Sword {
  /// Defines the requirements that must be met in order to execute a command
  public enum CommandRequirement {
    /// User controlled requirement that receives a Message and returns a Bool
    case custom((Message) -> Bool)
  }
}
