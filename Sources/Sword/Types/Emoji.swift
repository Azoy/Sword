//
//  Emoji.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Emoji Type
public struct Emoji {
  
  // MARK: Properties
  
  /// ID of custom emoji
  public let id: Snowflake?
  
  /// Whether or not this emoji is managed
  public let managed: Bool?
  
  /// Name of the emoji
  public let name: String
  
  /// Whether this emoji requires colons to use
  public let requireColons: Bool?
  
  /// Array of roles that can use this emoji
  public internal(set) var roles = [Role]()
  
  /// Tag used for rest endpoints
  public var tag: String {
    guard let id = id else {
      return name
    }
    
    return "\(name):\(id)"
  }
  
  // MARK: Initializers
  
  /**
   Creates an Emoji structure
   
   - parameter json: JSON representable as a dictionary
  */
  init(_ json: [String: Any]) {
    self.id = Snowflake(json["id"])
    self.managed = json["managed"] as? Bool
    self.name = json["name"] as! String
    self.requireColons = json["require_colons"] as? Bool
    
    if let roles = json["roles"] as? [[String: Any]] {
      for role in roles {
        self.roles.append(Role(role))
      }
    }
  }
  
  /**
   Creates an Emoji structure for use with reactions
   
   - parameter name: Emoji unicode character or name (if custom)
   - parameter id: Emoji snowflake ID if custom (nil if unicode)
  */
  public init(_ name: String, id: Snowflake? = nil) {
    self.id = id
    self.name = name
    self.managed = nil
    self.requireColons = nil
  }
}
