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
func decode<T: Decodable>(
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
    
    return payload.d
  } catch {
    Sword.log(.error, error.localizedDescription)
    return nil
  }
}

// Used to decode iso8601 timestamps
extension DateFormatter {
  static let isoFormatterLong: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US")
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    return df
  }()
  
  static let isoFormatterShort: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US")
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return df
  }()
  
  static let http: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US")
    df.dateFormat = "E, dd MMM yyyy HH:mm:ss zzzz"
    return df
  }()
}

func decodeISO8601(_ decoder: Decoder) throws -> Date {
  let container = try decoder.singleValueContainer()
  let dateString = try container.decode(String.self)
  
  if let date = DateFormatter.isoFormatterLong.date(from: dateString) {
    return date
  }
  
  if let date = DateFormatter.isoFormatterShort.date(from: dateString) {
    return date
  }
  
  throw DecodingError.dataCorruptedError(
    in: container,
    debugDescription: "ISO8601 format is incorrect"
  )
}

extension String {
  var httpDate: Date? {
    return DateFormatter.http.date(from: self)
  }
}
