//
//  Permissions.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public struct Overwrite: Codable {
  public let allowed: UInt64
  public let denied: UInt64
  public let id: Snowflake
  public let type: Kind
  
  enum CodingKeys: String, CodingKey {
    case allowed = "allow"
    case denied = "deny"
    case id
    case type
  }
}

extension Overwrite {
  public enum Kind: String, Codable {
    case member
    case role
  }
}

public struct Role: Codable, _SwordChild {
  public internal(set) weak var sword: Sword?
  
  public let color: UInt32
  
  public var guild: Guild? {
    return sword?.getGuild(from: id, type: .role)
  }
  
  public let id: Snowflake
  public let isHoisted: Bool
  public let isManaged: Bool
  public let isMentionable: Bool
  public let name: String
  public let permissions: UInt64
  public let position: UInt16
  
  enum CodingKeys: String, CodingKey {
    case color
    case id
    case isHoisted = "hoist"
    case isManaged = "managed"
    case isMentionable = "mentionable"
    case name
    case permissions
    case position
  }
}
