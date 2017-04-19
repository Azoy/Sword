//
//  Endpoints.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Structure to create dynamic links
struct Endpoints {

  static func gateway() -> String {
    return "/gateway/bot"
  }

  static func addPinnedChannelMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/pins/\(messageId)"
  }

  static func beginGuildPrune(_ guildId: String) -> String {
    return "/guilds/\(guildId)/prune"
  }

  static func bulkDeleteMessages(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages/bulk-delete"
  }

  static func createChannelInvite(_ channelId: String) -> String {
    return "/channels/\(channelId)/invites"
  }

  static func createDM() -> String {
    return "/users/@me/channels"
  }

  static func createGuild() -> String {
    return "/guilds"
  }

  static func createGuildBan(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  static func createGuildChannel(_ guildId: String) -> String {
    return "/guilds/\(guildId)/channels"
  }

  static func createGuildIntegration(_ guildId: String) -> String {
    return "/guilds/\(guildId)/integrations"
  }

  static func createGuildRole(_ guildId: String) -> String {
    return "/guilds/\(guildId)/roles"
  }

  static func createMessage(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages"
  }

  static func createReaction(_ channelId: String, _ messageId: String, _ reaction: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)/@me"
  }

  static func createWebhook(_ channelId: String) -> String {
    return "/channels/\(channelId)/webhooks"
  }

  static func deleteAllReactions(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions"
  }

  static func deleteChannel(_ channelId: String) -> String {
    return "/channels/\(channelId)"
  }

  static func deleteChannelPermission(_ channelId: String, _ overwriteId: String) -> String {
    return "/channels/\(channelId)/permissions/\(overwriteId)"
  }

  static func deleteGuild(_ guildId: String) -> String {
    return "/guilds/\(guildId)"
  }

  static func deleteGuildIntegration(_ guildId: String, _ integrationId: String) -> String {
    return "/guilds/\(guildId)/integrations/\(integrationId)"
  }

  static func deleteGuildRole(_ guildId: String, _ roleId: String) -> String {
    return "/guilds/\(guildId)/roles/\(roleId)"
  }

  static func deleteInvite(_ inviteId: String) -> String {
    return "/invites/\(inviteId)"
  }

  static func deleteMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)"
  }

  static func deleteOwnReaction(_ channelId: String, _ messageId: String, _ reaction: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)/@me"
  }

  static func deletePinnedChannelMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/pins/\(messageId)"
  }

  static func deleteUserReaction(_ channelId: String, _ messageId: String, _ reaction: String, _ userId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)/\(userId)"
  }

  static func deleteWebhook(_ webhookId: String, _ webhookToken: String? = nil) -> String {
    if webhookToken != nil {
      return "/webhooks/\(webhookId)/\(webhookToken!)"
    }else {
      return "/webhooks/\(webhookId)"
    }
  }

  static func editChannelPermissions(_ channelId: String, _ overwriteId: String) -> String {
    return "/channels/\(channelId)/permissions/\(overwriteId)"
  }

  static func editMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)"
  }

  static func executeSlackWebhook(_ webhookId: String, _ webhookToken: String) -> String {
    return "/webhooks/\(webhookId)/\(webhookToken)/slack"
  }

  static func executeWebhook(_ webhookId: String, _ webhookToken: String) -> String {
    return "/webhooks/\(webhookId)/\(webhookToken)"
  }

  static func getChannel(_ channelId: String) -> String {
    return "/channels/\(channelId)"
  }

  static func getChannelInvites(_ channelId: String) -> String {
    return "/channels/\(channelId)/invites"
  }

  static func getChannelMessage(_ channelId: String, _ messageId: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)"
  }

  static func getChannelMessages(_ channelId: String) -> String {
    return "/channels/\(channelId)/messages"
  }

  static func getChannelWebhooks(_ channelId: String) -> String {
    return "/channels/\(channelId)/webhooks"
  }

  static func getCurrentUser() -> String {
    return "/users/@me"
  }

  static func getCurrentUserGuilds() -> String {
    return "/users/@me/guilds"
  }

  static func getGuild(_ guildId: String) -> String {
    return "/guilds/\(guildId)"
  }

  static func getGuildBans(_ guildId: String) -> String {
    return "/guilds/\(guildId)/bans"
  }

  static func getGuildChannels(_ guildId: String) -> String {
    return "/guilds/\(guildId)/channels"
  }

  static func getGuildEmbed(_ guildId: String) -> String {
    return "/guilds/\(guildId)/embed"
  }

  static func getGuildIntegrations(_ guildId: String) -> String {
    return "/guilds/\(guildId)/integrations"
  }

  static func getGuildInvites(_ guildId: String) -> String {
    return "/guilds/\(guildId)/invites"
  }

  static func getGuildMember(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  static func getGuildPruneCount(_ guildId: String) -> String {
    return "/guilds/\(guildId)/prune"
  }

  static func getGuildRoles(_ guildId: String) -> String {
    return "/guilds/\(guildId)/roles"
  }

  static func getGuildVoiceRegions(_ guildId: String) -> String {
    return "/guilds/\(guildId)/regions"
  }

  static func getGuildWebhooks(_ guildId: String) -> String {
    return "/guilds/\(guildId)/webhooks"
  }

  static func getInvite(_ inviteId: String) -> String {
    return "/invites/\(inviteId)"
  }

  static func getPinnedMessages(_ channelId: String) -> String {
    return "/channels/\(channelId)/pins"
  }

  static func getReactions(_ channelId: String, _ messageId: String, _ reaction: String) -> String {
    return "/channels/\(channelId)/messages/\(messageId)/reactions/\(reaction)"
  }

  static func getUser(_ userId: String) -> String {
    return "/users/\(userId)"
  }

  static func getUserDM() -> String {
    return "/users/@me/channels"
  }

  static func getWebhook(_ webhookId: String, _ webhookToken: String? = nil) -> String {
    if webhookToken != nil {
      return "/webhooks/\(webhookId)/\(webhookToken!)"
    }else {
      return "/webhooks/\(webhookId)"
    }
  }

  static func groupDMRemoveRecipient(_ channelId: String, _ userId: String) -> String {
    return "/channels/\(channelId)/recipients/\(userId)"
  }

  static func leaveGuild(_ guildId: String) -> String {
    return "/users/@me/guilds/\(guildId)"
  }

  static func listGuildMembers(_ guildId: String) -> String {
    return "/guilds/\(guildId)/members"
  }

  static func modifyChannel(_ channelId: String) -> String {
    return "/channels/\(channelId)"
  }

  static func modifyCurrentUser() -> String {
    return "/users/@me"
  }

  static func modifyGuild(_ guildId: String) -> String {
    return "/guilds/\(guildId)"
  }

  static func modifyGuildChannelPositions(_ guildId: String) -> String {
    return "/guilds/\(guildId)/channels"
  }

  static func modifyGuildEmbed(_ guildId: String) -> String {
    return "/guilds/\(guildId)/embed"
  }

  static func modifyGuildIntegration(_ guildId: String, _ integrationId: String) -> String {
    return "/guilds/\(guildId)/integrations/\(integrationId)"
  }

  static func modifyGuildMember(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  static func modifyGuildRole(_ guildId: String, _ roleId: String) -> String {
    return "/guilds/\(guildId)/roles/\(roleId)"
  }

  static func modifyGuildRolePositions(_ guildId: String) -> String {
    return "/guilds/\(guildId)/roles"
  }

  static func modifyWebhook(_ webhookId: String, _ webhookToken: String? = nil) -> String {
    if webhookToken != nil {
      return "/webhooks/\(webhookId)/\(webhookToken!)"
    }else {
      return "/webhooks/\(webhookId)"
    }
  }

  static func removeGuildBan(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/bans/\(userId)"
  }

  static func removeGuildMember(_ guildId: String, _ userId: String) -> String {
    return "/guilds/\(guildId)/members/\(userId)"
  }

  static func syncGuildIntegration(_ guildId: String, _ integrationId: String) -> String {
    return "/guilds/\(guildId)/integrations/\(integrationId)"
  }

  static func triggerTypingIndicator(_ channelId: String) -> String {
    return "/channels/\(channelId)/typing"
  }

}
