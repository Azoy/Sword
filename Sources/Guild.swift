//
//  Guild.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Guild Type
public class Guild {

  // MARK: Properties

  /// Parent class
  private weak var sword: Sword?

  /// ID of afk voice channel (if there is any)
  public let afkChannelId: String?

  /// AFK timeout (if there is any)
  public let afkTimeout: Int?

  /// Collection of channels mapped by channel ID
  public internal(set) var channels: [String: Channel] = [:]

  /// Default notification protocol
  public let defaultMessageNotifications: Int

  /// ID of embeddable channel
  public let embedChannelId: Int?

  /// Array of custom emojis for this guild
  public internal(set) var emojis: [Emoji] = []

  /// Array of features this guild has
  public private(set) var features: [String] = []

  /// Icon hash for guild
  public let icon: String?

  /// ID of guild
  public let id: String

  /// Whether or not this guild is embeddable
  public let isEmbedEnabled: Bool?

  /// Whether or not this guild is considered "large"
  public let isLarge: Bool?

  /// The date at which the bot joined the server
  public let joinedAt: Date?

  /// Amount of members this guild has
  public let memberCount: Int

  /// Collection of members mapped by user ID
  public internal(set) var members: [String: Member] = [:]

  /// MFA level of guild
  public let mfaLevel: Int

  /// Name of the guild
  public let name: String

  /// Owner's user ID
  public let ownerId: String

  /// Region this guild is hosted in
  public let region: String

  /// Collection of roles mapped by role ID
  public internal(set) var roles: [String: Role] = [:]

  /// Shard ID this guild is handled by
  public let shard: Int?

  /// Splash Hash for guild
  public let splash: String?

  /// Level of verification for guild
  public let verificationLevel: Int

  // MARK: Initializer

  /**
   Creates a Guild structure

   - parameter sword: Parent class
   - parameter json: JSON representable as a dictionary
   - parameter shard: Shard ID this guild is handled by
   */
  init(_ sword: Sword, _ json: [String: Any], _ shard: Int? = nil) {
    self.sword = sword

    self.afkChannelId = json["afk_channel_id"] as? String
    self.afkTimeout = json["afk_timeout"] as? Int

    if let channels = json["channels"] as? [[String: Any]] {
      for channel in channels {
        let channel = Channel(sword, channel)
        self.channels[channel.id] = channel
      }
    }

    self.defaultMessageNotifications = json["default_message_notifications"] as! Int
    self.embedChannelId = json["embed_channel_id"] as? Int
    self.isEmbedEnabled = json["embed_enabled"] as? Bool

    if let emojis = json["emojis"] as? [[String: Any]] {
      for emoji in emojis {
        self.emojis.append(Emoji(emoji))
      }
    }

    if let features = json["features"] as? [String] {
      for feature in features {
        self.features.append(feature)
      }
    }

    self.icon = json["icon"] as? String
    self.id = json["id"] as! String

    if let joinedAt = json["joined_at"] as? String {
      self.joinedAt = joinedAt.date
    }else {
      self.joinedAt = nil
    }

    self.isLarge = json["large"] as? Bool
    self.memberCount = json["member_count"] as! Int

    self.mfaLevel = json["mfa_level"] as! Int
    self.name = json["name"] as! String
    self.ownerId = json["owner_id"] as! String

    self.region = json["region"] as! String

    let roles = json["roles"] as! [[String: Any]]
    for role in roles {
      let role = Role(role)
      self.roles[role.id] = role
    }

    self.shard = shard
    self.splash = json["splash"] as? String
    self.verificationLevel = json["verification_level"] as! Int

    if let members = json["members"] as? [[String: Any]] {
      for member in members {
        let member = Member(sword, self, member)
        self.members[member.user.id] = member
      }
    }

    let presences = json["presences"] as! [[String: Any]]
    for presence in presences {
      let userId = (presence["user"] as! [String: Any])["id"] as! String
      let presence = Presence(presence)
      self.members[userId]!.presence = presence
    }

    let voiceStates = json["voice_states"] as? [[String: Any]]
    if voiceStates != nil {
      for voiceState in voiceStates! {
        let voiceStateObjc = VoiceState(voiceState)

        self.members[voiceState["user_id"] as! String]!.voiceState = voiceStateObjc
      }
    }
  }

  // MARK: Functions

  /**
   Adds a member to this guild

   - parameter userId: Member to add
   - parameter options: ["nick": "nickname to give", "roles": ["roleidshere"], "mute": false, "deaf": false]
   */
  public func add(member userId: String, with options: [String: Any] = [:], _ completion: @escaping (Member?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.addGuildMember(self.id, userId), body: options.createBody(), method: "PUT") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Member(self.sword!, self, data as! [String: Any]))
      }
    }
  }

  /**
   Bans a member from this guild

   - parameter userId: Member to ban
   - parameter options: Delete messages from this user ["delete-message-days": 5]
   */
  public func ban(member userId: String, with options: [String: Int] = [:], _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildBan(self.id, userId), body: options.createBody(), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Creates a channel in this guild

   - parameter options: ["name": "nameofchannel", "type": "voice" || "text", "user_limit": 5]
   */
  public func createChannel(with options: [String: Any], _ completion: @escaping (Channel?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildChannel(self.id), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Channel(self.sword!, data as! [String: Any]))
      }
    }
  }

  /**
   Creates an integration for this guild

   - parameter options: ["type": "twitch, youtube..etc", "id": "user integration id"]
   */
  public func createIntegration(with options: [String: String], _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildIntegration(self.id), body: options.createBody(), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /// Creates a guild role
  public func createRole(_ completion: @escaping (Role?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildRole(self.id), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Role(data as! [String: Any]))
      }
    }
  }

  /**
   Deletes an integration from this guild

   - parameter integrationId: Integration to delete
   */
  public func delete(integration integrationId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteGuildIntegration(self.id, integrationId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Deletes a role from this guild

   - parameter roleId: Role to delete
   */
  public func delete(role roleId: String, _ completion: @escaping (Role?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteGuildRole(self.id, roleId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Role(data as! [String: Any]))
      }
    }
  }

  /// Deletes current guild
  public func delete(_ completion: @escaping (Guild?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteGuild(self.id), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let guild = Guild(self.sword!, data as! [String: Any], self.shard)
        self.sword!.guilds.removeValue(forKey: self.id)
        completion(guild)
      }
    }
  }

  /// Gets guild's bans
  public func getBans(_ completion: @escaping ([User]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildBans(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self.sword!, user))
        }

        completion(returnUsers)
      }
    }
  }

  /// Gets the guild embed
  public func getEmbed(_ completion: @escaping ([String: Any]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildEmbed(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [String: Any])
      }
    }
  }

  /// Gets guild's integrations
  public func getIntegrations(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildIntegrations(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /// Gets guild's invites
  public func getInvites(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildInvites(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /// Gets an array of guild members
  public func getMembers(_ completion: @escaping ([Member]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.listGuildMembers(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnMembers: [Member] = []
        let members = data as! [[String: Any]]
        for member in members {
          returnMembers.append(Member(self.sword!, self, member))
        }

        completion(returnMembers)
      }
    }
  }

  /**
   Gets number of users who would be pruned by x amount of days

   - parameter limit: Number of days to get prune count for
   */
  public func getPruneCount(for limit: Int, _ completion: @escaping (Int?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildPruneCount(self.id), body: ["days": limit].createBody()) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? Int)
      }
    }
  }

  /// Gets guild roles
  public func getRoles(_ completion: @escaping ([Role]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildRoles(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(returnRoles)
      }
    }
  }

  /// Gets an array of voice regions from guild
  public func getVoiceRegions(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildVoiceRegions(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /// Gets guild's webhooks
  public func getWebhooks(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildWebhooks(self.id)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /**
   Modifies an integration from this guild

   - parameter integrationId: Integration to modify
   - parameter options: ["expire_grace_period": 60 (seconds in which integration will ignore lapsed subscription), "enable_emoticons": true (whether or not they should be enabled)]
   */
  public func modify(integration integrationId: String, with options: [String: Any], _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildIntegration(self.id, integrationId), body: options.createBody(), method: "PATCH") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Modifies a member from this guild

   - parameter userId: Member to modify
   - parameter options: ["nick": "nickname for user", "roles": ["roleids"], "mute": true, "deaf": true, "channel_id": "id of voice channel to move user"]
   */
  public func modify(member userId: String, with options: [String: Any], _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildMember(self.id, userId), body: options.createBody(), method: "PATCH") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Modifies a role from this guild

   - parameter roleId: Role to modify
   - parameter options: ["name": "name of role", "permissions": 8 (permission number for role), "position": 1 (role position number), "color": 16777215 (Int value for RGB), "hoist": true, "mentionable": true]
   */
  public func modify(role roleId: String, with options: [String: Any], _ completion: @escaping (Role?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildRole(self.id, roleId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Role(data as! [String: Any]))
      }
    }
  }

  /**
   Modifies current guild

   - parameter options: ["name": "name of guild", "afk_channel_id": "channel id", "afk_timeout": 300 (seconds), "icon": "base64 string of img", "splash": "base64 string of img"]
   */
  public func modify(with options: [String: Any], _ completion: @escaping (Guild?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuild(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let guild = Guild(self.sword!, data as! [String: Any], self.shard)
        self.sword!.guilds[self.id] = guild
        completion(guild)
      }
    }
  }

  /**
   Modifies channel positions

   - parameter options: [["id": "channel id", "position": 0]]
   */
  public func modifyChannelPositions(with options: [[String: Any]], _ completion: @escaping ([Channel]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildChannelPositions(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnChannels: [Channel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(Channel(self.sword!, channel))
        }

        completion(returnChannels)
      }
    }
  }

  /**
   Modifies role positions

   - parameter options: [["id": "role id", "position": 0]]
   */
  public func modifyRolePositions(with options: [[String: Any]], _ completion: @escaping ([Role]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildRolePositions(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(returnRoles)
      }
    }
  }

  /**
   Prunes members for x amount of days

   - parameter limit: Amount of days for prunned users
   */
  public func prune(for limit: Int, _ completion: @escaping (Int?) -> () = {_ in}) {
    if limit < 1 { completion(nil); return }
    self.sword!.requester.request(self.sword!.endpoints.beginGuildPrune(self.id), body: ["days": limit].createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? Int)
      }
    }
  }

  /**
   Removes member from this guild

   - parameter userId: Member to remove from server
   */
  public func remove(member userId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.removeGuildMember(self.id, userId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Syncs an integration from this guild

   - parameter integrationId: Integration to sync
   */
  public func sync(integration integrationId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.syncGuildIntegration(self.id, integrationId), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /**
   Unbans a user from this guild

   - parameter userId: User to unban
   */
  public func unban(member userId: String, _ completion: @escaping () -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.removeGuildBan(self.id, userId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

}

/// UnavailableGuild Type
public struct UnavailableGuild {

  // MARK: Properties

  /// ID of this guild
  public let id: Int

  /// ID of shard this guild is handled by
  public let shard: Int

  // MARK: Initializer

  /**
   Creates an UnavailableGuild structure

   - parameter json: JSON representable as a dictionary
   - parameter shard: Shard ID this guild is handled by
   */
  init(_ json: [String: Any], _ shard: Int) {
    self.id = Int(json["id"] as! String)!
    self.shard = shard
  }

}

/// Emoji Type
public struct Emoji {

  // MARK: Properties

  /// ID of custom emoji
  public let id: String

  /// Whether or not this emoji is managed
  public let managed: Bool

  /// Name of the emoji
  public let name: String

  /// Whether this emoji requires colons to use
  public let requireColons: Bool

  /// Array of roles that can use this emoji
  public var roles: [Role] = []

  // MARK: Initializer

  /**
   Creates an Emoji structure

   - parameter json: JSON representable as a dictionary
   */
  init(_ json: [String: Any]) {
    self.id = json["id"] as! String
    self.managed = json["managed"] as! Bool
    self.name = json["name"] as! String
    self.requireColons = json["require_colons"] as! Bool

    if let roles = json["roles"] as? [[String: Any]] {
      for role in roles {
        self.roles.append(Role(role))
      }
    }
  }

}
