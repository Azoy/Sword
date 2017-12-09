//
//  User.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// User Type
public struct User {

  // MARK: Properties

  /// Parent class
  public internal(set) weak var sword: Sword?

  /// Avatar hash
  public let avatar: String?

  /// Whether or not this user is a bot
  public let isBot: Bool?

  /// Discriminator of user
  public let discriminator: String?

  /// Email of user (will probably be empty forever)
  public let email: String?

  /// ID of user
  public let id: Snowflake

  /// Whether of not user has mfa enabled (will probably be empty forever)
  public let isMfaEnabled: Bool?

  /// Username of user
  public let username: String?

  /// Whether user is verified or not
  public let isVerified: Bool?

  // MARK: Initializer

  /**
   Creates User struct

   - parameter sword: Parent class to get properties from
   - parameter json: JSON to decode into User struct
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.id = Snowflake(json["id"])!
    self.avatar = json["avatar"] as? String
    self.isBot = json["bot"] as? Bool
    self.discriminator = json["discriminator"] as? String
    self.email = json["email"] as? String
    self.isMfaEnabled = json["mfaEnabled"] as? Bool
    self.username = json["username"] as? String
    self.isVerified = json["verified"] as? Bool
  }

  // MARK: Functions
  
  /**
   Gets the link of the user's avatar
   
   - parameter format: File extension of the avatar (default png)
  */
  public func avatarUrl(format: FileExtension = .png) -> String? {
    guard let avatar = self.avatar else {
      return nil
    }
    
    return "https://cdn.discordapp.com/avatars/\(self.id)/\(avatar).\(format.rawValue)"
  }
  
  /// Gets DM for user
  public func getDM(then completion: @escaping (DM?, RequestError?) -> ()) {
    self.sword?.getDM(for: self.id, then: completion)
  }

}
