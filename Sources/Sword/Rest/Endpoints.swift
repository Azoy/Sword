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
  static func addMember(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.PUT, "/guilds/\(major: guildId)/members/\(userId)")
  }
  
  static func addRecipient(_ userId: String, in channelId: String) -> Endpoint {
    return .init(.PUT, "/channels/\(major: channelId)/recipients/\(userId)")
  }
  
  static func addRole(_ roleId: String, to userId: String, in guildId: String) -> Endpoint {
    return .init(.PUT, "/guilds/\(major: guildId)/members/\(userId)/roles/\(roleId)")
  }
  
  static func beginPrune(in guildId: String) -> Endpoint {
    return .init(.POST, "/guilds/\(major: guildId)/prune")
  }
  
  static func bulkDeleteMessages(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/messages/bulk-delete")
  }
  
  static func createBan(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.PUT, "/guilds/\(major: guildId)/bans/\(userId)")
  }
  
  static func createChannel(in guildId: String) -> Endpoint {
    return .init(.POST, "/guilds/\(major: guildId)/channels")
  }
  
  static var createDm: Endpoint {
    return .init(.POST, "/users/@me/channels")
  }
  
  static func createEmoji(in guildId: String) -> Endpoint {
    return .init(.POST, "/guilds/\(major: guildId)/emojis")
  }
  
  static var createGuild: Endpoint {
    return .init(.POST, "/guilds")
  }
  
  static func createIntegration(in guildId: String) -> Endpoint {
    return .init(.POST, "/guilds/\(major: guildId)/integrations")
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
  
  static func createRole(in guildId: String) -> Endpoint {
    return .init(.POST, "/guilds/\(major: guildId)/roles")
  }
  
  static func createWebhook(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/webhooks")
  }
  
  static func deleteChannel(_ channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)")
  }
  
  static func deleteChannelPermission(_ overwriteId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/permissions/\(overwriteId)")
  }
  
  static func deleteEmoji(_ emojiId: String, in guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)/emojis/\(emojiId)")
  }
  
  static func deleteGuild(_ guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)")
  }
  
  static func deleteIntegration(_ intId: String, in guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)/integrations/\(intId)")
  }
  
  static func deleteInvite(_ invId: String) -> Endpoint {
    return .init(.DELETE, "/invites/\(invId)")
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
  
  static func deleteRole(_ roleId: String, in guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)/roles/\(roleId)")
  }
  
  static func deleteWebhook(_ whId: String, token: String? = nil) -> Endpoint {
    guard let token = token else {
      return .init(.DELETE, "/webhooks/\(whId)")
    }
    
    return .init(.DELETE, "/webhooks/\(whId)/\(token)")
  }
  
  static func editChannelPermission(_ overwriteId: String, in channelId: String) -> Endpoint {
    return .init(.PUT, "/channels/\(major: channelId)/permissions/\(overwriteId)")
  }
  
  static func editMessage(_ messageId: String, in channelId: String) -> Endpoint {
    return .init(.PATCH, "/channels/\(major: channelId)/messages/\(messageId)")
  }
  
  static func executeWebhook(_ whId: String, token: String) -> Endpoint {
    return .init(.POST, "/webhooks/\(whId)/\(token)")
  }
  
  static func executeWebhookSlack(_ whId: String, token: String) -> Endpoint {
    return .init(.POST, "/webhooks/\(whId)/\(token)/slack")
  }
  
  static func executeWebhookGithub(_ whId: String, token: String) -> Endpoint {
    return .init(.POST, "/webhooks/\(whId)/\(token)/github")
  }
  
  static var gateway: Endpoint {
    return .init(.GET, "/gateway/bot")
  }
  
  static func getAuditLog(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/audit-logs")
  }
  
  static func getBan(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/bans/\(userId)")
  }
  
  static func getBans(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/bans")
  }
  
  static func getChannel(_ channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)")
  }
  
  static func getChannels(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/channels")
  }
  
  static var getConnections: Endpoint {
    return .init(.GET, "/users/@me/connections")
  }
  
  static var getDms: Endpoint {
    return .init(.GET, "/users/@me/channels")
  }
  
  static func getEmbed(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/embed")
  }
  
  static func getEmoji(_ emojiId: String, in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/emojis/\(emojiId)")
  }
  
  static func getGuild(_ guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)")
  }
  
  static func getGuildInvites(_ guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/invites")
  }
  
  static func getGuildWebhooks(_ guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/webhooks")
  }
  
  static func getIntegrations(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/integrations")
  }
  
  static func getInvite(_ invId: String) -> Endpoint {
    return .init(.GET, "/invites/\(invId)")
  }
  
  static func getInvites(in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/invites")
  }
  
  static func getMember(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/members/\(userId)")
  }
  
  static func getMembers(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/members")
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
  
  static func getPruneCount(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/prune")
  }
  
  static func getReaction(_ reactionId: String, from messageId: String, in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/messages/\(messageId)/reactions/\(reactionId)")
  }
  
  static func getRoles(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/roles")
  }
  
  static var getSelf: Endpoint {
    return .init(.GET, "/users/@me")
  }
  
  static var getSelfGuilds: Endpoint {
    return .init(.GET, "/users/@me/guilds")
  }
  
  static func getUser(_ userId: String) -> Endpoint {
    return .init(.GET, "/users/\(userId)")
  }
  
  static func getVanityUrl(for guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/vanity-url")
  }
  
  static func getVoiceRegions(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/regions")
  }
  
  static func getWebhook(_ whId: String, token: String? = nil) -> Endpoint {
    guard let token = token else {
      return .init(.GET, "/webhooks/\(whId)")
    }
    
    return .init(.GET, "/webhooks/\(whId)/\(token)")
  }
  
  static func getWebhooks(in channelId: String) -> Endpoint {
    return .init(.GET, "/channels/\(major: channelId)/webhooks")
  }
  
  static func getWidgetImage(for guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/widget.png")
  }
  
  static func leaveGuild(_ guildId: String) -> Endpoint {
    return .init(.DELETE, "/users/@me/guilds/\(guildId)")
  }
  
  static func listEmojis(in guildId: String) -> Endpoint {
    return .init(.GET, "/guilds/\(major: guildId)/emojis")
  }
  
  static var listVoiceRegions: Endpoint {
    return .init(.GET, "/voice/regions")
  }
  
  static func modifyChannel(_ channelId: String) -> Endpoint {
    return .init(.PATCH, "/channels/\(major: channelId)")
  }
  
  static func modifyChannelPositions(in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/channels")
  }
  
  static func modifyEmbed(in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/embed")
  }
  
  static func modifyEmoji(_ emojiId: String, in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/emojis/\(emojiId)")
  }
  
  static func modifyGuild(_ guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)")
  }
  
  static func modifyIntegration(_ intId: String, in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/integrations/\(intId)")
  }
  
  static func modifyMember(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/members/\(userId)")
  }
  
  static func modifyRole(_ roleId: String, in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/roles/\(roleId)")
  }
  
  static func modifyRolePositions(in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/roles")
  }
  
  static var modifySelf: Endpoint {
    return .init(.PATCH, "/users/@me")
  }
  
  static func modifySelfNickname(in guildId: String) -> Endpoint {
    return .init(.PATCH, "/guilds/\(major: guildId)/members/@me/nick")
  }
  
  static func modifyWebhook(_ whId: String, token: String? = nil) -> Endpoint {
    guard let token = token else {
      return .init(.PATCH, "/webhooks/\(whId)")
    }
    
    return .init(.PATCH, "/webhooks/\(whId)/\(token)")
  }
  
  static func removeBan(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)/bans/\(userId)")
  }
  
  static func removeMember(_ userId: String, in guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)/members/\(userId)")
  }
  
  static func removeRecipient(_ userId: String, in channelId: String) -> Endpoint {
    return .init(.DELETE, "/channels/\(major: channelId)/recipients/\(userId)")
  }
  
  static func removeRole(_ roleId: String, from userId: String, in guildId: String) -> Endpoint {
    return .init(.DELETE, "/guilds/\(major: guildId)/members/\(userId)/roles/\(roleId)")
  }
  
  static func syncIntegration(_ intId: String, in guildId: String) -> Endpoint {
    return .init(.POST, "/guilds/\(major: guildId)/integrations/\(intId)/sync")
  }
  
  static func triggerTyping(in channelId: String) -> Endpoint {
    return .init(.POST, "/channels/\(major: channelId)/typing")
  }
}
