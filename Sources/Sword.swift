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

  /// Endpoints structure
  let endpoints = Endpoints()

  /// The gateway url to connect to
  var gatewayUrl: String?

  /// Array of guilds the bot is currently connected to
  public internal(set) var guilds: [String: Guild] = [:]

  /// Event listeners
  public var listeners: [Event: [([Any]) -> ()]] = [:]

  /// Optional options to apply to bot
  var options: SwordOptions

  /// Timestamp of ready event
  public internal(set) var readyTimestamp: Date?

  /// Requester class
  let requester: Request

  /// Amount of shards to initialize
  public internal(set) var shardCount = 1

  /// Array of Shard class
  var shards: [Shard] = []

  /// The bot token
  let token: String

  /// Array of unavailable guilds the bot is currently connected to
  public internal(set)var unavailableGuilds: [String: UnavailableGuild] = [:]

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

  /// Object of voice connections the bot is currently connected to. Mapped by guildId
  public var voiceConnections: [String: VoiceConnection] {
    return self.voiceManager.connections
  }

  /// Voice handler
  let voiceManager = VoiceManager()

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
  func getGateway(completion: @escaping (RequestError?, [String: Any]?) -> ()) {
    self.requester.request(self.endpoints.gateway(), rateLimited: false) { error, data in
      if error != nil {
        completion(error, nil)
        return
      }

      guard let data = data as? [String: Any] else {
        completion(.unknown, nil)
        return
      }

      completion(nil, data)
    }
  }

  /// Starts the bot
  public func connect() {
    self.getGateway() { error, data in
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
   Creates a guild

   - parameter options: Refer to [discord docs](https://discordapp.com/developers/docs/resources/guild#create-guild) for guild options
  */
  public func createGuild(with options: [String: Any], _ completion: @escaping (RequestError?, Guild?) -> () = {_ in}) {
    self.requester.request(endpoints.createGuild(), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Guild(self, data as! [String: Any]))
      }
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
  public func createInvite(for channelId: String, with options: [String: Any] = [:], _ completion: @escaping (RequestError?, Any?) -> () = {_ in}) {
    self.requester.request(endpoints.createChannelInvite(channelId), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data)
      }
    }
  }

  /**
   Deletes a channel

   - parameter channelId: Channel to delete
  */
  public func delete(channel channelId: String, _ completion: @escaping (RequestError?, Channel?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannel(channelId), method: "DELETE") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipient"] == nil {
          completion(nil, GuildChannel(self, channelData))
        }else {
          completion(nil, DMChannel(self, channelData))
        }
      }
    }
  }

  /**
   Deletes a guild

   - parameter guildId: Guild to delete
  */
  public func delete(guild guildId: String, _ completion: @escaping (RequestError?, Guild?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteGuild(guildId), method: "DELETE") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds.removeValue(forKey: guild.id)
        completion(nil, guild)
      }
    }
  }

  /**
   Deletes an invite

   - parameter inviteId: Invite to delete
  */
  public func delete(invite inviteId: String, _ completion: @escaping (RequestError?, Any?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteInvite(inviteId), method: "DELETE") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as! [String: Any])
      }
    }
  }

  /**
   Deletes a webhook

   - parameter webhookId: Webhook to delete
  */
  public func delete(webhook webhookId: String, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteWebhook(webhookId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Deletes an overwrite permission for a channel

   - parameter channelId: Channel to delete permissions from
   - parameter overwriteId: Overwrite ID to use for permissons
  */
  public func deletePermission(for channelId: String, with overwriteId: String, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannelPermission(channelId, overwriteId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
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
  public func edit(permissions: [String: Any], for channelId: String, with overwriteId: String, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(endpoints.editChannelPermissions(channelId, overwriteId), body: permissions.createBody(), method: "PUT") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Edits bot status

   - parameter presence: Presence structure to set status to
  */
  public func editStatus(to presence: Presence) {
    guard self.shards.count > 0 else { return }
    var data: [String: Any] = ["afk": presence.status == .idle, "game": NSNull(), "since": presence.status == .idle ? Date().milliseconds : 0, "status": presence.status.rawValue]

    if presence.game != nil {
      data["game"] = ["name": presence.game]
    }

    let payload = Payload(op: .statusUpdate, data: data).encode()

    for shard in self.shards {
      shard.send(payload, presence: true)
    }
  }

  /**
   Executes a webhook

   #### Content Dictionary Params ####

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
  public func execute(webhook webhookId: String, token webhookToken: String, with content: Any, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), body: data, method: "POST") { error, data in
        if error != nil {
          completion(error)
        }else {
          completion(nil)
        }
      }
      return
    }
    var file: [String: Any] = [:]
    var parameters: [String: String] = [:]

    if message["file"] != nil {
      file["file"] = message["file"] as! String
    }
    if message["content"] != nil {
      parameters["content"] = (message["content"] as! String)
    }
    if message["tts"] != nil {
      parameters["tts"] = (message["tts"] as! String)
    }
    if message["embed"] != nil {
      if file.isEmpty {
        parameters["embeds"] = [(message["embed"] as! [String: Any])].encode()
      }else {
        parameters["payload_json"] = [(message["embed"] as! [String: Any])].encode()
      }
    }
    if message["username"] != nil {
      parameters["username"] = (message["user"] as! String)
    }
    if message["avatar_url"] != nil {
      parameters["avatar_url"] = (message["avatar_url"] as! String)
    }

    if file.isEmpty && !parameters.isEmpty {
      self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), body: parameters.createBody(), method: "POST") { error, data in
        if error != nil {
          completion(error)
        }else {
          completion(nil)
        }
      }
    }else {
      file["parameters"] = parameters

      self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), file: file, method: "POST") { error, data in
        if error != nil {
          completion(error)
        }else {
          completion(nil)
        }
      }
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
  public func executeSlack(webhook webhookId: String, token webhookToken: String, with content: [String: Any], _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(endpoints.executeSlackWebhook(webhookId, webhookToken), body: content.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Gets a message from channel

   - parameter messageId: Message to get
   - parameter channelId: Channel to get message from
  */
  public func get(message messageId: String, from channelId: String, _ completion: @escaping (RequestError?, Message?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelMessage(channelId, messageId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Message(self, data as! [String: Any]))
      }
    }
  }

  /**
   Gets an array of messages from channel

   - parameter limit: Amount of messages to get
   - parameter channelId: Channel to get messages from
  */
  public func get(_ limit: Int, messagesFrom channelId: String, _ completion: @escaping (RequestError?, [Message]?) -> () = {_ in}) {
    if limit > 100 || limit < 1 {
      completion(.unknown, nil)
      return
    }
    self.requester.request(endpoints.getChannelMessages(channelId), body: ["limit": limit].createBody()) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }
        completion(nil, returnMessages)
      }
    }
  }

  /**
   Gets an invite

   - parameter inviteId: Invite to get
  */
  public func get(invite inviteId: String, _ completion: @escaping (RequestError?, Any?) -> () = {_ in}) {
    self.requester.request(endpoints.getInvite(inviteId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data as! [String: Any])
      }
    }
  }

  /**
   Gets a user from guild

   - parameter userId: User to get
   - parameter guildId: Guild to get user from
  */
  public func get(user userId: String, from guildId: String, _ completion: @escaping (RequestError?, Member?) -> () = {_ in}) {
    self.requester.request(endpoints.getGuildMember(guildId, userId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let member = Member(self, self.guilds[guildId]!, data as! [String: Any])
        completion(nil, member)
      }
    }
  }

  /**
   Gets a webhook

   - parameter webhookId: Webhook to get
  */
  public func get(webhook webhookId: String, _ completion: @escaping (RequestError?, Webhook?) -> ()) {
    self.requester.request(endpoints.getWebhook(webhookId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Webhook(self, data as! [String: Any]))
      }
    }
  }

  /**
   Gets a channel's invites

   - parameter channelId: Channel to get invites from
  */
  public func getInvites(for channelId: String, _ completion: @escaping (RequestError?, Any?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelInvites(channelId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, data)
      }
    }
  }

  /**
   Function to get guild for channelId

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
   Restfully gets a channel

   - parameter channelId: Channel to get restfully
  */
  public func getREST(channel channelId: String, _ completion: @escaping (RequestError?, Channel?) -> ()) {
    self.requester.request(endpoints.getChannel(channelId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipient"] == nil {
          completion(nil, GuildChannel(self, channelData))
        }else {
          completion(nil, DMChannel(self, channelData))
        }
      }
    }
  }

  /**
   Restfully gets a guild

   - parameter guildId: Guild to get restfully
  */
  public func getREST(guild guildId: String, _ completion: @escaping (RequestError?, Guild?) -> ()) {
    self.requester.request(endpoints.getGuild(guildId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds[guild.id] = guild
        completion(nil, guild)
      }
    }
  }

  /**
   Restfully gets a user

   - parameter userId: User to get restfully
  */
  public func getREST(user userId: String, _ completion: @escaping (RequestError?, User?) -> ()) {
    self.requester.request(endpoints.getUser(userId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, User(self, data as! [String: Any]))
      }
    }
  }

  /**
   Restfully gets channels from guild

   - parameter guildId: Guild to get channels from
  */
  public func getRESTChannels(from guildId: String, _ completion: @escaping (RequestError?, [GuildChannel]?) -> ()) {
    self.requester.request(endpoints.getGuildChannels(guildId)) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnChannels: [GuildChannel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(GuildChannel(self, channel))
        }

        completion(nil, returnChannels)
      }
    }
  }

  /// Restfully get guilds bot is in
  public func getRESTGuilds(_ completion: @escaping (RequestError?, [Guild]?) -> ()) {
    self.requester.request(endpoints.getCurrentUserGuilds()) { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        var returnGuilds: [Guild] = []
        let guilds = data as! [[String: Any]]
        for guild in guilds {
          returnGuilds.append(Guild(self, guild))
        }

        completion(nil, returnGuilds)
      }
    }
  }

  /**
   Joins a voice channel

   - parameter channelId: Channel to connect to
  */
  public func join(voiceChannel channelId: String, _ completion: @escaping (VoiceConnection) -> () = {_ in}) {
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

    shard.join(voiceChannel: channelId, in: guild!.id)
  }

  /**
   Leaves a guild

   - parameter guildId: Guild to leave
   */
  public func leave(guild guildId: String, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(endpoints.leaveGuild(guildId), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Leaves a voice channel

   - parameter channelId: Channel to disconnect from
  */
  public func leave(voiceChannel channelId: String) {
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
  public func modify(channel channelId: String, with options: [String: Any] = [:], _ completion: @escaping (RequestError?, GuildChannel?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyChannel(channelId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, GuildChannel(self, data as! [String: Any]))
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
  public func modify(webhook webhookId: String, with options: [String: String], _ completion: @escaping (RequestError?, Webhook?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyWebhook(webhookId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Webhook(self, data as! [String: Any]))
      }
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
  public func send(_ content: Any, to channelId: String, _ completion: @escaping (RequestError?, Message?) -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.requester.request(endpoints.createMessage(channelId), body: data, method: "POST") { error, data in
        if error != nil {
          completion(error, nil)
        }else {
          completion(nil, Message(self, data as! [String: Any]))
        }
      }
      return
    }
    var file: [String: Any] = [:]
    var parameters: [String: [String: Any]] = ["payload_json": [:]]

    if message["file"] != nil {
      file["file"] = message["file"] as! String
    }
    if message["content"] != nil {
      parameters["payload_json"]!["content"] = message["content"] as! String
    }
    if message["tts"] != nil {
      parameters["payload_json"]!["tts"] = message["tts"] as! String
    }
    if message["embed"] != nil {
      parameters["payload_json"]!["embed"] = message["embed"] as! [String: Any]
    }

    file["parameters"] = parameters

    self.requester.request(endpoints.createMessage(channelId), file: file, method: "POST") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Message(self, data as! [String: Any]))
      }
    }
  }

  /**
   Sets bot to typing in channel

   - parameter channelId: Channel to set typing to
  */
  public func setTyping(for channelId: String, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.requester.request(endpoints.triggerTypingIndicator(channelId), method: "POST") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

  /**
   Sets bot's username

   - parameter name: Name to set bot's username to
  */
  public func setUsername(to name: String, _ completion: @escaping (RequestError?, User?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyCurrentUser(), body: ["username": name].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        let user = User(self, data as! [String: Any])
        self.user = user
        completion(nil, user)
      }
    }
  }

}
