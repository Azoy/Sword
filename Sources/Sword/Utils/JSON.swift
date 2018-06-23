//
//  JSON.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

/// Used in situations where the type is not known when decoding JSON
@dynamicMemberLookup
public enum JSON {
  /// Represents a JSON null
  case null
  
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
    
    if case let .string(string) = self {
      return Int8(string)
    }
    
    return nil
  }
  
  /// Tries to get a 16 bit integer from the current JSON
  var int16: Int16? {
    if case let .int(int) = self {
      return Int16(exactly: int)
    }
    
    if case let .string(string) = self {
      return Int16(string)
    }
    
    return nil
  }
  
  /// Tries to get a 32 bit integer from the current JSON
  var int32: Int32? {
    if case let .int(int) = self {
      return Int32(exactly: int)
    }
    
    if case let .string(string) = self {
      return Int32(string)
    }
    
    return nil
  }
  
  /// Tries to get a 64 bit integer from the current JSON
  var int64: Int64? {
    if case let .int(int) = self {
      return Int64(exactly: int)
    }
    
    if case let .string(string) = self {
      return Int64(string)
    }
    
    return nil
  }
  
  /// Tries to get an integer value from the current JSON
  var int: Int? {
    if case let .int(int) = self {
      return int
    }
    
    if case let .string(string) = self {
      return Int(string)
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
    
    if case let .string(string) = self {
      return UInt8(string)
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
    
    if case let .string(string) = self {
      return UInt16(string)
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
    
    if case let .string(string) = self {
      return UInt32(string)
    }
    
    return nil
  }
  
  /// Tries to get a 64 bit unsigned integer from the current JSON
  var uint64: UInt64? {
    if case let .int(int) = self {
      return UInt64(exactly: int)
    }
    
    if case let .uint(int) = self {
      return UInt64(exactly: int)
    }
    
    if case let .string(string) = self {
      return UInt64(string)
    }
    
    return nil
  }
  
  /// Tries to get an unsigned integer value from the current JSON
  var uint: UInt? {
    if case let .int(int) = self {
      return UInt(exactly: int)
    }
    
    if case let .uint(int) = self {
      return int
    }
    
    if case let .string(string) = self {
      return UInt(string)
    }
    
    return nil
  }
  
  /// Tries to get a snowflake value from the current JSON
  var snowflake: Snowflake? {
    return Snowflake(self)
  }
  
  /// Tries to get a string value from the current JSON
  var string: String? {
    if case let .string(string) = self {
      return string
    }
    
    return nil
  }
  
  /// Tries to get an array value from the current JSON
  var array: [JSON]? {
    if case let .array(array) = self {
      return array
    }
    
    return nil
  }
  
  /// Tries to get a dictionary value from the current JSON
  var dict: JSON? {
    if case .dictionary(_) = self {
      return self
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
  subscript(dynamicMember member: String) -> JSON? {
    if case let .dictionary(dict) = self {
      return dict[member]
    }
    
    return nil
  }
  
  /// Tries to form an enum member from current JSON
  func raw<T: RawRepresentable>(_ type: T.Type) -> T? {
    let value: Any
    
    switch type.RawValue.self {
    case is Bool.Type:
      guard let bool = bool else {
        return nil
      }
      
      value = bool
      
    case is Int8.Type:
      guard let int8 = int8 else {
        return nil
      }
      
      value = int8
      
    case is Int16.Type:
      guard let int16 = int16 else {
        return nil
      }
      
      value = int16
      
    case is Int32.Type:
      guard let int32 = int32 else {
        return nil
      }
      
      value = int32
      
    case is Int64.Type:
      guard let int64 = int64 else {
        return nil
      }
      
      value = int64
      
    case is Int.Type:
      guard let int = int else {
        return nil
      }
      
      value = int
      
    case is UInt8.Type:
      guard let uint8 = uint8 else {
        return nil
      }
      
      value = uint8
      
    case is UInt16.Type:
      guard let uint16 = uint16 else {
        return nil
      }
      
      value = uint16
      
    case is UInt32.Type:
      guard let uint32 = uint32 else {
        return nil
      }
      
      value = uint32
      
    case is UInt64.Type:
      guard let uint64 = uint64 else {
        return nil
      }
      
      value = uint64
      
    case is UInt.Type:
      guard let uint = uint else {
        return nil
      }
      
      value = uint
      
    case is String.Type:
      guard let string = string else {
        return nil
      }
      
      value = string
      
    default:
      return nil
    }
    
    return T.init(rawValue: value as! T.RawValue)
  }
}

extension JSON: Encodable {
  /// Encode to JSON
  ///
  /// - parameter encoder: JSONEncoder
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    
    switch self {
    case .null:
      try container.encodeNil()
      
    case let .bool(bool):
      try container.encode(bool)
      
    case let .int(int):
      try container.encode(int)
      
    case let .uint(uint):
      try container.encode(uint)
      
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
    
    if container.decodeNil() {
      self = .null
      return
    }
    
    if let bool = try? container.decode(Bool.self) {
      self = .bool(bool)
      return
    }
    
    if let int = try? container.decode(Int.self) {
      self = .int(int)
      return
    }
    
    if let uint = try? container.decode(UInt.self) {
      self = .uint(uint)
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
