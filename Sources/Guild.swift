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
  public weak var sword: Sword?

  /// ID of afk voice channel (if there is any)
  public let afkChannelId: String?

  /// AFK timeout (if there is any)
  public let afkTimeout: Int?

  /// Collection of channels mapped by channel ID
  public internal(set) var channels: [String: GuildChannel] = [:]

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

    self.id = json["id"] as! String

    self.afkChannelId = json["afk_channel_id"] as? String
    self.afkTimeout = json["afk_timeout"] as? Int

    if let channels = json["channels"] as? [[String: Any]] {
      for channel in channels {
        var returnChannel = channel
        returnChannel["guild_id"] = self.id
        let channel = GuildChannel(sword, returnChannel)
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
   Bans a member from this guild

   #### Option Params ####

   - **delete-message-days**: Number of days to delete messages for (0-7)

   - parameter userId: Member to ban
   - parameter options: Deletes messages from this user by amount of days
  */
  public func ban(member userId: String, with options: [String: Int] = [:], completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildBan(self.id, userId), body: options.createBody(), method: "PUT") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Creates a channel in this guild

   #### Option Params ####

   - **name**: The name to give this channel
   - **type**: The type of channel to create
   - **bitrate**: If a voice channel, sets the bitrate for the voice channel
   - **user_limit**: If a voice channel, sets the maximum amount of users to be allowed at a time
   - **permission_overwrites**: Array of overwrite objects to give this channel

   - parameter options: Preconfigured options to give the channel on create
  */
  public func createChannel(with options: [String: Any], completion: @escaping (RequestError?, GuildChannel?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildChannel(self.id), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, GuildChannel(self.sword!, data as! [String: Any]))
      }
    }
  }

  /**
   Creates an integration for this guild

   #### Option Params ####

   - **type**: The type of integration to create
   - **id**: The id of the user's integration to link to this guild

   - parameter options: Preconfigured options for this integration
  */
  public func createIntegration(with options: [String: String], completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildIntegration(self.id), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Creates a guild role

   #### Option Params ####

   - **name**: The name of the role
   - **permissions**: The bitwise number to set role with
   - **color**: Integer value of RGB color
   - **hoist**: Whether or not this role is hoisted on the member list
   - **mentionable**: Whether or not this role is mentionable in chat

   - parameter options: Preset options to configure role with
  */
  public func createRole(with options: [String: Any], completion: @escaping (RequestError?, Role?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.createGuildRole(self.id), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Role(data as! [String: Any]))
      }
    }
  }

  /**
   Deletes an integration from this guild

   - parameter integrationId: Integration to delete
  */
  public func delete(integration integrationId: String, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteGuildIntegration(self.id, integrationId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Deletes a role from this guild

   - parameter roleId: Role to delete
  */
  public func delete(role roleId: String, completion: @escaping (RequestError?, Role?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteGuildRole(self.id, roleId), method: "DELETE") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Role(data as! [String: Any]))
      }
    }
  }

  /// Deletes current guild
  public func delete(completion: @escaping (RequestError?, Guild?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteGuild(self.id), method: "DELETE") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let guild = Guild(self.sword!, data as! [String: Any], self.shard)
        self.sword!.guilds.removeValue(forKey: self.id)
        completion(nil, guild)
      }
    }
  }

  /// Gets guild's bans
  public func getBans(completion: @escaping (RequestError?, [User]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildBans(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self.sword!, user))
        }

        completion(nil, returnUsers)
      }
    }
  }

  /// Gets the guild embed
  public func getEmbed(completion: @escaping (RequestError?, [String: Any]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildEmbed(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? [String: Any])
      }
    }
  }

  /// Gets guild's integrations
  public func getIntegrations(completion: @escaping (RequestError?, [[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildIntegrations(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? [[String: Any]])
      }
    }
  }

  /// Gets guild's invites
  public func getInvites(completion: @escaping (RequestError?, [[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildInvites(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? [[String: Any]])
      }
    }
  }

  /// Gets an array of guild members
  public func getMembers(completion: @escaping (RequestError?, [Member]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.listGuildMembers(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnMembers: [Member] = []
        let members = data as! [[String: Any]]
        for member in members {
          returnMembers.append(Member(self.sword!, self, member))
        }

        completion(nil, returnMembers)
      }
    }
  }

  /**
   Gets number of users who would be pruned by x amount of days

   - parameter limit: Number of days to get prune count for
  */
  public func getPruneCount(for limit: Int, completion: @escaping (RequestError?, Int?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildPruneCount(self.id), body: ["days": limit].createBody()) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? Int)
      }
    }
  }

  /// Gets guild roles
  public func getRoles(completion: @escaping (RequestError?, [Role]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildRoles(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(nil, returnRoles)
      }
    }
  }

  /// Gets an array of voice regions from guild
  public func getVoiceRegions(completion: @escaping (RequestError?, [[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildVoiceRegions(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? [[String: Any]])
      }
    }
  }

  /// Gets guild's webhooks
  public func getWebhooks(completion: @escaping (RequestError?, [[String: Any]]?) -> ()) {
    self.sword!.requester.request(self.sword!.endpoints.getGuildWebhooks(self.id)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? [[String: Any]])
      }
    }
  }

  /**
   Modifies an integration from this guild

   #### Option Params ####

   - **expire_behavior**: The behavior when an integration subscription lapses (see the [integration](https://discordapp.com/developers/docs/resources/guild#integration-object) object documentation)
   - **expire_grace_period**: Period (in seconds) where the integration will ignore lapsed subscriptions
   - **enable_emoticons**: Whether emoticons should be synced for this integration (twitch only currently), true or false

   - parameter integrationId: Integration to modify
   - parameter options: Preconfigured options to modify this integration with
  */
  public func modify(integration integrationId: String, with options: [String: Any], completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildIntegration(self.id, integrationId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Modifies a member from this guild

   #### Options Params ####

   - **nick**: The nickname to assign
   - **roles**: Array of role id's that should be assigned to the member
   - **mute**: Whether or not to server mute the member
   - **deaf**: Whether or not to server deafen the member
   - **channel_id**: If the user is connected to a voice channel, assigns them the new voice channel they are to connect.

   - parameter userId: Member to modify
   - parameter options: Preconfigured options to modify member with
  */
  public func modify(member userId: String, with options: [String: Any], completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildMember(self.id, userId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Modifies a role from this guild

   #### Options Params ####

   - **name**: The name to assign to the role
   - **permissions**: The bitwise permission integer
   - **color**: RGB int color value to assign to the role
   - **hoist**: Whether or not this role should be hoisted on the member list
   - **mentionable**: Whether or not this role should be mentionable by everyone

   - parameter roleId: Role to modify
   - parameter options: Preconfigured options to modify guild roles with
  */
  public func modify(role roleId: String, with options: [String: Any], completion: @escaping (RequestError?, Role?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildRole(self.id, roleId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Role(data as! [String: Any]))
      }
    }
  }

  /**
   Modifies current guild

   #### Options Params ####

   - **name**: The name to assign to the guild
   - **region**: The region to set this guild to
   - **verification_level**: The guild verification level integer
   - **default_message_notifications**: The guild default message notification settings integer
   - **afk_channel_id**: The channel id to assign afks
   - **afk_timeout**: The amount of time in seconds to afk a user in voice
   - **icon**: The icon in base64 string
   - **owner_id**: The user id to make own of this server
   - **splash**: If a VIP server, the splash image in base64 to assign

   - parameter options: Preconfigured options to modify guild with
  */
  public func modify(with options: [String: Any], completion: @escaping (RequestError?, Guild?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuild(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let guild = Guild(self.sword!, data as! [String: Any], self.shard)
        self.sword!.guilds[self.id] = guild
        completion(nil, guild)
      }
    }
  }

  /**
   Modifies channel positions

   #### Options Params ####

   Array of the following:

   - **id**: The channel id to modify
   - **position**: The sorting position of the channel

   - parameter options: Preconfigured options to set channel positions to
  */
  public func modifyChannelPositions(with options: [[String: Any]], completion: @escaping (RequestError?, [GuildChannel]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildChannelPositions(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnChannels: [GuildChannel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(GuildChannel(self.sword!, channel))
        }

        completion(nil, returnChannels)
      }
    }
  }

  /**
   Modifies role positions

   #### Options Params ####

   Array of the following:

   - **id**: The role id to edit position
   - **position**: The sorting position of the role

   - parameter options: Preconfigured options to set role positions to
  */
  public func modifyRolePositions(with options: [[String: Any]], completion: @escaping (RequestError?, [Role]?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildRolePositions(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(nil, returnRoles)
      }
    }
  }

  /**
   Moves a member to another voice channel (if they are in one)

   - parameter channelId: The Id of the channel to send them to
  */
  public func move(member userId: String, to channelId: String, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyGuildMember(self.id, userId), body: ["channel_id": channelId].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Prunes members for x amount of days

   - parameter limit: Amount of days for prunned users
  */
  public func prune(for limit: Int, completion: @escaping (RequestError?, Int?) -> () = {_ in}) {
    if limit < 1 {
      completion(.unknown, nil)
      return
    }
    self.sword!.requester.request(self.sword!.endpoints.beginGuildPrune(self.id), body: ["days": limit].createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as? Int)
      }
    }
  }

  /**
   Removes member from this guild

   - parameter userId: Member to remove from server
  */
  public func remove(member userId: String, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.removeGuildMember(self.id, userId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Syncs an integration from this guild

   - parameter integrationId: Integration to sync
  */
  public func sync(integration integrationId: String, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.syncGuildIntegration(self.id, integrationId), method: "POST") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Unbans a user from this guild

   - parameter userId: User to unban
  */
  public func unban(member userId: String, completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.removeGuildBan(self.id, userId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
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
