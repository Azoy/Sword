//
//  Role.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Role Type
public struct Role {

  // MARK: Properties

  /// Color of role as an Int
  public let color: Int

  /// ID of the role
  public let id: Snowflake

  /// Whether or not this role is hoisted
  public let isHoisted: Bool

  /// Whether or not this role is managed
  public let isManaged: Bool

  /// Whether or not this role is mentionable
  public let isMentionable: Bool

  /// The name of the role
  public let name: String

  /// The permission number for this role
  public let permissions: Int

  /// The position for this role
  public let position: Int

  // MARKK: Initializer

  /**
   Creates Role struct

   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.color = json["color"] as! Int
    self.isHoisted = json["hoist"] as! Bool
    self.id = Snowflake(json["id"])!
    self.isManaged = json["managed"] as! Bool
    self.isMentionable = json["mentionable"] as! Bool
    self.name = json["name"] as! String
    self.permissions = json["permissions"] as! Int
    self.position = json["position"] as! Int
  }

}
