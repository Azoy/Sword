//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

enum Endpoint {

  case gateway

  case addPinnedChannelMessage(String, String)

  case beginGuildPrune(String)

  case bulkDeleteMessages(String)

  case createChannelInvite(String)

  case createDM

  case createGuild

  case createGuildBan(String, String)

  case createGuildChannel(String)

  case createGuildIntegration(String)

  case createGuildRole(String)

  case createMessage(String)

  case createReaction(String, String, String)

  case createWebhook(String)

  case deleteAllReactions(String, String)

  case deleteChannel(String)

  case deleteChannelPermission(String, String)

  case deleteGuild(String)

  case deleteGuildIntegration(String, String)

  case deleteGuildRole(String, String)

  case deleteInvite(String)

  case deleteMessage(String, String)

  case deleteOwnReaction(String, String, String)

  case deletePinnedChannelMessage(String, String)

  case deleteUserReaction(String, String, String, String)

  case deleteWebhook(String, String?)

  case editChannelPermissions(String, String)

  case editMessage(String, String)

  case executeSlackWebhook(String, String)

  case executeWebhook(String, String)

  case getChannel(String)

  case getChannelInvites(String)

  case getChannelMessage(String, String)

  case getChannelMessages(String)

  case getChannelWebhooks(String)

  case getCurrentUser

  case getCurrentUserGuilds

  case getGuild(String)

  case getGuildBans(String)

  case getGuildChannels(String)

  case getGuildEmbed(String)

  case getGuildIntegrations(String)

  case getGuildInvites(String)
  
  case getGuildMember(String, String)

  case getGuildPruneCount(String)

  case getGuildRoles(String)

  case getGuildVoiceRegions(String)

  case getGuildWebhooks(String)

  case getInvite(String)

  case getPinnedMessages(String)

  case getReactions(String, String, String)

  case getUser(String)

  case getUserConnections

  case getUserDM

  case getWebhook(String, String?)

  case groupDMRemoveRecipient(String, String)

  case leaveGuild(String)

  case listGuildMembers(String)

  case modifyChannel(String)

  case modifyCurrentUser

  case modifyGuild(String)

  case modifyGuildChannelPositions(String)

  case modifyGuildEmbed(String)

  case modifyGuildIntegration(String, String)

  case modifyGuildMember(String, String)

  case modifyGuildRole(String, String)

  case modifyGuildRolePositions(String)

  case modifyWebhook(String, String?)

  case removeGuildBan(String, String)

  case removeGuildMember(String, String)

  case syncGuildIntegration(String, String)

  case triggerTypingIndicator(String)

}
