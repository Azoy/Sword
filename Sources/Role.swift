//
//  Role.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2016 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Role Type
public struct Role {

  // MARK: Properties
  
  /// Color of role as an Int
  public let color: Int
  
  /// Whether or not this role is hoisted
  public let hoist: Bool
  
  /// ID of the role
  public let id: String
  
  /// Whether or not this role is managed
  public let managed: Bool
  
  /// Whether or not this role is mentionable
  public let mentionable: Bool
  
  /// The name of the role
  public let name: String
  
  /// The permission number for this role
  public let permissions: Int
  
  /// The position for this role
  public let position: Int

  // MarK: Initializer
  
  /**
   Creates Role struct
   
   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.color = json["color"] as! Int
    self.hoist = json["hoist"] as! Bool
    self.id = json["id"] as! String
    self.managed = json["managed"] as! Bool
    self.mentionable = json["mentionable"] as! Bool
    self.name = json["name"] as! String
    self.permissions = json["permissions"] as! Int
    self.position = json["position"] as! Int
  }

}
