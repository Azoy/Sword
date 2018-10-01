//
//  JSON.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2018 Alejandro Alonso. All rights reserved.
//

import Foundation

protocol _SwordChild {
  var sword: Sword? { get set }
}

/// Used to grab data from message received from gateway
func decode<T: Codable>(
  _ type: T.Type,
  from data: Data
) -> T? {
  do {
    let payload = try Sword.decoder.decode(PayloadData<T>.self, from: data)
    
    Sword.decoder.dateDecodingStrategy = .deferredToDate
    
    if var data = payload.d as? _SwordChild {
      data.sword = Sword.decoder.userInfo[Sword.decodingInfo] as? Sword
      return data as? T
    }
    
    // This is somewhat of a hack because Channel can't conform to _SwordChild
    if var data = payload.d as? Channel {
      data.sword = Sword.decoder.userInfo[Sword.decodingInfo] as? Sword
      return data as? T
    }
    
    return payload.d
  } catch {
    print(error)
    return nil
  }
}

// Used to decode iso8601 timestamps
extension DateFormatter {
  static var isoFormatter: ISO8601DateFormatter {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return fmt
  }
  
  static var isoFormatter2: ISO8601DateFormatter {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [.withInternetDateTime]
    return fmt
  }
}

func decodeISO8601(_ decoder: Decoder) throws -> Date {
  let container = try decoder.singleValueContainer()
  let dateString = try container.decode(String.self)
  
  // This doesn't look great, but you'd still have to append/remove fractionalSeconds
  guard let date = DateFormatter.isoFormatter.date(from: dateString) else {
    guard let date = DateFormatter.isoFormatter2.date(from: dateString) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "ISO8601 format is incorrect"
      )
    }
    
    return date
  }
  
  return date
}
