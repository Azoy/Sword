//
//  Webhook.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Webhook structure
public struct Webhook {

  // MARK: Properties

  /// Parent class
  public weak var sword: Sword?

  /// Avatar for the webhook in base64
  public let avatar: String?

  /// The GuildChannel this webhook messages to
  public let channel: GuildChannel

  /// The Guild this webhook is located in
  public let guild: Guild

  /// The id of the webhook
  public let id: String

  /// The display name of the webhook
  public let name: String

  /// The user account for this webhook
  public let user: User

  /// The token for this webhook
  public let token: String

  // MARK: Initializer

  /**
   Creates Webhook structure

   - parameter sword: The parent class
   - parameter json: The data to transform to a webhook
  */
  init(_ sword: Sword, _ json: [String: Any]) {
    self.sword = sword

    self.avatar = json["avatar"] as? String

    let channelId = json["channel_id"] as! String
    self.channel = sword.guilds[sword.getGuild(for: channelId)!.id]!.channels[channelId]!

    let guildId = json["guild_id"] as! String
    self.guild = sword.guilds[guildId]!

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.user = User(sword, json["user"] as! [String: Any])
    self.token = json["token"] as! String
  }

  /**
   Modifies the current Webhook

   #### Option Params ####

   - **name**: The name of the webhook
   - **avatar**: The avatar for this webhook in base64 string

   - parameter options: A dictionary of options to apply to this webhook
  */
  public func modify(with options: [String: Any], _ completion: @escaping (RequestError?, Webhook?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.modifyWebhook(self.id), body: options.createBody(), method: "PATCH") { error, data in
      if error != nil {
        completion(error, nil)
      }else {
        completion(nil, Webhook(self.sword!, data as! [String: Any]))
      }
    }
  }

  /// Deletes the current webhook from its guild
  public func delete(_ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.deleteWebhook(self.id), method: "DELETE") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
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

   - parameter content: String or dictionary containing message content
  */
  public func execute(with content: Any, _ completion: @escaping (RequestError?) -> () = {_ in}) {
    guard let message = content as? [String: Any] else {
      let data = ["content": content].createBody()
      self.sword!.requester.request(self.sword!.endpoints.executeWebhook(self.id, self.token), body: data, method: "POST") { error, data in
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
        parameters["embeds"] = (message["embed"] as! [String: Any]).encode()
      }else {
        parameters["payload_json"] = (message["embed"] as! [String: Any]).encode()
      }
    }
    if message["username"] != nil {
      parameters["username"] = (message["user"] as! String)
    }
    if message["avatar_url"] != nil {
      parameters["avatar_url"] = (message["avatar_url"] as! String)
    }

    if file.isEmpty && !parameters.isEmpty {
      self.sword!.requester.request(self.sword!.endpoints.executeWebhook(self.id, self.token), body: parameters.createBody(), method: "POST") { error, data in
        if error != nil {
          completion(error)
        }else {
          completion(nil)
        }
      }
    }else {
      file["parameters"] = parameters

      self.sword!.requester.request(self.sword!.endpoints.executeWebhook(self.id, self.token), file: file, method: "POST") { error, data in
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

   - parameter content: Dictionary containing slack webhook info
  */
  public func executeSlack(with content: [String: Any], _ completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.requester.request(self.sword!.endpoints.executeSlackWebhook(self.id, self.token), body: content.createBody(), method: "POST") { error, data in
      if error != nil {
        completion(error)
      }else {
        completion(nil)
      }
    }
  }

}
