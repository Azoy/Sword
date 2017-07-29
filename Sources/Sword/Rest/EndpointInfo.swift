//
//  EndpointInfo.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

typealias EndpointInfo = (method: HTTPMethod, url: String)

extension Endpoint {

  var httpInfo: EndpointInfo {
    switch self {

      case .gateway:
        return (.get, "/gateway/bot")

      case let .addPinnedChannelMessage(channel, message):
        return (.post, "/channels/\(channel)/pins/\(message)")

      case let .beginGuildPrune(guild):
        return (.post, "/guilds/\(guild)/prune")

      case let .bulkDeleteMessages(channel):
        return (.post, "/channels/\(channel)/messages/bulk-delete")

      case let .createChannelInvite(channel):
        return (.post, "/channels/\(channel)/invites")

      case .createDM:
        return (.post, "/users/@me/channels")

      case .createGuild:
        return (.post, "/guilds")

      case let .createGuildBan(guild, user):
        return (.put, "/guilds/\(guild)/bans/\(user)")

      case let .createGuildChannel(guild):
        return (.post, "/guilds/\(guild)/channels")

      case let .createGuildIntegration(guild):
        return (.post, "/guilds/\(guild)/integrations")

      case let .createGuildRole(guild):
        return (.post, "/guilds/\(guild)/roles")

      case let .createMessage(channel):
        return (.post, "/channels/\(channel)/messages")

      case let .createReaction(channel, message, reaction):
        return (.put, "/channels/\(channel)/messages/\(message)/reactions/\(reaction)/@me")

      case let .createWebhook(channel):
        return (.post, "/channels/\(channel)/webhooks")

      case let .deleteAllReactions(channel, message):
        return (.delete, "/channels/\(channel)/messages/\(message)/reactions")

      case let .deleteChannel(channel):
        return (.delete, "/channels/\(channel)")

      case let .deleteChannelPermission(channel, overwrite):
        return (.delete, "/channels/\(channel)/permissions/\(overwrite)")

      case let .deleteGuild(guild):
        return (.delete, "/guilds/\(guild)")

      case let .deleteGuildIntegration(guild, integration):
        return (.delete, "/guilds/\(guild)/integrations/\(integration)")

      case let .deleteGuildRole(guild, role):
        return (.delete, "/guilds/\(guild)/roles/\(role)")

      case let .deleteInvite(invite):
        return (.delete, "/invites/\(invite)")

      case let .deleteMessage(channel, message):
        return (.delete, "/channels/\(channel)/messages/\(message)")

      case let .deleteOwnReaction(channel, message, reaction):
        return (.delete, "/channels/\(channel)/messages/\(message)/reactions/\(reaction)/@me")

      case let .deletePinnedChannelMessage(channel, message):
        return (.delete, "/channels/\(channel)/messages/\(message)")

      case let .deleteUserReaction(channel, message, reaction, user):
        return (.delete, "/channels/\(channel)/messages/\(message)/reactions/\(reaction)/\(user)")

      case let .deleteWebhook(webhook, token):
        if let token = token {
          return (.delete, "/webhooks/\(webhook)/\(token)")
        }

        return (.delete, "/webhooks/\(webhook)")

      case let .editChannelPermissions(channel, overwrite):
        return (.put, "/channels/\(channel)/permissions/\(overwrite)")

      case let .editMessage(channel, message):
        return (.patch, "/channels/\(channel)/messages/\(message)")

      case let .executeSlackWebhook(webhook, token):
        return (.post, "/webhooks/\(webhook)/\(token)")

      case let .executeWebhook(webhook, token):
        return (.post, "/webhooks/\(webhook)/\(token)")

      case let .getChannel(channel):
        return (.get, "/channels/\(channel)")

      case let .getChannelInvites(channel):
        return (.get, "/channels/\(channel)/invites")

      case let .getChannelMessage(channel, message):
        return (.get, "/channels/\(channel)/messages/\(message)")

      case let .getChannelMessages(channel):
        return (.get, "/channels/\(channel)/messages")

      case let .getChannelWebhooks(channel):
        return (.get, "/channels/\(channel)/webhooks")

      case .getCurrentUser:
        return (.get, "/users/@me")

      case .getCurrentUserGuilds:
        return (.get, "/users/@me/guilds")

      case let .getGuild(guild):
        return (.get, "/guilds/\(guild)")
      
      case let .getGuildAuditLogs(guild):
        return (.get, "/guilds/\(guild)/audit-logs")
      
      case let .getGuildBans(guild):
        return (.get, "/guilds/\(guild)/bans")

      case let .getGuildChannels(guild):
        return (.get, "/guilds/\(guild)/channels")

      case let .getGuildEmbed(guild):
        return (.get, "/guilds/\(guild)/embed")

      case let .getGuildIntegrations(guild):
        return (.get, "/guilds/\(guild)/integrations")

      case let .getGuildInvites(guild):
        return (.get, "/guilds/\(guild)/invites")

      case let .getGuildMember(guild, user):
        return (.get, "/guilds/\(guild)/members/\(user)")

      case let .getGuildPruneCount(guild):
        return (.get, "/guilds/\(guild)/prune")

      case let .getGuildRoles(guild):
        return (.get, "/guilds/\(guild)/roles")

      case let .getGuildVoiceRegions(guild):
        return (.get, "/guilds/\(guild)/regions")

      case let .getGuildWebhooks(guild):
        return (.get, "/guilds/\(guild)/webhooks")

      case let .getInvite(invite):
        return (.get, "/invites/\(invite)")

      case let .getPinnedMessages(channel):
        return (.get, "/channels/\(channel)/pins")

      case let .getReactions(channel, message, reaction):
        return (.get, "/channels/\(channel)/messages/\(message)/reactions/\(reaction)")

      case let .getUser(user):
        return (.get, "/users/\(user)")

      case .getUserConnections:
        return (.get, "/users/@me/connections")

      case .getUserDM:
        return (.get, "/users/@me/channels")

      case let .getWebhook(webhook, token):
        if let token = token {
          return (.get, "/webhooks/\(webhook)/\(token)")
        }

        return (.get, "/webhooks/\(webhook)")

      case let .groupDMRemoveRecipient(channel, user):
        return (.delete, "/channels/\(channel)/recipients/\(user)")

      case let .leaveGuild(guild):
        return (.delete, "/users/@me/guilds/\(guild)")

      case let .listGuildMembers(guild):
        return (.get, "/guilds/\(guild)/members")

      case let .modifyChannel(channel):
        return (.patch, "/channels/\(channel)")

      case .modifyCurrentUser:
        return (.patch, "/users/@me")

      case let .modifyGuild(guild):
        return (.patch, "/guilds/\(guild)")

      case let .modifyGuildChannelPositions(guild):
        return (.patch, "/guilds/\(guild)/channels")

      case let .modifyGuildEmbed(guild):
        return (.patch, "/guilds/\(guild)/embed")

      case let .modifyGuildIntegration(guild, integration):
        return (.patch, "/guilds/\(guild)/integrations/\(integration)")

      case let .modifyGuildMember(guild, user):
        return (.patch, "/guilds/\(guild)/members/\(user)")

      case let .modifyGuildRole(guild, role):
        return (.patch, "/guilds/\(guild)/roles/\(role)")

      case let .modifyGuildRolePositions(guild):
        return (.patch, "/guilds/\(guild)/roles")

      case let .modifyWebhook(webhook, token):
        if let token = token {
          return (.patch, "/webhooks/\(webhook)/\(token)")
        }

        return (.patch, "/webhooks/\(webhook)")

      case let .removeGuildBan(guild, user):
        return (.delete, "/guilds/\(guild)/bans/\(user)")

      case let .removeGuildMember(guild, user):
        return (.delete, "/guilds/\(guild)/members/\(user)")

      case let .syncGuildIntegration(guild, integration):
        return (.post, "/guilds/\(guild)/integrations/\(integration)")

      case let .triggerTypingIndicator(channel):
        return (.post, "/channels/\(channel)/typing")
    }
  }

}
