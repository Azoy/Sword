//
//  AuditLog.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Represents a guild's audit log
public struct AuditLog {
  
  // MARK: Properties
  
  /// Array of audit log entries
  public internal(set) var entries = [AuditLog.Entry]()
  
  /// Array of users found in audit log
  public internal(set) var users = [User]()
  
  /// Array of webhooks found in audit log
  public internal(set) var webhooks = [Webhook]()
  
  // MARK: Initialzer
  
  /**
   Creates an AuditLog structure
   
   - parameter sword: Parent class to give users and webhooks
   - parameter json: Dictionary representation of audit log
  */
  init(_ sword: Sword, _ json: [String: [Any]]) {
    let entries = json["audit_log_entries"]!
    for entry in entries {
      self.entries.append(AuditLog.Entry(entry as! [String: Any]))
    }
    
    let users = json["users"]!
    for user in users {
      self.users.append(User(sword, user as! [String: Any]))
    }
    
    let webhooks = json["webhooks"]!
    for webhook in webhooks {
      self.webhooks.append(Webhook(sword, webhook as! [String: Any]))
    }
  }
  
}

extension AuditLog {
  
  /// Representation of an individual entry in audit logs
  public struct Entry {
    
    // MARK: Properties
    
    /// Type of action that occurred
    public let actionType: AuditLog.Entry.Event
    
    /// Array of changes made to targetId
    public internal(set) var changes = [AuditLog.Entry.Change]()
    
    /// ID of the audit log entry
    public let id: Snowflake
    
    /// Optional entry information for certain action types
    public let options: [String: Any]
    
    /// User provided reason for this entry
    public let reason: String
    
    /// ID of the affected entity
    public let targetId: Snowflake
    
    /// User ID that made this change
    public let userId: Snowflake
    
    // MARK: Initializer
    
    /**
     Creates an AuditLogEntry structure
     
     - parameter json: Dictionary representation of the entry
     */
    init(_ json: [String: Any]) {
      self.actionType = AuditLog.Entry.Event(
        rawValue: json["action_type"] as! Int
      )!
      
      let changes = json["changes"] as! [[String: Any]]
      for change in changes {
        self.changes.append(AuditLog.Entry.Change(change))
      }
      
      self.id = Snowflake(json["id"])!
      self.options = json["options"] as! [String: Any]
      self.reason = json["reason"] as! String
      self.targetId = Snowflake(json["target_id"])!
      self.userId = Snowflake(json["user_id"])!
    }
    
  }
  
}

extension AuditLog.Entry {
  
  /// Specific information of changes made to targetId
  public struct Change {
    
    // MARK: Properties
    
    /// Type of audit log change
    public let key: String
    
    /// New value after change
    public let newValue: Any
    
    /// Old value before change
    public let oldValue: Any
    
    // MARK: Initializer
    
    /**
     Creates an AuditLogChange structure
     
     - parameter json: Dictionary representation of a change
     */
    init(_ json: [String: Any]) {
      self.key = json["key"] as! String
      self.newValue = json["new_value"]!
      self.oldValue = json["old_value"]!
    }
    
  }
  
}

extension AuditLog.Entry {
  
  /// Type of action that occurs for an entry
  public enum Event: Int {
    
    /// A guild is updated
    case guildUpdate = 1
    
    /// A channel is created in a guild
    case channelCreate = 10
    
    /// A channel is updated in a guild
    case channelUpdate
    
    /// A channel is deleted in a guild
    case channelDelete
    
    /// A channel creates a new overwrite
    case channelOverwriteCreate
    
    /// A channel's overwrite is updated
    case channelOverwriteUpdate
    
    /// A chanenl's overwrite is deleted
    case channelOverwriteDelete
    
    /// A member is kicked from a guild
    case memberKick = 20
    
    /// Someone decides to prune inactive members
    case memberPrune
    
    /// A member of a guild was banned
    case memberBanAdd
    
    /// A member of a guild was unbanned
    case memberBanRemove
    
    /// A member of a guild was updated
    case memberUpdate
    
    /// A member's role was updated
    case memberRoleUpdate
    
    /// A role was created in a guild
    case roleCreate = 30
    
    /// A role was updated in a guild
    case roleUpdate
    
    /// A role was deleted in a guild
    case roleDelete
    
    /// An invite was created in a guild
    case inviteCreate = 40
    
    /// An invite was updated in a guild
    case inviteUpdate
    
    /// An invite was deleted in a guild
    case inviteDelete
    
    /// A webhook was created for a channel
    case webhookCreate = 50
    
    /// A webhook was updated for a channel
    case webhookUpdate
    
    /// A webhook was deleted for a channel
    case webhookDelete
    
    /// A custom emoji was created in a guild
    case emojiCreate = 60
    
    /// A custom emoji was updated in a guild
    case emojiUpdate
    
    /// A custom emoji was deleted in a guild
    case emojiDelete
    
    /// A message was deleted in a channel
    case messageDelete = 72
    
  }
  
}
