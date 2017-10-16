//
//  JSON.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// JSON BBY
extension String {

  /// EZPZ String JSON -> Array | Dictionary | Other
  func decode() -> Any {
    let data = try? JSONSerialization.jsonObject(
      with: self.data(using: .utf8)!,
      options: .allowFragments
    )

    if let dictionary = data as? [String: Any] {
      return dictionary
    }

    if let array = data as? [Any] {
      return array
    }

    return data!
  }

}

/// Used to add same function to two different types once
protocol JSONEncodable {
  func encode() -> String
  func createBody() -> Data?
}

/// Make Dictionary & Array Encaodable
extension Dictionary: JSONEncodable {}
extension Array: JSONEncodable {}

/// Make Dictionary & Array conform to Encodable
extension JSONEncodable {

  /// Encode Array | Dictionary -> JSON String
  func encode() -> String {
    let data = try? JSONSerialization.data(withJSONObject: self, options: [])
    return String(data: data!, encoding: .utf8)!
  }

  /// Create Data from Array | Dictionary to send over HTTP
  func createBody() -> Data? {
    let json = self.encode()
    return json.data(using: .utf8)
  }
}
