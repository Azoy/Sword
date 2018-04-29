//
//  JSON.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Used in situations where the type is not known when decoding JSON
public enum JSON {
  /// Represents a JSON boolean
  case bool(Bool)
  
  /// Represents a JSON integer
  case int(Int)
  
  /// Represents a JSON unsigned integer
  case uint(UInt)
  
  /// Represents a JSON string
  case string(String)
  
  /// Represents an array of JSON representables
  case array([JSON])
  
  /// Represents a JSON object keyed by strings
  case dictionary([String: JSON])
  
  /// Tries to get a boolean value from the current JSON
  var bool: Bool? {
    if case let .bool(bool) = self {
      return bool
    }
    
    return nil
  }
  
  /// Tries to get an 8 bit integer from the current JSON
  var int8: Int8? {
    if case let .int(int) = self {
      return Int8(exactly: int)
    }
    
    return nil
  }
  
  /// Tries to get a 16 bit integer from the current JSON
  var int16: Int16? {
    if case let .int(int) = self {
      return Int16(exactly: int)
    }
    
    return nil
  }
  
  /// Tries to get a 32 bit integer from the current JSON
  var int32: Int32? {
    if case let .int(int) = self {
      return Int32(exactly: int)
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
  
  /// Tries to get an 8 bit unsigned integer from the current JSON
  var uint8: UInt8? {
    if case let .int(int) = self {
      return UInt8(exactly: int)
    }
    
    if case let .uint(int) = self {
      return UInt8(exactly: int)
    }
    
    return nil
  }
  
  /// Tries to get a 16 bit unsigned integer from the current JSON
  var uint16: UInt16? {
    if case let .int(int) = self {
      return UInt16(exactly: int)
    }
    
    if case let .uint(int) = self {
      return UInt16(exactly: int)
    }
    
    return nil
  }
  
  /// Tries to get a 32 bit unsigned integer from the current JSON
  var uint32: UInt32? {
    if case let .int(int) = self {
      return UInt32(exactly: int)
    }
    
    if case let .uint(int) = self {
      return UInt32(exactly: int)
    }
    
    return nil
  }
  
  /// Tries to get an unsigned integer value from the current JSON
  var uint: UInt? {
    if case let .uint(int) = self {
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

extension JSON: Encodable {
  /// Encode to JSON
  ///
  /// - parameter encoder: JSONEncoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    
    switch self {
    case let .bool(bool):
      try container.encode(bool)
      
    case let .int(int):
      try container.encode(int)
      
    case let .uint(int):
      try container.encode(int)
      
    case let .string(string):
      try container.encode(string)
      
    case let .array(array):
      try container.encode(array)
      
    case let .dictionary(dict):
      try container.encode(dict)
    }
  }
}

extension JSON: Decodable {
  /// Decode from JSON
  ///
  /// - parameter decoder: JSONDecoder
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
      return
    }
    
    if let int = try? container.decode(Int.self) {
      self = .int(int)
      return
    }
    
    if let int = try? container.decode(UInt.self) {
      self = .uint(int)
      return
    }
    
    if let string = try? container.decode(String.self) {
      self = .string(string)
      return
    }
    
    if let array = try? container.decode([JSON].self) {
      self = .array(array)
      return
    }
    
    if let dict = try? container.decode([String: JSON].self) {
      self = .dictionary(dict)
      return
    }
    
    throw Sword.Error("Unable to decode JSON")
  }
}
