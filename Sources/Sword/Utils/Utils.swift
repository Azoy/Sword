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

  /// Computed property to get date from string
  var date: Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

    if let returnDate = dateFormat.date(from: self) {
      return returnDate
    }else {
      dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

      return dateFormat.date(from: self)!
    }
  }

  /// Computed property to get date from string (specifically the Date header from requests)
  var httpDate: Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "E, dd MMM yyyy HH:mm:ss zzzz"

    return dateFormat.date(from: self)!
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
