//
//  JSON.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

extension Sword {
  /// Used in situations where the type is not known when decoding JSON
  enum JSON {
    /// Represents an array of JSON representables
    case array([JSON])
    
    /// Represents a JSON boolean
    case bool(Bool)
    
    /// Represents a JSON object keyed by strings
    case dictionary([String: JSON])
    
    /// Represents a JSON integer
    case int(Int)
    
    /// Represents a JSON string
    case string(String)
    
    /// Tries to get a boolean value from the current JSON
    var bool: Bool? {
      if case let .bool(bool) = self {
        return bool
      }
      
      return nil
    }
    
    /// Tries to get an integer value from the current JSON
    var int: Int? {
      if case let .int(int) = self {
        return int
      }
      
      return nil
    }
    
    /// Tries to get a string value from the current JSON
    var string: String? {
      if case let .string(string) = self {
        return string
      }
      
      return nil
    }
    
    /// Tries to access an array's element at index from the current JSON
    subscript(index: Int) -> JSON? {
      if case let .array(arr) = self {
        return arr[index]
      }
      
      return nil
    }
    
    /// Tries to access a dictionary's key->value from the current JSON
    subscript(member: String) -> JSON? {
      if case let .dictionary(dict) = self {
        return dict[member]
      }
      
      return nil
    }
  }
}

extension Sword.JSON: Encodable {
  /// Encode to JSON
  ///
  /// - parameter encoder: JSONEncoder
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    
    switch self {
    case let .array(array):
      try container.encode(array)
    case let .bool(bool):
      try container.encode(bool)
    case let .dictionary(dict):
      try container.encode(dict)
    case let .int(int):
      try container.encode(int)
    case let .string(string):
      try container.encode(string)
    }
  }
}

extension Sword.JSON: Decodable {
  /// Decode from JSON
  ///
  /// - parameter decoder: JSONDecoder
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    if let array = try? container.decode([Sword.JSON].self) {
      self = .array(array)
      return
    }
    
    if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
      return
    }
    
    if let dict = try? container.decode([String: Sword.JSON].self) {
      self = .dictionary(dict)
      return
    }
    
    if let int = try? container.decode(Int.self) {
      self = .int(int)
      return
    }
    
    if let string = try? container.decode(String.self) {
      self = .string(string)
      return
    }
    
    throw Sword.Error("Unable to decode JSON")
  }
}
