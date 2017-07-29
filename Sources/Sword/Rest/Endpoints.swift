//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

enum Endpoint {

  case gateway

  case addPinnedChannelMessage(ChannelID, MessageID)

  case beginGuildPrune(GuildID)

  case bulkDeleteMessages(ChannelID)

  case createChannelInvite(ChannelID)

  case createDM

  case createGuild

  case createGuildBan(GuildID, UserID)

  case createGuildChannel(GuildID)

  case createGuildIntegration(GuildID)

  case createGuildRole(GuildID)

  case createMessage(ChannelID)

  case createReaction(ChannelID, MessageID, String)

  case createWebhook(ChannelID)

  case deleteAllReactions(ChannelID, MessageID)

  case deleteChannel(ChannelID)

  case deleteChannelPermission(ChannelID, OverwriteID)

  case deleteGuild(GuildID)

  case deleteGuildIntegration(GuildID, IntegrationID)

  case deleteGuildRole(GuildID, RoleID)

  case deleteInvite(invite: String)

  case deleteMessage(ChannelID, MessageID)

  case deleteOwnReaction(ChannelID, MessageID, String)

  case deletePinnedChannelMessage(ChannelID, MessageID)

  case deleteUserReaction(ChannelID, MessageID, String, UserID)

  case deleteWebhook(WebhookID, String?)

  case editChannelPermissions(ChannelID, OverwriteID)

  case editMessage(ChannelID, MessageID)

  case executeSlackWebhook(WebhookID, String)

  case executeWebhook(WebhookID, String)

  case getChannel(ChannelID)

  case getChannelInvites(ChannelID)

  case getChannelMessage(ChannelID, MessageID)

  case getChannelMessages(ChannelID)

  case getChannelWebhooks(ChannelID)

  case getCurrentUser

  case getCurrentUserGuilds

  case getGuild(GuildID)
  
  case getGuildAuditLogs(GuildID)
  
  case getGuildBans(GuildID)

  case getGuildChannels(GuildID)

  case getGuildEmbed(GuildID)

  case getGuildIntegrations(GuildID)

  case getGuildInvites(GuildID)

  case getGuildMember(GuildID, UserID)

  case getGuildPruneCount(GuildID)

  case getGuildRoles(GuildID)

  case getGuildVoiceRegions(GuildID)

  case getGuildWebhooks(GuildID)

  case getInvite(invite: String)

  case getPinnedMessages(ChannelID)

  case getReactions(ChannelID, MessageID, String)

  case getUser(UserID)

  case getUserConnections

  case getUserDM

  case getWebhook(WebhookID, String?)

  case groupDMRemoveRecipient(ChannelID, UserID)

  case leaveGuild(GuildID)

  case listGuildMembers(GuildID)

  case modifyChannel(ChannelID)

  case modifyCurrentUser

  case modifyGuild(GuildID)

  case modifyGuildChannelPositions(GuildID)

  case modifyGuildEmbed(GuildID)

  case modifyGuildIntegration(GuildID, IntegrationID)

  case modifyGuildMember(GuildID, UserID)

  case modifyGuildRole(GuildID, RoleID)

  case modifyGuildRolePositions(GuildID)

  case modifyWebhook(WebhookID, String?)

  case removeGuildBan(GuildID, UserID)

  case removeGuildMember(GuildID, UserID)

  case syncGuildIntegration(GuildID, IntegrationID)

  case triggerTypingIndicator(ChannelID)

}
