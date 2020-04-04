//
//  RateLimit.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2019 Alejandro Alonso. All rights reserved.
//

import Foundation

extension Sword {
  /// Handles what to do when a request is complete (rate limiting)
  ///
  /// - parameter response: The http response from the Discord
  func handleRateLimit(_ response: HTTPURLResponse, _ route: String) {
    /*
    let headers = response.allHeaderFields
    let _limit = headers["x-ratelimit-limit"] as? Int
    let _remaining = headers["x-ratelimit-remaining"] as? Int
    let _reset = headers["x-ratelimit-reset"] as? Int
    let _date = headers["date"] as? String
    
    guard let limit = _limit,
          let remaining = _remaining,
          let reset = _reset,
          let date = _date else {
      Sword.log(.error, "monkaS")
      return
    }
    
    guard let bucket = buckets[route] else {
      buckets[route] = Bucket(name: "sword.bucket.\(route)", limit: limit, interval: <#T##Int#>)
    }
    */
  }
  /*
  func haltRequests() {
    for bucket in buckets.values {
      bucket.worker.suspend()
    }
  }
  */
}

