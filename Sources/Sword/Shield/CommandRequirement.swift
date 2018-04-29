//
//  CommandRequirement.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Defines the requirements that must be met in order to execute a command
public enum CommandRequirement {
  /// Whitelists a specific channel to use a command
  case channel(Snowflake)
  
  /// User controlled requirement that receives a Message and returns a Bool
  case custom((Message) -> Bool)
  
  /// Whitelists a specific guild to use a command
  case guild(Snowflake)
  
  /// Whitelists a specific role to use a command
  case role(Snowflake)
  
  /// Whitelists a specific user to use a command
  case user(Snowflake)
}
