//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

enum Endpoint {

  case gateway

  case addPinnedChannelMessage(channel: Snowflake, message: Snowflake)

  case beginGuildPrune(Snowflake)

  case bulkDeleteMessages(Snowflake)

  case createChannelInvite(Snowflake)

  case createDM

  case createGuild

  case createGuildBan(guild: Snowflake, user: Snowflake)

  case createGuildChannel(Snowflake)

  case createGuildIntegration(Snowflake)

  case createGuildRole(Snowflake)

  case createMessage(Snowflake)

  case createReaction(channel: Snowflake, message: Snowflake, emoji: String)

  case createWebhook(Snowflake)

  case deleteAllReactions(channel: Snowflake, message: Snowflake)

  case deleteChannel(Snowflake)

  case deleteChannelPermission(channel: Snowflake, overwrite: Snowflake)

  case deleteGuild(Snowflake)

  case deleteGuildIntegration(guild: Snowflake, integration: Snowflake)

  case deleteGuildRole(guild: Snowflake, role: Snowflake)

  case deleteInvite(Snowflake)

  case deleteMessage(channel: Snowflake, message: Snowflake)

  case deleteOwnReaction(channel: Snowflake, message: Snowflake, emoji: String)

  case deletePinnedChannelMessage(channel: Snowflake, message: Snowflake)

  case deleteUserReaction(channel: Snowflake, message: Snowflake, emoji: String, user: Snowflake)

  case deleteWebhook(webhook: Snowflake, token: String?)

  case editChannelPermissions(channel: Snowflake, overwrite: Snowflake)

  case editMessage(channel: Snowflake, message: Snowflake)

  case executeSlackWebhook(webhook: Snowflake, token: String)

  case executeWebhook(webhook: Snowflake, token: String)

  case getChannel(Snowflake)

  case getChannelInvites(Snowflake)

  case getChannelMessage(channel: Snowflake, message: Snowflake)

  case getChannelMessages(Snowflake)

  case getChannelWebhooks(Snowflake)

  case getCurrentUser

  case getCurrentUserGuilds

  case getGuild(Snowflake)

  case getGuildBans(Snowflake)

  case getGuildChannels(Snowflake)

  case getGuildEmbed(Snowflake)

  case getGuildIntegrations(Snowflake)

  case getGuildInvites(Snowflake)

  case getGuildMember(guild: Snowflake, user: Snowflake)

  case getGuildPruneCount(Snowflake)

  case getGuildRoles(Snowflake)

  case getGuildVoiceRegions(Snowflake)

  case getGuildWebhooks(Snowflake)

  case getInvite(Snowflake)

  case getPinnedMessages(Snowflake)

  case getReactions(channel: Snowflake, message: Snowflake, emoji: String)

  case getUser(Snowflake)

  case getUserConnections

  case getUserDM

  case getWebhook(webhook: Snowflake, token: String?)

  case groupDMRemoveRecipient(channel: Snowflake, user: Snowflake)

  case leaveGuild(Snowflake)

  case listGuildMembers(Snowflake)

  case modifyChannel(Snowflake)

  case modifyCurrentUser

  case modifyGuild(Snowflake)

  case modifyGuildChannelPositions(Snowflake)

  case modifyGuildEmbed(Snowflake)

  case modifyGuildIntegration(guild: Snowflake, integration: Snowflake)

  case modifyGuildMember(guild: Snowflake, user: Snowflake)

  case modifyGuildRole(guild: Snowflake, role: Snowflake)

  case modifyGuildRolePositions(Snowflake)

  case modifyWebhook(webhook: Snowflake, token: String?)

  case removeGuildBan(guild: Snowflake, user: Snowflake)

  case removeGuildMember(guild: Snowflake, user: Snowflake)

  case syncGuildIntegration(guild: Snowflake, integration: Snowflake)

  case triggerTypingIndicator(Snowflake)

}
