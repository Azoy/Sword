//
//  User.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// User Type
public struct User {

  // MARK: Properties

  /// Parent class
  private weak var sword: Sword?

  /// Avatar hash
  public let avatar: String?

  /// The link of the user's avatar
  public let avatarUrl: String?

  /// Whether or not this user is a bot
  public let isBot: Bool?

  /// Discriminator of user
  public let discriminator: String?

  /// Email of user (will probably be empty forever)
  public let email: String?

  /// ID of user
  public let id: String

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

    self.id = json["id"] as! String
    self.avatar = json["avatar"] as? String
    self.isBot = json["bot"] as? Bool
    self.discriminator = json["discriminator"] as? String
    self.email = json["email"] as? String
    self.isMfaEnabled = json["mfaEnabled"] as? Bool
    self.username = json["username"] as? String
    self.isVerified = json["verified"] as? Bool

    guard self.avatar != nil else {
      self.avatarUrl = nil
      return
    }

    self.avatarUrl = "https://cdn.discordapp.com/avatars/\(self.id)/\(self.avatar!).png"
  }

  // MARK: Functions

  /// Gets DM for user
  public func getDM(_ completion: @escaping (DMChannel?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.createDM(), body: ["recipient_id": self.id].createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(DMChannel(self.sword!, data as! [String: Any]))
      }
    }
  }

}
