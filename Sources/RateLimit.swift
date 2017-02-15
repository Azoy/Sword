//
//  RateLimit.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// Rate Limit
extension Request {

  /**
   Gets the "route" for an HTTP request

   - parameter url: URL to get route from
  */
  func getRoute(for url: String) -> String {

    #if !os(Linux)
    let regex = try! NSRegularExpression(pattern: "/([a-z-]+)/(?:[0-9]{17,})+?", options: .caseInsensitive)
    #else
    let regex = try! RegularExpression(pattern: "/([a-z-]+)/(?:[0-9]{17,})+?", options: .caseInsensitive)
    #endif

    let string = NSString(string: url)
    let matches = regex.matches(in: url, options: [], range: NSMakeRange(0, string.length))
    var returnRoute = ""

    for match in matches {
      var parameters = string.substring(with: match.range).components(separatedBy: "/")
      if parameters[1] == "channels" || parameters[1] == "guilds" {
        returnRoute += parameters.joined(separator: "/")

        continue
      }
      parameters.remove(at: 2)

      returnRoute += parameters.joined(separator: "/")
    }

    let parameters = url.components(separatedBy: "/")
    if parameters.count % 2 == 0 {
      returnRoute += "/" + parameters[parameters.count - 1]
    }

    return returnRoute
  }

  /// Used to un clog the global queue full of requests that woudld've resulted in 429 because of global rate limit
  func globalUnlock() {
    self.globallyLocked = false
    for request in self.globalLockQueue {
      request()
    }
  }

  /**
   Handles creating buckets, and making sure the bucket is up to date with the headers

   - parameter headers: The received headers from the request
  */
  func handleRateLimitHeaders(_ limitHeader: Any?, _ remainingHeader: Any?, _ intervalHeader: Any?, _ date: Double, _ route: String) {
    var limit = 1
    var remaining = 0
    var interval = 2

    if limitHeader != nil && remainingHeader != nil && intervalHeader != nil {
      #if !os(Linux)
      limit = Int(limitHeader as! String)!
      remaining = Int(remainingHeader as! String)!
      interval = Int(Double(intervalHeader as! String)! - date)
      #else
      limit = Int(limitHeader!)!
      remaining = Int(remainingHeader!)!
      interval = Int(Double(intervalHeader!)! - date)
      #endif
    }

    if route != "" && self.rateLimits[route] == nil {
      let bucket = Bucket(name: "gg.azoy.sword.\(route)", limit: limit, interval: interval)
      bucket.take(1)

      self.rateLimits[route] = bucket
    }else {
      if self.rateLimits[route]!.tokens != remaining {
        self.rateLimits[route]!.tokens = remaining
      }
      if self.rateLimits[route]!.limit != limit {
        self.rateLimits[route]!.limit = limit
      }
      if self.rateLimits[route]!.interval != interval {
        self.rateLimits[route]!.interval = interval
      }
    }
  }

  /**
   Handles being 429'd

   - parameter headers: The received headers from the request
   - parameter sema: The dispatch semaphore to signal
  */
  func handleRateLimited(_ retryAfter: Int, _ global: Any?, _ sema: DispatchSemaphore) {
    guard global == nil else {
      self.globallyLocked = true
      self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(retryAfter)) {
        self.globalUnlock()
      }

      sema.signal()
      return
    }
  }

}
