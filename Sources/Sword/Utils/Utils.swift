//
//  Utils.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Date {

  /// Computed variable to get milliseconds since 1970
  var milliseconds: Int {
    return Int((self.timeIntervalSince1970 * 1000.0).rounded())
  }

}

extension String {
  
  // Cached date formatters so we don't have to keep making new ones
  
  private static let dateFormatLong: DateFormatter = {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US")
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    return dateFormat
  }()
  
  private static let dateFormatShort: DateFormatter = {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US")
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormat
  }()
  
  private static let dateFormatHTTP: DateFormatter = {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US")
    dateFormat.dateFormat = "E, dd MMM yyyy HH:mm:ss zzzz"
    return dateFormat
  }()
  
  /// Computed property to get date from string
  var date: Date {
    if let returnDate = String.dateFormatLong.date(from: self) {
      return returnDate
    }else {
      return String.dateFormatShort.date(from: self)!
    }
  }

  /// Computed property to get date from string (specifically the Date header from requests)
  var httpDate: Date {
    return String.dateFormatHTTP.date(from: self)!
  }

}

extension Data {

  /// Function to append data
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }

}
