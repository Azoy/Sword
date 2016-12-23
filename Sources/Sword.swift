import Foundation

public class Sword {

  let token: String

  let requester: Request
  let endpoints = Endpoints()
  var shards: [Shard] = []
  let eventer = Eventer()

  var gatewayUrl: String?
  var shardCount: Int?

  public var guilds: [String: Guild] = [:]
  public var unavailableGuilds: [String: UnavailableGuild] = [:]
  public var user: User?

  /* Sword Initializer
    @param token: String - Bot Token
  */
  public init(token: String) {
    self.token = token
    self.requester = Request(token)
  }

  // Alias for Eventer().on(_:, _:)
  public func on(_ eventName: String, _ completion: @escaping (_ data: Any) -> ()) {
    self.eventer.on(eventName, completion)
  }

  // Alias for Eventer().emit(_:, with:)
  public func emit(_ eventName: String, with data: Any...) {
    self.eventer.emit(eventName, with: data)
  }

  // Used to get gateway URL
  func getGateway(completion: @escaping (Error?, [String: Any]?) -> ()) {
    self.requester.request(self.endpoints.gateway, rateLimited: false) { error, data in
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

  // Starts WS with Discord
  public func connect() {
    self.getGateway() { error, data in
      if error != nil {
        print(error!)
        sleep(2)
        self.connect()
      }else {
        self.gatewayUrl = "\(data!["url"]!)/?encoding=json&v=6"
        self.shardCount = data!["shards"] as? Int

        for id in 0..<self.shardCount! {
          let shard = Shard(self, id, self.shardCount!)
          self.shards.append(shard)
          shard.startWS(self.gatewayUrl!)
        }

      }
    }
  }

  /* Add User to Guild
    @param userId: String - User to add to guild
    @param guildId: String - Guild to add user in
    @param options: [String: Any] - Options to give new member
  */
  public func add(user userId: String, to guildId: String, with options: [String: Any] = [:], _ completion: @escaping (Member?) -> () = {_ in}) {
    self.requester.request(endpoints.addGuildMember(guildId, userId), body: options.createBody(), method: "PUT") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Member(self, data as! [String: Any]))
      }
    }
  }

  /* Creates an invite for channel
    @param channelId: String - Channel to create invite for
    @param options: [String: Any] - Options for invite
  */
  public func createInvite(for channelId: String, with options: [String: Any] = [:], _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.createChannelInvite(channelId), body: options.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data)
      }
    }
  }

  /* Deletes a channel
    @param channelId: String - Channel to delete
  */
  public func delete(channel channelId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannel(channelId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipient"] == nil {
          completion(Channel(self, channelData))
        }else {
          completion(DMChannel(self, channelData))
        }
      }
    }
  }

  /* Deletes a guild
    @param guildId: String - Guild to delete
  */
  public func delete(guild guildId: String, _ completion: @escaping (Guild?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteGuild(guildId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds.removeValue(forKey: guild.id)
        completion(guild)
      }
    }
  }

  /* Delete an invite
    @param inviteId: String - ID of invite
  */
  public func delete(invite inviteId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.deleteInvite(inviteId), method: "DELETE") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as! [String: Any])
      }
    }
  }

  /* Deletes a webhook
    @param webhookId: String - Webhook to delete
  */
  public func delete(webhook webhookId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.deleteWebhook(webhookId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Deletes permissions for overwrite in channel
    @param channelId: String - Channel to delete permisson from
    @param overwriteId: String - Overwrite to delete
  */
  public func deletePermission(for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.deleteChannelPermission(channelId, overwriteId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Edits channel with options
    @param channelId: String - Channel to edit
    @param options: [String: Any] - Options to append to channel
  */
  public func edit(channel channelId: String, with options: [String: Any] = [:], _ completion: @escaping (Channel?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyChannel(channelId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Channel(self, data as! [String: Any]))
      }
    }
  }

  /* Edits permissions for channel
    @param permissions: [String: Any] - Permissions to add/remove from channel
    @param channelId: String - Channel to edit perms for
    @param overwriteId: String - Overwrite id to change perms for
  */
  public func edit(permissions: [String: Any], for channelId: String, with overwriteId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.editChannelPermissions(channelId, overwriteId), body: permissions.createBody(), method: "PUT") { error, data in
      if error == nil { completion() }
    }
  }

  /* Edits status
    @param status: String - "online" | "idle" | "dnd" | "invisible"
    @param game: [String: Any]? - Game to set status to/set streaming
  */
  public func editStatus(to status: String = "online", playing game: [String: Any]? = nil) {
    guard self.shards.count > 0 else { return }
    var data: [String: Any] = ["afk": status == "idle", "game": NSNull(), "since": status == "idle" ? Date().milliseconds : 0, "status": status]

    if game != nil {
      data["game"] = game
    }

    let payload = Payload(op: .statusUpdate, data: data).encode()

    for shard in self.shards {
      shard.send(payload, presence: true)
    }
  }

  /* Executes a webhook
    @param webhookId: String - Webhook to executeWebhook
    @param webhookToken: String - Webhook token auth
    @param content: Any - Either string or dictionary containing webhook object
  */
  public func execute(webhook webhookId: String, token webhookToken: String, with content: Any, _ completion: @escaping () -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), body: data, method: "POST") { error, data in
        if error == nil { completion() }
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
      parameters["payload_json"] = (message["embed"] as! [String: Any]).encode()
    }
    if message["username"] != nil {
      parameters["username"] = (message["user"] as! String)
    }
    if message["avatar_url"] != nil {
      parameters["avatar_url"] = (message["avatar_url"] as! String)
    }

    file["parameters"] = parameters

    self.requester.request(endpoints.executeWebhook(webhookId, webhookToken), file: file, method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /* Executes Slack style webhook
    @param webhookId: String - Webhook to execute
    @param webhookToken: String - Webhook token auth
    @param content: [String: Any] - Slack webhook objcet
  */
  public func executeSlack(webhook webhookId: String, token webhookToken: String, with content: [String: Any], _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.executeSlackWebhook(webhookId, webhookToken), body: content.createBody(), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /* Get message from channel
    @param messageId: String - Message to get
    @param channelId: String - Channel to get message from
  */
  public func get(message messageId: String, from channelId: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelMessage(channelId, messageId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self, data as! [String: Any]))
      }
    }
  }

  /* Gets messages from channel
    @param limit: Int - Amount of messages to get
    @param channelId: String - Channel to get messages from
  */
  public func get(_ limit: Int, messagesFrom channelId: String, _ completion: @escaping ([Message]?) -> () = {_ in}) {
    if limit > 100 || limit < 1 { completion(nil); return }
    self.requester.request(endpoints.getChannelMessages(channelId), body: ["limit": limit].createBody()) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnMessages: [Message] = []
        let messages = data as! [[String: Any]]
        for message in messages {
          returnMessages.append(Message(self, message))
        }
        completion(returnMessages)
      }
    }
  }

  /* Get an invite
    @param inviteId: String - ID of invite
  */
  public func get(invite inviteId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.getInvite(inviteId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as! [String: Any])
      }
    }
  }

  /* Gets a guild member
    @param userId: String - User to get
    @param guildId: String - Guild to get from
  */
  public func get(user userId: String, from guildId: String, _ completion: @escaping (Member?) -> () = {_ in}) {
    self.requester.request(endpoints.getGuildMember(guildId, userId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        let member = Member(self, data as! [String: Any])
        completion(member)
      }
    }
  }

  /* Gets webhook by id
    @param webhookId: String - Webhook to get
  */
  public func get(webhook webhookId: String, _ completion: @escaping ([String: Any]?) -> ()) {
    self.requester.request(endpoints.getWebhook(webhookId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [String: Any])
      }
    }
  }

  /* Gets channel invites
    @param channelId: String - Channel to get invites from
  */
  public func getInvites(for channelId: String, _ completion: @escaping (Any?) -> () = {_ in}) {
    self.requester.request(endpoints.getChannelInvites(channelId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data)
      }
    }
  }

  /* Restfully get channel
    @param channelId: String - Channel to get
  */
  public func getREST(channel channelId: String, _ completion: @escaping (Any?) -> ()) {
    self.requester.request(endpoints.getChannel(channelId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        let channelData = data as! [String: Any]
        if channelData["recipient"] == nil {
          completion(Channel(self, channelData))
        }else {
          completion(DMChannel(self, channelData))
        }
      }
    }
  }

  /* Restfully get guild
    @param guildId: String - Guild to get
  */
  public func getREST(guild guildId: String, _ completion: @escaping (Guild?) -> ()) {
    self.requester.request(endpoints.getGuild(guildId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        let guild = Guild(self, data as! [String: Any])
        self.guilds[guild.id] = guild
        completion(guild)
      }
    }
  }

  /* Restfully get a user
    @param userId: String - User to get
  */
  public func getREST(user userId: String, _ completion: @escaping (User?) -> ()) {
    self.requester.request(endpoints.getUser(userId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(User(self, data as! [String: Any]))
      }
    }
  }

  /* Restfully gets guild channels
    @param guildId: String - Guild to get channels from
  */
  public func getRESTChannels(from guildId: String, _ completion: @escaping ([Channel]?) -> ()) {
    self.requester.request(endpoints.getGuildChannels(guildId)) { error, data in
      if error != nil {
        completion(nil)
      }else {
        var returnChannels: [Channel] = []
        let channels = data as! [[String: Any]]
        for channel in channels {
          returnChannels.append(Channel(self, channel))
        }

        completion(returnChannels)
      }
    }
  }

  // Restfully get guilds bot is in
  public func getRESTGuilds(_ completion: @escaping ([[String: Any]]?) -> ()) {
    self.requester.request(endpoints.getCurrentUserGuilds()) { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [[String: Any]])
      }
    }
  }

  /* Leaves a guild
    @param guildId: String - Guild to leave
  */
  public func leave(guild guildId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.leaveGuild(guildId), method: "DELETE") { error, data in
      if error == nil { completion() }
    }
  }

  /* Modifies webhook
    @param webhookId: String - Webhook to modify
  */
  public func modify(webhook webhookId: String, with options: [String: String], _ completion: @escaping ([String: Any]?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyWebhook(webhookId), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(data as? [String: Any])
      }
    }
  }

  /* Send message to channel
    @param content: Any - Either a string or a dictionary with info on embeds, files, tts, etc..
    @param channelId: String - Channel to send message to
  */
  public func send(_ content: Any, to channelId: String, _ completion: @escaping (Message?) -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.requester.request(endpoints.createMessage(channelId), body: data, method: "POST") { error, data in
        if error != nil {
          completion(nil)
        }else {
          completion(Message(self, data as! [String: Any]))
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
      parameters["payload_json"] = (message["embed"] as! [String: Any]).encode()
    }

    file["parameters"] = parameters

    self.requester.request(endpoints.createMessage(channelId), file: file, method: "POST") { error, data in
      if error != nil {
        completion(nil)
      }else {
        completion(Message(self, data as! [String: Any]))
      }
    }
  }

  /* Sets bot to typing in channel
    @param channelId: String - Channel to start "typing" in
  */
  public func setTyping(for channelId: String, _ completion: @escaping () -> () = {_ in}) {
    self.requester.request(endpoints.triggerTypingIndicator(channelId), method: "POST") { error, data in
      if error == nil { completion() }
    }
  }

  /* Sets bot's username
    @param name: String - Name to change to
  */
  public func setUsername(to name: String, _ completion: @escaping (User?) -> () = {_ in}) {
    self.requester.request(endpoints.modifyCurrentUser(), body: ["username": name].createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(nil)
      }else {
        let user = User(self, data as! [String: Any])
        self.user = user
        completion(user)
      }
    }
  }

}
