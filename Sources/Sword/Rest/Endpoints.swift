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
    return .init(.PUT, "/channels/\(major: channelId)/recipients/\(userId)")
  }
  
  static func bulkDeleteMessages(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/messages/bulk-delete")
  }
  
  static func createInvite(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/invites")
  }
  
  static func createMessage(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/messages")
  }
  
  static func createPinnedMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.PUT, "/channels/\(major: channelId)/pins/\(messageId)")
  }
  
  static func createReaction(_ reactionId: String, for messageId: String, in channelId: String) -> Endpoint {
    return .init(.PUT, "/channels/\(major: channelId)/messages/\(messageId)/reactions/\(reactionId)/@me")
  }
  
  static func deleteChannel(_ channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)")
  }
  
  static func deleteChannelPermission(_ overwriteId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/permissions/\(overwriteId)")
  }
  
  static func deleteMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/messages/\(messageId)")
  }
  
  static func deletePinnedMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/pins/\(messageId)")
  }
  
  static func deleteReaction(_ reactionId: String, by userId: String, from messageId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/messages/\(messageId)/reactions/\(reactionId)/\(userId)")
  }
  
  static func deleteReactions(from messageId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/messages/\(messageId)/reactions")
  }
  
  static func editChannelPermission(_ overwriteId: String, in channelId: String) -> Endpoint {
    return .init(.PUT, "/channels/\(major: channelId)/permissions/\(overwriteId)")
  }
  
  static func editMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.PATCH, "/channels/\(major: channelId)/messages/\(messageId)")
  }
  
  static var gateway: Endpoint {
    return .init(.GET, "/gateway/bot")
  }
  
  static func getAuditLog(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/audit-logs")
  }
  
  static func getChannel(_ channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)")
  }
  
  static func getInvites(in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/invites")
  }
  
  static func getMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/messages/\(messageId)")
  }
  
  static func getMessages(in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/messages")
  }
  
  static func getPinnedMessages(in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/pins")
  }
  
  static func getReaction(_ reactionId: String, from messageId: String, in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/messages/\(messageId)/reactions/\(reactionId)")
  }
  
  static func modifyChannel(_ channelId: String) -> Endpoint {
    return .init(.PATCH, "/channels/\(major: channelId)")
  }
  
  static func removeRecipient(_ userId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/recipients/\(userId)")
  }
  
  static func triggerTyping(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/typing")
  }
}
