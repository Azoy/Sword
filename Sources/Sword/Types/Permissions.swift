//
//  Permissions.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public struct Role: Codable {
  public let color: UInt32
  public let id: Snowflake
  public let isHoisted: Bool
  public let isManaged: Bool
  public let isMentionable: Bool
  public let name: String
  public let permissions: UInt64
  public let position: UInt16
}
