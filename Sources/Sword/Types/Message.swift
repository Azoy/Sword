//
//  Message.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

public struct Message: Codable {
  public let id: Snowflake
}

extension Message {
  /// Message content to send to a channel
  public struct Content: Encodable {
    /// The message
    public var content: String
    
    /// The rich shiny embed
    public var embed: String?
    
    /// Used for optimistic message sending
    public var nonce: Snowflake?
    
    /// Whether or not this message speaks to you
    public var tts: Bool?
  }
}

extension Message.Content: ExpressibleByStringLiteral {
  public typealias StringLiteralType = String
  
  /// Init from a string literal
  ///
  /// - parameter value: The string literal to use as the message content
  public init(stringLiteral value: String) {
    self.content = value
    self.nonce = nil
    self.tts = nil
    self.embed = nil
  }
}
