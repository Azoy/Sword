//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

// This and Diagnostics.swift are the only files where I'll permit violating
// the 80 column rule.

extension Endpoint {
  static func addRecipient(_ userId: String, in channelId: String) -> Endpoint {
    return .init(.put, "/channels/\(channelId)/recipients/\(userId)", channelId)
  }
  
  static func bulkDeleteMessages(in channelId: String) -> Endpoint {
    return .init(.post, "/channels/\(channelId)/messages/bulk-delete", channelId)
  }
  
  static func createInvite(in channelId: String) -> Endpoint {
    return .init(.post, "/channels/\(channelId)/invites")
  }
  
  /// Create Message
  ///
  /// - parameter channelId: The channel to create message in
  static func createMessage(in channelId: String) -> Endpoint {
    return .init(.post, "/channels/\(channelId)/messages", channelId)
  }
  
  static func createPinnedMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.put, "/channels/\(channelId)/pins/\(messageId)", channelId)
  }
  
  static func createReaction(_ reactionId: String, for messageId: String, in channelId: String) -> Endpoint {
    return .init(.put, "/channels/\(channelId)/messages/\(messageId)/reactions/\(reactionId)/@me", channelId)
  }
  
  static func deleteChannel(_ channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)", channelId)
  }
  
  static func deleteChannelPermission(_ overwriteId: String, in channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)/permissions/\(overwriteId)", channelId)
  }
  
  static func deleteMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)/messages/\(messageId)", channelId)
  }
  
  static func deletePinnedMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)/pins/\(messageId)", channelId)
  }
  
  static func deleteReaction(_ reactionId: String, by userId: String, from messageId: String, in channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)/messages/\(messageId)/reactions/\(reactionId)/\(userId)", channelId)
  }
  
  static func deleteReactions(from messageId: String, in channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)/messages/\(messageId)/reactions", channelId)
  }
  
  static func editChannelPermission(_ overwriteId: String, in channelId: String) -> Endpoint {
    return .init(.put, "/channels/\(channelId)/permissions/\(overwriteId)", channelId)
  }
  
  static func editMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.patch, "/channels/\(channelId)/messages/\(messageId)", channelId)
  }
  
  static var gateway: Endpoint {
    return .init(.get, "/gateway/bot")
  }
  
  static func getAuditLog(in guildId: String) -> Endpoint {
    return .init(.get, "/guilds/\(guildId)/audit-logs", guildId)
  }
  
  static func getChannel(_ channelId: String) -> Endpoint {
    return .init(.get, "/channels/\(channelId)", channelId)
  }
  
  static func getInvites(in channelId: String) -> Endpoint {
    return .init(.get, "/channels/\(channelId)/invites", channelId)
  }
  
  static func getMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.get, "/channels/\(channelId)/messages/\(messageId)", channelId)
  }
  
  static func getMessages(in channelId: String) -> Endpoint {
    return .init(.get, "/channels/\(channelId)/messages", channelId)
  }
  
  static func getPinnedMessages(in channelId: String) -> Endpoint {
    return .init(.get, "/channels/\(channelId)/pins", channelId)
  }
  
  static func getReaction(_ reactionId: String, from messageId: String, in channelId: String) -> Endpoint {
    return .init(.get, "/channels/\(channelId)/messages/\(messageId)/reactions/\(reactionId)", channelId)
  }
  
  static func modifyChannel(_ channelId: String) -> Endpoint {
    return .init(.patch, "/channels/\(channelId)", channelId)
  }
  
  static func removeRecipient(_ userId: String, in channelId: String) -> Endpoint {
    return .init(.delete, "/channels/\(channelId)/recipients/\(userId)", channelId)
  }
  
  static func triggerTyping(in channelId: String) -> Endpoint {
    return .init(.post, "/channels/\(channelId)/typing", channelId)
  }
}
