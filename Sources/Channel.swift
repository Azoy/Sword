//
//  Channel.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Generic Channel structure
public protocol Channel {

  // MARK: Properties

  /// Parent class
  weak var sword: Sword? { get }

  /// The id of the channel
  var id: String { get }

  /// The last message's id
  var lastMessageId: String? { get }

  /// Collection of messages mapped by message id
  var messages: [String: Message] { get }

}

public extension Channel {

  // MARK: Functions

  /**
   Adds a reaction (unicode or custom emoji) to message

   - parameter reaction: Unicode or custom emoji reaction
   - parameter messageId: Message to add reaction to
  */
  public func addReaction(_ reaction: String, to messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.addReaction(reaction, to: messageId, in: self.id, then: completion)
  }

  /// Deletes the current channel, whether it be a DMChannel or GuildChannel
  public func delete(then completion: @escaping (Channel?, RequestError?) -> () = {_ in}) {
    self.sword!.deleteChannel(self.id, then: completion)
  }

  /**
   Deletes a message from this channel

   - parameter messageId: Message to delete
  */
  public func deleteMessage(_ messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.deleteMessage(messageId, from: self.id, then: completion)
  }

  /**
   Bulk deletes messages

   - parameter messages: Array of message ids to delete
  */
  public func deleteMessages(_ messages: [String], then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.deleteMessages(messages, from: self.id, then: completion)
  }

  /**
   Deletes a reaction from message by user

   - parameter reaction: Unicode or custom emoji to delete
   - parameter messageId: Message to delete reaction from
   - parameter userId: If nil, deletes bot's reaction from, else delete a reaction from user
  */
  public func deleteReaction(_ reaction: String, from messageId: String, by userId: String? = nil, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.deleteReaction(reaction, from: messageId, by: userId, in: self.id, then: completion)
  }

  /**
   Edits a message's content

   - parameter messageId: Message to edit
   - parameter content: Text to change message to
  */
  public func editMessage(_ messageId: String, to content: String, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.sword!.editMessage(messageId, to: content, in: self.id, then: completion)
  }

  /**
   Gets an array of users who used reaction from message

   - parameter reaction: Unicode or custom emoji to get
   - parameter messageId: Message to get reaction users from
  */
  public func getReaction(_ reaction: String, from messageId: String, then completion: @escaping ([User]?, RequestError?) -> ()) {
    self.sword!.getReaction(reaction, from: messageId, in: self.id, then: completion)
  }

  /// Get Pinned messages for this channel
  public func getPinnedMessages(then completion: @escaping ([Message]?, RequestError?) -> () = {_ in}) {
    self.sword!.getPinnedMessages(from: self.id, then: completion)
  }

  /**
   Pins a message to this channel

   - parameter messageId: Message to pin
  */
  public func pin(_ messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.pin(messageId, in: self.id, then: completion)
  }

  /**
   Sends a message to channel

   - parameter message: Message to send
  */
  public func send(_ message: Any, then completion: @escaping (Message?, RequestError?) -> () = {_ in}) {
    self.sword!.send(message, to: self.id, then: completion)
  }

  /**
   Unpins a pinned message from this channel

   - parameter messageId: Pinned message to unpin
  */
  public func unpin(_ messageId: String, then completion: @escaping (RequestError?) -> () = {_ in}) {
    self.sword!.unpin(messageId, from: self.id, then: completion)
  }

}
