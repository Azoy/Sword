//
//  Guild.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public class Guild: Codable {
  public let afkChannelId: Snowflake?
  public let afkTimeout: UInt64
  public let defaultMessageNotificationLevel: DefaultMessageNotification
  public let embedChannelId: Snowflake?
  public let embedEnabled: Bool?
  public let explicitContentFilterLevel: ExplicitContentFilter
  public let icon: String?
  public let id: Snowflake
  public let isOwner: Bool?
  public let name: String
  public let ownerId: Snowflake
  public let permissions: UInt64?
  public let region: String
  public let splash: String?
  public let verificationLevel: Verification
}

extension Guild {
  public enum DefaultMessageNotification: UInt8, Codable {
    case all
    case mentions
  }
  
  public enum ExplicitContentFilter: UInt8, Codable {
    case disabled
    case withoutRoles
    case all
  }
  
  public enum MFA: UInt8, Codable {
    case none
    case elevated
  }
  
  public enum Verification: UInt8, Codable {
    case none
    case low
    case medium
    case high
    case veryHigh
  }
}
