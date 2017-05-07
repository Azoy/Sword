//
//  EndpointInfo.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

typealias EndpointInfo = (url: String, method: HTTPMethod)

extension Endpoint {

  var httpInfo: EndpointInfo {
    switch self {

      case .gateway:
        return ("/gateway/bot", .get)

      case let .addPinnedChannelMessage(channel, message):
        return ("/channels/\(channel)/pins/\(message)", .post)

      case let .beginGuildPrune(guild):
        return ("/guilds/\(guild)/prune", .post)

      case let .bulkDeleteMessages(channel):
        return ("/channels/\(channel)/messages/bulk-delete", .post)

      case let .createChannelInvite(channel):
        return ("/channels/\(channel)/invites", .post)

      case .createDM:
        return ("/users/@me/channels", .post)

      case .createGuild:
        return ("/guilds", .post)

      case let .createGuildBan(guild, user):
        return ("/guilds/\(guild)/members/\(user)", .put)

      case let .createGuildChannel(guild):
        return ("/guilds/\(guild)/channels", .post)

      case let .createGuildIntegration(guild):
        return ("/guilds/\(guild)/integrations", .post)

      case let .createGuildRole(guild):
        return ("/guilds/\(guild)/roles", .post)

      case let .createMessage(channel):
        return ("/channels/\(channel)/message", .post)

      case let .createReaction(channel, message, reaction):
        return ("/channels/\(channel)/messages/\(message)/reactions/\(reaction)/@me", .put)

      case let .createWebhook(channel):
        return ("/channels/\(channel)/webhooks", .post)

      case let .deleteAllReactions(channel, message):
        return ("/channels/\(channel)/messages/\(message)/reactions", .delete)

      case let .deleteChannel(channel):
        return ("/channels/\(channel)", .delete)

      case let .deleteChannelPermission(channel, overwrite):
        return ("/channels/\(channel)/permissions/\(overwrite)", .delete)

      case let .deleteGuild(guild):
        return ("/guilds/\(guild)", .delete)

      case let .deleteGuildIntegration(guild, integration):
        return ("/guilds/\(guild)/integrations/\(integration)", .delete)

      case let .deleteGuildRole(guild, role):
        return ("/guilds/\(guild)/roles/\(role)", .delete)

      case let .deleteInvite(invite):
        return ("/invites/\(invite)", .delete)

      case let .deleteMessage(channel, message):
        return ("/channels/\(channel)/messages/\(message)", .delete)

      case let .deleteOwnReaction(channel, message, reaction):
        return ("/channels/\(channel)/messages/\(message)/reactions/\(reaction)/@me", .delete)

      case let .deletePinnedChannelMessage(channel, message):
        return ("/channels/\(channel)/messages/\(message)", .delete)

      case let .deleteUserReaction(channel, message, reaction, user):
        return ("/channels/\(channel)/messages/\(message)/reactions/\(reaction)/\(user)", .delete)

      case let .deleteWebhook(webhook, token):
        if token != nil {
          return ("/webhooks/\(webhook)/\(token!)", .delete)
        }

        return ("/webhooks/\(webhook)", .delete)

      case let .editChannelPermissions(channel, overwrite):
        return ("/channels/\(channel)/permissions/\(overwrite)", .put)

      case let .editMessage(channel, message):
        return ("/channels/\(channel)/messages/\(message)", .patch)

      case let .executeSlackWebhook(webhook, token):
        return ("/webhooks/\(webhook)/\(token)", .post)

      case let .executeWebhook(webhook, token):
        return ("/webhooks/\(webhook)/\(token)", .post)

      case let .getChannel(channel):
        return ("/channels/\(channel)", .get)

      case let .getChannelInvites(channel):
        return ("/channels/\(channel)/invites", .get)

      case let .getChannelMessage(channel, message):
        return ("/channels/\(channel)/messages/\(message)", .get)

      case let .getChannelMessages(channel):
        return ("/channels/\(channel)/messages", .get)

      case let .getChannelWebhooks(channel):
        return ("/channels/\(channel)/webhooks", .get)

      case .getCurrentUser:
        return ("/users/@me", .get)

      case .getCurrentUserGuilds:
        return ("/users/@me/guilds", .get)

      case let .getGuild(guild):
        return ("/guilds/\(guild)", .get)

      case let .getGuildBans(guild):
        return ("/guilds/\(guild)/bans", .get)

      case let .getGuildChannels(guild):
        return ("/guilds/\(guild)/channels", .get)

      case let .getGuildEmbed(guild):
        return ("/guilds/\(guild)/embed", .get)

      case let .getGuildIntegrations(guild):
        return ("/guilds/\(guild)/integrations", .get)

      case let .getGuildInvites(guild):
        return ("/guilds/\(guild)/invites", .get)

      case let .getGuildMember(guild, user):
        return ("/guilds/\(guild)/members/\(user)", .get)

      case let .getGuildPruneCount(guild):
        return ("/guilds/\(guild)/prune", .get)

      case let .getGuildRoles(guild):
        return ("/guilds/\(guild)/roles", .get)

      case let .getGuildVoiceRegions(guild):
        return ("/guilds/\(guild)/regions", .get)

      case let .getGuildWebhooks(guild):
        return ("/guilds/\(guild)/webhooks", .get)

      case let .getInvite(invite):
        return ("/invites/\(invite)", .get)

      case let .getPinnedMessages(channel):
        return ("/channels/\(channel)/pins", .get)

      case let .getReactions(channel, message, reaction):
        return ("/channels/\(channel)/messages/\(message)/reactions/\(reaction)", .get)

      case let .getUser(user):
        return ("/users/\(user)", .get)

      case .getUserDM:
        return ("/users/@me/channels", .get)

      case let .getWebhook(webhook, token):
        if token != nil {
          return ("/webhooks/\(webhook)/\(token!)", .get)
        }

        return ("/webhooks/\(webhook)", .get)

      case let .groupDMRemoveRecipient(channel, user):
        return ("/channels/\(channel)/recipients/\(user)", .delete)

      case let .leaveGuild(guild):
        return ("/users/@me/guilds/\(guild)", .delete)

      case let .listGuildMembers(guild):
        return ("/guilds/\(guild)/members", .get)

      case let .modifyChannel(channel):
        return ("/channels/\(channel)", .patch)

      case .modifyCurrentUser:
        return ("/users/@me", .patch)

      case let .modifyGuild(guild):
        return ("/guilds/\(guild)", .patch)

      case let .modifyGuildChannelPositions(guild):
        return ("/guilds/\(guild)/channels", .patch)

      case let .modifyGuildEmbed(guild):
        return ("/guilds/\(guild)/embed", .patch)

      case let .modifyGuildIntegration(guild, integration):
        return ("/guilds/\(guild)/integrations/\(integration)", .patch)

      case let .modifyGuildMember(guild, user):
        return ("/guilds/\(guild)/members/\(user)", .patch)

      case let .modifyGuildRole(guild, role):
        return ("/guilds/\(guild)/roles/\(role)", .patch)

      case let .modifyGuildRolePositions(guild):
        return ("/guilds/\(guild)/roles", .patch)

      case let .modifyWebhook(webhook, token):
        if token != nil {
          return ("/webhooks/\(webhook)/\(token!)", .patch)
        }

        return ("/webhooks/\(webhook)", .patch)

      case let .removeGuildBan(guild, user):
        return ("/guilds/\(guild)/bans/\(user)", .delete)

      case let .removeGuildMember(guild, user):
        return ("/guilds/\(guild)/members/\(user)", .delete)

      case let .syncGuildIntegration(guild, integration):
        return ("/guilds/\(guild)/integrations/\(integration)", .post)

      case let .triggerTypingIndicator(channel):
        return ("/channels/\(channel)/typing", .post)
    }
  }

}
