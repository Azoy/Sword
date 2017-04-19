//
//  Sword.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Main Class for Sword
open class Sword: Eventable {

  // MARK: Properties

  /// Collection of DMChannels mapped by user id
  public internal(set) var dms = [String: DMChannel]()

  /// The gateway url to connect to
  var gatewayUrl: String?

  /// Array of guilds the bot is currently connected to
  public internal(set) var guilds = [String: Guild]()

  /// Event listeners
  public var listeners = [Event: [([Any]) -> ()]]()

  /// Optional options to apply to bot
  var options: SwordOptions

  /// Timestamp of ready event
  public internal(set) var readyTimestamp: Date?

  /// Requester class
  let requester: Request

  /// Amount of shards to initialize
  public internal(set) var shardCount = 1

  /// Array of Shard class
  var shards = [Shard]()

  /// How many shards are ready
  var shardsReady = 0

  /// The bot token
  let token: String

  /// Array of unavailable guilds the bot is currently connected to
  public internal(set)var unavailableGuilds = [String: UnavailableGuild]()

  /// Int in seconds of how long the bot has been online
  public var uptime: Int? {
    if self.readyTimestamp != nil {
      return Int((Date() - self.readyTimestamp!.timeIntervalSince1970).timeIntervalSince1970)
    }else {
      return nil
    }
  }

  /// The user account for the bot
  public internal(set) var user: User?

  /// Array of users mapped by userId that the bot sees
  public internal(set) var users = [String: User]()

  #if !os(iOS)

  /// Object of voice connections the bot is currently connected to. Mapped by guildId
  public var voiceConnections: [String: VoiceConnection] {
    return self.voiceManager.connections
  }

  /// Voice handler
  let voiceManager = VoiceManager()

  #endif

  // MARK: Initializer

  /**
   Initializes the Sword class

   - parameter token: The bot token
   - parameter options: Options to give bot (sharding, offline members, etc)
  */
  public init(token: String, with options: SwordOptions = SwordOptions()) {
    self.options = options
    self.requester = Request(token)
    self.token = token
  }

  // MARK: Functions

  /// Gets the gateway URL to connect to
  func getGateway(then completion: @escaping ([String: Any]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.gateway(), rateLimited: false) { data, error in
      if error != nil {
        completion(nil, error)
        return
      }

      guard let data = data as? [String: Any] else {
        completion(nil, .unknown)
        return
      }

      completion(data, nil)
    }
  }

  /// Starts the bot
  public func connect() {
    self.getGateway() { [unowned self] data, error in
      if error != nil {
        guard error == .unauthorized else {
          sleep(3)
          self.connect()
          return
        }

        print("[Sword] Bot token invalid.")
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"

        if self.options.isSharded {
          self.shardCount = data!["shards"] as! Int
        }else {
          self.shardCount = 1
        }

        for id in 0..<self.shardCount {
          let shard = Shard(self, id, self.shardCount)
          self.shards.append(shard)
          shard.startWS(self.gatewayUrl!)
        }

      }
    }
  }

  /**
   Adds a reaction (unicode or custom emoji) to a message

   - parameter reaction: Unicode or custom emoji reaction
   - parameter messageId: Message to add reaction to
   - parameter channelId: Channel to add reaction to message in
  */
  public func addReaction(_ reaction: String, to messageId: String, in channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createReaction(channelId, messageId, reaction), method: "PUT") { data, error in
      completion(error)
    }
  }

  /**
   Bans a member from a guild

   #### Option Params ####

   - **delete-message-days**: Number of days to delete messages for (0-7)

   - parameter userId: Member to ban
   - parameter guildId: Guild to ban member in
   - parameter options: Deletes messages from this user by amount of days
  */
  public func ban(_ userId: String, in guildId: String, with options: [String: Int] = [:], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createGuildBan(guildId, userId), body: options, method: "PUT") { data, error in
      completion(error)
    }
  }

  /**
   Creates a channel in a guild

   #### Option Params ####

   - **name**: The name to give this channel
   - **type**: The type of channel to create
   - **bitrate**: If a voice channel, sets the bitrate for the voice channel
   - **user_limit**: If a voice channel, sets the maximum amount of users to be allowed at a time
   - **permission_overwrites**: Array of overwrite objects to give this channel

   - parameter guildId: Guild to create channel for
   - parameter options: Preconfigured options to give the channel on create
  */
  public func createChannel(for guildId: String, with options: [String: Any], then completion: @escaping (GuildChannel?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createGuildChannel(guildId), body: options, method: "POST") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(GuildChannel(self, data as! [String: Any]), error)
      }
    }
  }

  /**
   Creates a guild

   - parameter options: Refer to [discord docs](https://discordapp.com/developers/docs/resources/guild#create-guild) for guild options
  */
  public func createGuild(with options: [String: Any], then completion: @escaping (Guild?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createGuild(), body: options, method: "POST") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Guild(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Creates an integration for a guild

   #### Option Params ####

   - **type**: The type of integration to create
   - **id**: The id of the user's integration to link to this guild

   - parameter guildId: Guild to create integration for
   - parameter options: Preconfigured options for this integration
  */
  public func createIntegration(for guildId: String, with options: [String: String], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createGuildIntegration(guildId), body: options, method: "POST") { data, error in
      completion(error)
    }
  }

  /**
   Creates an invite for channel

   #### Options Params ####

   - **max_age**: Duration in seconds before the invite expires, or 0 for never. Default 86400 (24 hours)
   - **max_uses**: Max number of people who can use this invite, or 0 for unlimited. Default 0
   - **temporary**: Whether or not this invite gives you temporary access to the guild. Default false
   - **unique**: Whether or not this invite has a unique invite code. Default false

   - parameter channelId: Channel to create invite for
   - parameter options: Options to give invite
  */
  public func createInvite(for channelId: String, with options: [String: Any] = [:], then completion: @escaping ([String: Any]?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createChannelInvite(channelId), body: options, method: "POST") { data, error in
      completion(data as? [String: Any], error)
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

   - parameter guildId: Guild to create role for
   - parameter options: Preset options to configure role with
  */
  public func createRole(for guildId: String, with options: [String: Any], then completion: @escaping (Role?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createGuildRole(guildId), body: options, method: "POST") { data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Role(data as! [String: Any]), nil)
      }
    }
  }

  /**
   Creates a webhook for a channel

   #### Options Params ####

   - **name**: The name of the webhook
   - **avatar**: The avatar string to assign this webhook in base64

   - parameter channelId: Guild channel to create webhook for
   - parameter options: Preconfigured options to create this webhook with
  */
  public func createWebhook(for channelId: String, with options: [String: String] = [:], then completion: @escaping (Webhook?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.createWebhook(channelId), body: options, method: "POST") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Webhook(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Deletes a channel

   - parameter channelId: Channel to delete
  */
  public func deleteChannel(_ channelId: String, then completion: @escaping (Channel?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteChannel(channelId), method: "DELETE") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipients"] == nil {
          completion(GuildChannel(self, channelData), nil)
        }else {
          completion(DMChannel(self, channelData), nil)
        }
      }
    }
  }

  /**
   Deletes a guild

   - parameter guildId: Guild to delete
  */
  public func deleteGuild(_ guildId: String, then completion: @escaping (Guild?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteGuild(guildId), method: "DELETE") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds.removeValue(forKey: guild.id)
        completion(guild, nil)
      }
    }
  }

  /**
   Deletes an integration from a guild

   - parameter integrationId: Integration to delete
   - parameter guildId: Guild to delete integration from
  */
  public func deleteIntegration(_ integrationId: String, from guildId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteGuildIntegration(guildId, integrationId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Deletes an invite

   - parameter inviteId: Invite to delete
  */
  public func deleteInvite(_ inviteId: String, then completion: @escaping ([String: Any]?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteInvite(inviteId), method: "DELETE") { data, error in
      completion(data as? [String: Any], error)
    }
  }

  /**
   Deletes a message from a channel

   - parameter messageId: Message to delete
  */
  public func deleteMessage(_ messageId: String, from channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteMessage(channelId, messageId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Bulk deletes messages

   - parameter messages: Array of message ids to delete
  */
  public func deleteMessages(_ messages: [String], from channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    for message in messages {
      let oldestMessage = (Date().timeIntervalSince1970 - 1421280000000) * 4194304
      guard let messageId = Double(message) else {
        completion(.unknown)
        return
      }
      if messageId < oldestMessage {
        completion(.unknown)
      }
    }

    self.requester.request(Endpoints.bulkDeleteMessages(channelId), body: ["messages": messages], method: "POST") { data, error in
      completion(error)
    }
  }

  /**
   Deletes an overwrite permission for a channel

   - parameter channelId: Channel to delete permissions from
   - parameter overwriteId: Overwrite ID to use for permissons
  */
  public func deletePermission(from channelId: String, with overwriteId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteChannelPermission(channelId, overwriteId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Deletes a reaction from a message by user

   - parameter reaction: Unicode or custom emoji to delete
   - parameter messageId: Message to delete reaction from
   - parameter userId: If nil, deletes bot's reaction from, else delete a reaction from user
   - parameter channelId: Channel to delete reaction from
  */
  public func deleteReaction(_ reaction: String, from messageId: String, by userId: String? = nil, in channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    var url = ""
    if userId != nil {
      url = Endpoints.deleteUserReaction(channelId, messageId, reaction, userId!)
    }else {
      url = Endpoints.deleteOwnReaction(channelId, messageId, reaction)
    }

    self.requester.request(url, method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Deletes all reactions from a message

   - parameter messageId: Message to delete all reactions from
   - parameter channelId: Channel to remove reactions in
  */
  public func deleteReactions(from messageId: String, in channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteAllReactions(channelId, messageId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Deletes a role from this guild

   - parameter roleId: Role to delete
   - parameter guildId: Guild to delete role from
  */
  public func deleteRole(_ roleId: String, from guildId: String, then completion: @escaping (Role?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteGuildRole(guildId, roleId), method: "DELETE") { data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Role(data as! [String: Any]), nil)
      }
    }
  }

  /**
   Deletes a webhook

   - parameter webhookId: Webhook to delete
  */
  public func deleteWebhook(_ webhookId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deleteWebhook(webhookId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Edits a message's content

   - parameter messageId: Message to edit
   - parameter content: Text to change message to
   - parameter channelId: Channel to edit message in
  */
  public func editMessage(_ messageId: String, to content: String, in channelId: String, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.editMessage(channelId, messageId), body: ["content": content], method: "PATCH") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Message(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
    Edits a channel's overwrite permission

   #### Option Params ####

   - **allow**: The bitwise allowed permissions
   - **deny**: The bitwise denied permissions
   - **type**: 'member' for a user, or 'role' for a role

   - parameter permissions: ["allow": perm#, "deny": perm#, "type": "role" || "member"]
   - parameter channelId: Channel to edit permissions for
   - parameter overwriteId: Overwrite ID to use for permissions
  */
  public func editPermissions(_ permissions: [String: Any], for channelId: String, with overwriteId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.editChannelPermissions(channelId, overwriteId), body: permissions, method: "PUT") { data, error in
      completion(error)
    }
  }

  /**
   Edits bot status
   - parameter status: Status to set bot to. Either .online (default), .idle, .dnd, .invisible
   - parameter game: ["name": "with Swords!", "type": 0 || 1]
  */
  public func editStatus(to status: Presence.Status = .online, playing game: [String: Any]? = nil) {
    guard self.shards.count > 0 else { return }
    var data: [String: Any] = ["afk": status == .idle, "game": NSNull(), "since": status == .idle ? Date().milliseconds : 0, "status": status.rawValue]

    if game != nil {
      data["game"] = game
    }

    let payload = Payload(op: .statusUpdate, data: data).encode()

    for shard in self.shards {
      shard.send(payload, presence: true)
    }
  }

  /**
   Executs a slack style webhook

   #### Content Params ####

   Refer to the [slack documentation](https://api.slack.com/incoming-webhooks) for their webhook structure

   - parameter webhookId: Webhook to execute
   - parameter webhookToken: Token for auth to execute
   - parameter content: The slack webhook content to send
  */
  public func executeSlackWebhook(_ webhookId: String, token webhookToken: String, with content: [String: Any], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.executeSlackWebhook(webhookId, webhookToken), body: content, method: "POST") { data, error in
      completion(error)
    }
  }

  /**
   Executes a webhook

   #### Content Params ####

   - **content**: Message to send
   - **username**: The username the webhook will send with the message
   - **avatar_url**: The url of the user the webhook will send
   - **tts**: Whether or not this message is tts
   - **file**: The url of the image to send
   - **embed**: The embed object to send. Refer to [Embed structure](https://discordapp.com/developers/docs/resources/channel#embed-object)

   - parameter webhookId: Webhook to execute
   - parameter webhookToken: Token for auth to execute
   - parameter content: String or dictionary containing message content
  */
  public func executeWebhook(_ webhookId: String, token webhookToken: String, with content: Any, then completion: @escaping (RequestError?) -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      self.requester.request(Endpoints.executeWebhook(webhookId, webhookToken), body: ["content": content], method: "POST") { data, error in
        completion(error)
      }
      return
    }
    var file = ""
    var parameters = [String: String]()

    if message["file"] != nil {
      file = message["file"] as! String
    }
    if message["content"] != nil {
      parameters["content"] = (message["content"] as! String)
    }
    if message["tts"] != nil {
      parameters["tts"] = (message["tts"] as! String)
    }
    if message["embed"] != nil {
      parameters["embeds"] = [(message["embed"] as! [String: Any])].encode()
    }
    if message["username"] != nil {
      parameters["username"] = (message["user"] as! String)
    }
    if message["avatar_url"] != nil {
      parameters["avatar_url"] = (message["avatar_url"] as! String)
    }

    self.requester.request(Endpoints.executeWebhook(webhookId, webhookToken), body: parameters, file: file, method: "POST") { data, error in
      completion(error)
    }

  }

  /**
   Gets a guild's bans

   - parameter guildId: Guild to get bans from
  */
  public func getBans(from guildId: String, then completion: @escaping ([User]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildBans(guildId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self, user))
        }

        completion(returnUsers, nil)
      }
    }
  }

  /**
   Either get a cached channel or restfully get a channel

   - parameter channelId: Channel to get
  */
  public func getChannel(_ channelId: String, rest: Bool = false, then completion: @escaping (Channel?, RequestError?) -> ()) {
    guard rest else {
      let guild = self.getGuild(for: channelId)
      let dm = self.getDM(for: channelId)

      guard guild != nil else {
        guard dm != nil else {
          completion(nil, .unknown)
          return
        }

        completion(dm, nil)
        return
      }

      completion(guild!.channels[channelId]!, nil)
      return
    }

    self.requester.request(Endpoints.getChannel(channelId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipients"] == nil {
          completion(GuildChannel(self, channelData), nil)
        }else {
          completion(DMChannel(self, channelData), nil)
        }
      }
    }
  }

  /**
   Gets a channel's invites

   - parameter channelId: Channel to get invites from
  */
  public func getChannelInvites(from channelId: String, then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getChannelInvites(channelId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Either get cached channels from guild

   - parameter guildId: Guild to get channels from
  */
  public func getChannels(from guildId: String, rest: Bool = false, then completion: @escaping ([GuildChannel]?, RequestError?) -> ()) {
    guard rest else {
      guard self.guilds[guildId] != nil else {
        completion(nil, nil)
        return
      }

      completion(Array(self.guilds[guildId]!.channels.values), nil)
      return
    }

    self.requester.request(Endpoints.getGuildChannels(guildId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnChannels: [GuildChannel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(GuildChannel(self, channel))
        }

        completion(returnChannels, nil)
      }
    }
  }

  /**
   Function to get dm from channelId

   - parameter channelId: Channel to get dm from
  */
  public func getDM(for channelId: String) -> DMChannel? {
    var dms = self.dms.filter {
      $0.1.id == channelId
    }

    if dms.isEmpty { return nil }
    return dms[0].1
  }

  /**
   Gets a DM for a user

   - parameter userId: User to get DM for
  */
  public func getDM(for userId: String, then completion: @escaping (DMChannel?, RequestError?) -> ()) {
    self.requester.request(Endpoints.createDM(), body: ["recipient_id": userId], method: "POST") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let dm = DMChannel(self, data as! [String: Any])
        self.dms[userId] = dm
        completion(dm, nil)
      }
    }
  }

  /**
   Function to get guild from channelId

   - parameter channelId: Channel to get guild from
  */
  public func getGuild(for channelId: String) -> Guild? {
    var guilds = self.guilds.filter {
      $0.1.channels[channelId] != nil
    }

    if guilds.isEmpty { return nil }
    return guilds[0].1
  }

  /**
   Either get a cached guild or restfully get a guild

   - parameter guildId: Guild to get
  */
  public func getGuild(_ guildId: String, rest: Bool = false, then completion: @escaping (Guild?, RequestError?) -> ()) {
    guard rest else {
      completion(self.guilds[guildId], nil)
      return
    }

    self.requester.request(Endpoints.getGuild(guildId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds[guild.id] = guild
        completion(guild, nil)
      }
    }
  }

  /**
   Gets a guild's embed

   - parameter guildId: Guild to get embed from
  */
  public func getGuildEmbed(from guildId: String, then completion: @escaping ([String: Any]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildEmbed(guildId)) { data, error in
      completion(data as? [String: Any], error)
    }
  }

  /**
   Gets a guild's invites

   - parameter guildId: Guild to get invites from
  */
  public func getGuildInvites(from guildId: String, then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildInvites(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /// Either get cached guilds or restfully get guilds
  public func getGuilds(rest: Bool = false, then completion: @escaping ([Guild]?, RequestError?) -> ()) {
    guard rest else {
      completion(Array(self.guilds.values), nil)
      return
    }

    self.requester.request(Endpoints.getCurrentUserGuilds()) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnGuilds: [Guild] = []
        let guilds = data as! [[String: Any]]
        for guild in guilds {
          returnGuilds.append(Guild(self, guild, self.getShard(for: guild["id"] as! String)))
        }

        completion(returnGuilds, nil)
      }
    }
  }

  /**
   Gets a guild's webhooks

   - parameter guildId: Guild to get webhooks from
  */
  public func getGuildWebhooks(from guildId: String, then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildWebhooks(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Gets a guild's integrations

   - parameter guildId: Guild to get integrations from
  */
  public func getIntegrations(from guildId: String, then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildIntegrations(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Gets an invite

   - parameter inviteId: Invite to get
  */
  public func getInvite(_ inviteId: String, then completion: @escaping ([String: Any]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getInvite(inviteId)) { data, error in
      completion(data as? [String: Any], error)
    }
  }

  /**
   Gets a member from guild

   - parameter userId: Member to get
   - parameter guildId: Guild to get member from
  */
  public func getMember(_ userId: String, in guildId: String, then completion: @escaping (Member?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildMember(guildId, userId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let member = Member(self, self.guilds[guildId]!, data as! [String: Any])
        completion(member, nil)
      }
    }
  }

  /**
   Gets an array of guild members in a guild

   - parameter guildId: Guild to get members from
  */
  public func getMembers(in guildId: String, then completion: @escaping ([Member]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.listGuildMembers(guildId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnMembers: [Member] = []
        let members = data as! [[String: Any]]
        for member in members {
          returnMembers.append(Member(self, self.guilds[guildId]!, member))
        }

        completion(returnMembers, nil)
      }
    }
  }

  /**
   Gets a message from channel

   - parameter messageId: Message to get
   - parameter channelId: Channel to get message from
  */
  public func getMessage(_ messageId: String, from channelId: String, then completion: @escaping (Message?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getChannelMessage(channelId, messageId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Message(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Gets an array of messages from channel

   - parameter limit: Amount of messages to get
   - parameter channelId: Channel to get messages from
  */
  public func getMessages(_ limit: Int, from channelId: String, then completion: @escaping ([Message]?, RequestError?) -> ()) {
    if limit > 100 || limit < 1 {
      completion(nil, .unknown)
      return
    }
    self.requester.request(Endpoints.getChannelMessages(channelId), body: ["limit": limit]) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }
        completion(returnMessages, nil)
      }
    }
  }

  /**
   Get pinned messages from a channel

   - parameter channelId: Channel to get pinned messages fromn
  */
  public func getPinnedMessages(from channelId: String, then completion: @escaping ([Message]?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.getPinnedMessages(channelId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }

        completion(returnMessages, nil)
      }
    }
  }

  /**
   Gets number of users who would be pruned by x amount of days in a guild

   - parameter guildId: Guild to get prune count for
   - parameter limit: Number of days to get prune count for
  */
  public func getPruneCount(from guildId: String, for limit: Int, then completion: @escaping (Int?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildPruneCount(guildId), body: ["days": limit]) { data, error in
      completion(data as? Int, error)
    }
  }

  /**
   Gets an array of users who used reaction from message

   - parameter reaction: Unicode or custom emoji to get
   - parameter messageId: Message to get reaction users from
   - parameter channelId: Channel to get reaction from
  */
  public func getReaction(_ reaction: String, from messageId: String, in channelId: String, then completion: @escaping ([User]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getReactions(channelId, messageId, reaction)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnUsers: [User] = []
        let users = data as! [[String: Any]]
        for user in users {
          returnUsers.append(User(self, user))
        }

        completion(returnUsers, nil)
      }
    }
  }

  /**
   Gets a guild's roles

   - parameter guildId: Guild to get roles from
  */
  public func getRoles(from guildId: String, then completion: @escaping ([Role]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildRoles(guildId)) { data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(returnRoles, nil)
      }
    }
  }

  /**
   Gets shard that is handling a guild

   - parameter guildId: Guild to get shard for
  */
  public func getShard(for guildId: String) -> Int {
    return (Int(guildId)! >> 22) & self.shardCount
  }

  /**
   Either get a cached user or restfully get a user

   - parameter userId: User to get
  */
  public func getUser(_ userId: String, rest: Bool = false, then completion: @escaping (User?, RequestError?) -> ()) {
    guard rest else {
      completion(self.users[userId], nil)
      return
    }

    self.requester.request(Endpoints.getUser(userId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(User(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Gets an array of voice regions from a guild

   - parameter guildId: Guild to get voice regions from
  */
  public func getVoiceRegions(from guildId: String, then completion: @escaping ([[String: Any]]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getGuildVoiceRegions(guildId)) { data, error in
      completion(data as? [[String: Any]], error)
    }
  }

  /**
   Gets a webhook

   - parameter webhookId: Webhook to get
  */
  public func getWebhook(_ webhookId: String, then completion: @escaping (Webhook?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getWebhook(webhookId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Webhook(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Gets a channel's webhooks

   - parameter channelId: Channel to get webhooks from
  */
  public func getWebhooks(from channelId: String, then completion: @escaping ([Webhook]?, RequestError?) -> ()) {
    self.requester.request(Endpoints.getChannelWebhooks(channelId)) { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnWebhooks: [Webhook] = []
        let webhooks = data as! [[String: Any]]
        for webhook in webhooks {
          returnWebhooks.append(Webhook(self, webhook))
        }
        completion(returnWebhooks, nil)
      }
    }
  }

  /**
   Joins a voice channel

   - parameter channelId: Channel to connect to
  */
  public func joinVoiceChannel(_ channelId: String, then completion: @escaping (VoiceConnection) -> () = {_ in}) {
    let guild = self.getGuild(for: channelId)

    guard guild != nil else { return }

    guard guild!.shard != nil else { return }

    let channel = guild!.channels[channelId]
    guard channel!.type != nil else { return }

    if channel!.type != 2 { return }

    let shard = self.shards.filter {
      $0.id == guild!.shard!
    }[0]

    self.voiceManager.handlers[guild!.id] = completion

    shard.joinVoiceChannel(channelId, in: guild!.id)
  }

  /**
   Leaves a guild

   - parameter guildId: Guild to leave
   */
  public func leaveGuild(_ guildId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.leaveGuild(guildId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Leaves a voice channel

   - parameter channelId: Channel to disconnect from
  */
  public func leaveVoiceChannel(_ channelId: String) {
    let guild = self.getGuild(for: channelId)

    guard guild != nil else { return }

    guard self.voiceManager.guilds[guild!.id] != nil else { return }

    guard guild!.shard != nil else { return }

    let channel = guild!.channels[channelId]

    guard channel!.type != nil else { return }

    if channel!.type != 2 { return }

    let shard = self.shards.filter {
      $0.id == guild!.shard!
    }[0]

    shard.leaveVoiceChannel(in: guild!.id)
  }

  /**
   Modifies a channel

   #### Options Params ####

   - **name**: Name to give channel
   - **position**: Channel position to set it to
   - **topic**: If a text channel, sets the topic of the text channel
   - **bitrate**: If a voice channel, sets the bitrate for the voice channel
   - **user_limit**: If a voice channel, sets the maximum allowed users in a voice channel

   - parameter channelId: Channel to edit
   - parameter options: Optons to give channel
  */
  public func modifyChannel(_ channelId: String, with options: [String: Any] = [:], then completion: @escaping (GuildChannel?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyChannel(channelId), body: options, method: "PATCH") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(GuildChannel(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Modifies channel positions from a guild

   #### Options Params ####

   Array of the following:

   - **id**: The channel id to modify
   - **position**: The sorting position of the channel

   - parameter guildId: Guild to modify channel positions from
   - parameter options: Preconfigured options to set channel positions to
  */
  public func modifyChannelPositions(for guildId: String, with options: [[String: Any]], then completion: @escaping ([GuildChannel]?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuildChannelPositions(guildId), body: ["array": options], method: "PATCH") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnChannels: [GuildChannel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(GuildChannel(self, channel))
        }

        completion(returnChannels, nil)
      }
    }
  }

  /**
   Modifies a guild

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

   - parameter guildId: Guild to modify
   - parameter options: Preconfigured options to modify guild with
  */
  public func modifyGuild(_ guildId: String, with options: [String: Any], then completion: @escaping (Guild?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuild(guildId), body: options, method: "PATCH") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let guild = Guild(self, data as! [String: Any], self.getShard(for: guildId))
        self.guilds[guildId] = guild
        completion(guild, nil)
      }
    }
  }

  /**
   Modifies an integration from a guild

   #### Option Params ####

   - **expire_behavior**: The behavior when an integration subscription lapses (see the [integration](https://discordapp.com/developers/docs/resources/guild#integration-object) object documentation)
   - **expire_grace_period**: Period (in seconds) where the integration will ignore lapsed subscriptions
   - **enable_emoticons**: Whether emoticons should be synced for this integration (twitch only currently), true or false

   - parameter integrationId: Integration to modify
   - parameter guildId: Guild to modify integration from
   - parameter options: Preconfigured options to modify this integration with
  */
  public func modifyIntegration(_ integrationId: String, for guildId: String, with options: [String: Any], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuildIntegration(guildId, integrationId), body: options, method: "PATCH") { data, error in
      completion(error)
    }
  }

  /**
   Modifies a member from a guild

   #### Options Params ####

   - **nick**: The nickname to assign
   - **roles**: Array of role id's that should be assigned to the member
   - **mute**: Whether or not to server mute the member
   - **deaf**: Whether or not to server deafen the member
   - **channel_id**: If the user is connected to a voice channel, assigns them the new voice channel they are to connect.

   - parameter userId: Member to modify
   - parameter guildId: Guild to modify member in
   - parameter options: Preconfigured options to modify member with
  */
  public func modifyMember(_ userId: String, in guildId: String, with options: [String: Any], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuildMember(guildId, userId), body: options, method: "PATCH") { data, error in
      completion(error)
    }
  }

  /**
   Modifies a role from a guild

   #### Options Params ####

   - **name**: The name to assign to the role
   - **permissions**: The bitwise permission integer
   - **color**: RGB int color value to assign to the role
   - **hoist**: Whether or not this role should be hoisted on the member list
   - **mentionable**: Whether or not this role should be mentionable by everyone

   - parameter roleId: Role to modify
   - parameter guildId: Guild to modify role from
   - parameter options: Preconfigured options to modify guild roles with
  */
  public func modifyRole(_ roleId: String, for guildId: String, with options: [String: Any], then completion: @escaping (Role?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuildRole(guildId, roleId), body: options, method: "PATCH") { data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Role(data as! [String: Any]), nil)
      }
    }
  }

  /**
   Modifies role positions from a guild

   #### Options Params ####

   Array of the following:

   - **id**: The role id to edit position
   - **position**: The sorting position of the role

   - parameter guildId: Guild to modify role positions from
   - parameter options: Preconfigured options to set role positions to
  */
  public func modifyRolePositions(for guildId: String, with options: [[String: Any]], then completion: @escaping ([Role]?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuildRolePositions(guildId), body: ["array": options], method: "PATCH") { data, error in
      if error != nil {
        completion(nil, error)
      }else {
        var returnRoles: [Role] = []
        let roles = data as! [[String: Any]]
        for role in roles {
          returnRoles.append(Role(role))
        }

        completion(returnRoles, nil)
      }
    }
  }

  /**
   Modifies a webhook

   #### Option Params ####

   - **name**: The name given to the webhook
   - **avatar**: The avatar image to give webhook in base 64 string

   - parameter webhookId: Webhook to modify
   - parameter options: Preconfigured options to modify webhook with
  */
  public func modifyWebhook(_ webhookId: String, with options: [String: String], then completion: @escaping (Webhook?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyWebhook(webhookId), body: options, method: "PATCH") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Webhook(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Moves a member in a guild to another voice channel (if they are in one)

   - parameter userId: User to move
   - parameter guildId: Guild that they're in currently
   - parameter channelId: The Id of the channel to send them to
  */
  public func moveMember(_ userId: String, in guildId: String, to channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyGuildMember(guildId, userId), body: ["channel_id": channelId], method: "PATCH") { data, error in
      completion(error)
    }
  }

  /**
   Pins a message to a channel

   - parameter messageId: Message to pin
   - parameter channelId: Channel to pin message in
  */
  public func pin(_ messageId: String, in channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.addPinnedChannelMessage(channelId, messageId), method: "PUT") { data, error in
      completion(error)
    }
  }

  /**
   Prunes members for x amount of days in a guild

   - parameter guildId: Guild to prune members in
   - parameter limit: Amount of days for prunned users
  */
  public func pruneMembers(in guildId: String, for limit: Int, then completion: @escaping (Int?, RequestError?) -> () = {_ in}) {
    guard limit > 1 else {
      completion(nil, .unknown)
      return
    }

    self.requester.request(Endpoints.beginGuildPrune(guildId), body: ["days": limit], method: "POST") { data, error in
      completion(data as? Int, error)
    }
  }

  /**
   Removes member from a guild

   - parameter userId: Member to remove from server
   - parameter guildId: Guild to remove them from
  */
  public func removeMember(_ userId: String, from guildId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.removeGuildMember(guildId, userId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Sends a message to channel

   #### Content Dictionary Params ####

   - **content**: Message to send
   - **username**: The username the webhook will send with the message
   - **avatar_url**: The url of the user the webhook will send
   - **tts**: Whether or not this message is tts
   - **file**: The url of the image to send
   - **embed**: The embed object to send. Refer to [Embed structure](https://discordapp.com/developers/docs/resources/channel#embed-object)

   - parameter content: Either string or dictionary containing info on message
   - parameter channelId: Channel to send message to
  */
  public func send(_ content: Any, to channelId: String, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    guard var message = content as? [String: Any] else {
      self.requester.request(Endpoints.createMessage(channelId), body: ["content": content], method: "POST") { [unowned self] data, error in
        if error != nil {
          completion(nil, error)
        }else {
          completion(Message(self, data as! [String: Any]), nil)
        }
      }
      return
    }

    var file: String? = nil

    if message["file"] != nil {
      file = message["file"] as? String
      message.removeValue(forKey: "file")
    }

    self.requester.request(Endpoints.createMessage(channelId), body: !message.isEmpty ? message : nil, file: file, method: "POST") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        completion(Message(self, data as! [String: Any]), nil)
      }
    }
  }

  /**
   Sets bot to typing in channel

   - parameter channelId: Channel to set typing to
  */
  public func setTyping(for channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.triggerTypingIndicator(channelId), method: "POST") { data, error in
      completion(error)
    }
  }

  /**
   Sets bot's username

   - parameter name: Name to set bot's username to
  */
  public func setUsername(to name: String, then completion: @escaping (User?, RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.modifyCurrentUser(), body: ["username": name], method: "PATCH") { [unowned self] data, error in
      if error != nil {
        completion(nil, error)
      }else {
        let user = User(self, data as! [String: Any])
        self.user = user
        completion(user, nil)
      }
    }
  }

  /**
   Syncs an integration for a guild

   - parameter integrationId: Integration to sync
   - parameter guildId: Guild to sync intregration for
  */
  public func syncIntegration(_ integrationId: String, for guildId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.syncGuildIntegration(guildId, integrationId), method: "POST") { data, error in
      completion(error)
    }
  }

  /**
   Unbans a user from this guild

   - parameter userId: User to unban
  */
  public func unbanMember(_ userId: String, from guildId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.removeGuildBan(guildId, userId), method: "DELETE") { data, error in
      completion(error)
    }
  }

  /**
   Unpins a pinned message from a channel

   - parameter messageId: Pinned message to unpin
  */
  public func unpin(_ messageId: String, from channelId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(Endpoints.deletePinnedChannelMessage(channelId, messageId), method: "DELETE") { data, error in
      completion(error)
    }
  }

}
