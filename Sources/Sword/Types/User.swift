//
//  User.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Represents a Discord user
public struct User: Codable {
  /// User's avatar hash
  public let avatar: String?
  
  /// User's 4 digit discord-tag
  public let discriminator: String
  
  /// User's email
  public let email: String?
  
  /// User's ID
  public let id: Snowflake
  
  /// Whether the user belongs to an OAuth2 App
  public let isBot: Bool?
  
  /// Whether the user has two factor enabled on their account
  public let isMfaEnabled: Bool?
  
  /// Whether the email on this account has been verified
  public let isVerified: Bool?
  
  /// User's username, not unique across Discord
  public let username: String
  
  /// Used to map json keys to swift keys
  enum CodingKeys: String, CodingKey {
    case avatar
    case discriminator
    case email
    case id
    case isBot = "bot"
    case isMfaEnabled = "mfa_enabled"
    case isVerified = "verified"
    case username
  }
  
  /// Instantiates a User structure from the given json object
  ///
  /// - parameter json: JSON object representing User
  init?(_ json: JSON) {
    self.avatar = json.avatar?.string
    
    guard let discrim = json.discriminator?.string else {
      Sword.log(.warning, "Received user object without a discriminator")
      Sword.log(.info, "\(json)")
      return nil
    }
    
    self.discriminator = discrim
    self.email = json.email?.string
    
    guard let id = json.id?.uint64 else {
      Sword.log(.warning, "Received user object without an id")
      return nil
    }
    
    self.id = Snowflake(rawValue: id)
    self.isBot = json.bot?.bool
    self.isMfaEnabled = json.mfa_enabled?.bool
    self.isVerified = json.verified?.bool
    
    guard let username = json.username?.string else {
      Sword.log(.warning, "Received user object without a username")
      return nil
    }
    
    self.username = username
  }
}
