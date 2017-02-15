//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Structure to create dynamic links
struct Endpoints {

  func gateway() -> String {
    return "/gateway/bot"
  }

  func addPinnedChannelMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/pins/\(messageId)"
  }

  func beginGuildPrune(_ guildId: String) -> String {
    return "/guilds/\(guildId)/prune"
  }

  func bulkDeleteMessages(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages/bulk-delete"
  }

  func createChannelInvite(_ channelId: String) -> String {
    return "/channels/\(channelId)/invites"
  }

  func createDM() -> String {
    return "/users/@me/channels"
  }

  func createGuildBan(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  func createGuildChannel(_ guildId: String) -> String {
    return "/guilds/\(guildId)/channels"
  }

  func createGuildIntegration(_ guildId: String) -> String {
    return "/guilds/\(guildId)/integrations"
  }

  func createGuildRole(_ guildId: String) -> String {
    return "/guilds/\(guildId)/roles"
  }

  func createMessage(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages"
  }

  func createReaction(_ channelId: String, _ messageId: String, _ reaction: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)/@me"
  }

  func createWebhook(_ channelId: String) -> String {
    return "/channels/\(channelId)/webhooks"
  }

  func deleteAllReactions(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions"
  }

  func deleteChannel(_ channelId: String) -> String {
    return "/channels/\(channelId)"
  }

  func deleteChannelPermission(_ channelId: String, _ overwriteId: String) -> String {
    return "/channels/\(channelId)/permissions/\(overwriteId)"
  }

  func deleteGuild(_ guildId: String) -> String {
    return "/guilds/\(guildId)"
  }

  func deleteGuildIntegration(_ guildId: String, _ integrationId: String) -> String {
    return "/guilds/\(guildId)/integrations/\(integrationId)"
  }

  func deleteGuildRole(_ guildId: String, _ roleId: String) -> String {
    return "/guilds/\(guildId)/roles/\(roleId)"
  }

  func deleteInvite(_ inviteId: String) -> String {
    return "/invites/\(inviteId)"
  }

  func deleteMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)"
  }

  func deleteOwnReaction(_ channelId: String, _ messageId: String, _ reaction: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)/@me"
  }

  func deletePinnedChannelMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/pins/\(messageId)"
  }

  func deleteUserReaction(_ channelId: String, _ messageId: String, _ reaction: String, _ userId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)/\(userId)"
  }

  func deleteWebhook(_ webhookId: String, _ webhookToken: String? = nil) -> String {
    if webhookToken != nil {
      return "/webhooks/\(webhookId)/\(webhookToken)"
    }else {
      return "/webhooks/\(webhookId)"
    }
  }

  func editChannelPermissions(_ channelId: String, _ overwriteId: String) -> String {
    return "/channels/\(channelId)/permissions/\(overwriteId)"
  }

  func editMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)"
  }

  func executeSlackWebhook(_ webhookId: String, _ webhookToken: String) -> String {
    return "/webhooks/\(webhookId)/\(webhookToken)/slack"
  }

  func executeWebhook(_ webhookId: String, _ webhookToken: String) -> String {
    return "/webhooks/\(webhookId)/\(webhookToken)"
  }

  func getChannel(_ channelId: String) -> String {
    return "/channels/\(channelId)"
  }

  func getChannelInvites(_ channelId: String) -> String {
    return "/channels/\(channelId)/invites"
  }

  func getChannelMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)"
  }

  func getChannelMessages(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages"
  }

  func getChannelWebhooks(_ channelId: String) -> String {
    return "/channels/\(channelId)/webhooks"
  }

  func getCurrentUser() -> String {
    return "/users/@me"
  }

  func getCurrentUserGuilds() -> String {
    return "/users/@me/guilds"
  }

  func getGuild(_ guildId: String) -> String {
    return "/guilds/\(guildId)"
  }

  func getGuildBans(_ guildId: String) -> String {
    return "/guilds/\(guildId)/bans"
  }

  func getGuildChannels(_ guildId: String) -> String {
    return "/guilds/\(guildId)/channels"
  }

  func getGuildEmbed(_ guildId: String) -> String {
    return "/guilds/\(guildId)/embed"
  }

  func getGuildIntegrations(_ guildId: String) -> String {
    return "/guilds/\(guildId)/integrations"
  }

  func getGuildInvites(_ guildId: String) -> String {
    return "/guilds/\(guildId)/invites"
  }

  func getGuildMember(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  func getGuildPruneCount(_ guildId: String) -> String {
    return "/guilds/\(guildId)/prune"
  }

  func getGuildRoles(_ guildId: String) -> String {
    return "/guilds/\(guildId)/roles"
  }

  func getGuildVoiceRegions(_ guildId: String) -> String {
    return "/guilds/\(guildId)/regions"
  }

  func getGuildWebhooks(_ guildId: String) -> String {
    return "/guilds/\(guildId)/webhooks"
  }

  func getInvite(_ inviteId: String) -> String {
    return "/invites/\(inviteId)"
  }

  func getPinnedMessages(_ channelId: String) -> String {
    return "/channels/\(channelId)/pins"
  }

  func getReactions(_ channelId: String, _ messageId: String, _ reaction: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)"
  }

  func getUser(_ userId: String) -> String {
    return "/users/\(userId)"
  }

  func getUserDM() -> String {
    return "/users/@me/channels"
  }

  func getWebhook(_ webhookId: String, _ webhookToken: String? = nil) -> String {
    if webhookToken != nil {
      return "/webhooks/\(webhookId)/\(webhookToken)"
    }else {
      return "/webhooks/\(webhookId)"
    }
  }

  func groupDMRemoveRecipient(_ channelId: String, _ userId: String) -> String {
    return "/channels/\(channelId)/recipients/\(userId)"
  }

  func leaveGuild(_ guildId: String) -> String {
    return "/users/@me/guilds/\(guildId)"
  }

  func listGuildMembers(_ guildId: String) -> String {
    return "/guilds/\(guildId)/members"
  }

  func modifyChannel(_ channelId: String) -> String {
    return "/channels/\(channelId)"
  }

  func modifyCurrentUser() -> String {
    return "/users/@me"
  }

  func modifyGuild(_ guildId: String) -> String {
    return "/guilds/\(guildId)"
  }

  func modifyGuildChannelPositions(_ guildId: String) -> String {
    return "/guilds/\(guildId)/channels"
  }

  func modifyGuildEmbed(_ guildId: String) -> String {
    return "/guilds/\(guildId)/embed"
  }

  func modifyGuildIntegration(_ guildId: String, _ integrationId: String) -> String {
    return "/guilds/\(guildId)/integrations/\(integrationId)"
  }

  func modifyGuildMember(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  func modifyGuildRole(_ guildId: String, _ roleId: String) -> String {
    return "/guilds/\(guildId)/roles/\(roleId)"
  }

  func modifyGuildRolePositions(_ guildId: String) -> String {
    return "/guilds/\(guildId)/roles"
  }

  func modifyWebhook(_ webhookId: String, _ webhookToken: String? = nil) -> String {
    if webhookToken != nil {
      return "/webhooks/\(webhookId)/\(webhookToken)"
    }else {
      return "/webhooks/\(webhookId)"
    }
  }

  func removeGuildBan(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/bans/\(userId)"
  }

  func removeGuildMember(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  func syncGuildIntegration(_ guildId: String, _ integrationId: String) -> String {
    return "/guilds/\(guildId)/integrations/\(integrationId)"
  }

  func triggerTypingIndicator(_ channelId: String) -> String {
    return "/channels/\(channelId)/typing"
  }

}
