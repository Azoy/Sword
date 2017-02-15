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
   (Had to make two has HTTPURLResponse has different headers types for macOS and Linux atm, this is fixed in swift 3.1)

   - parameter headers: The received headers from the request
  */
  #if !os(Linux)
  func handle(rateLimitHeaders headers: [AnyHashable: Any], with route: String) {
    let limitHeader = headers["x-ratelimit-limit"]
    let remainingHeader = headers["x-ratelimit-remaining"]
    let intervalHeader = headers["x-ratelimit-reset"]

    if limitHeader != nil && remainingHeader != nil && intervalHeader != nil {
      let limit = Int(limitHeader as! String)!
      let remaining = Int(remainingHeader as! String)!
      let interval = Int(Double(intervalHeader as! String)! - (headers["Date"] as! String).dateNorm.timeIntervalSince1970)

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
      }
    }else {
      if route != "" && self.rateLimits[route] == nil {
        let bucket = Bucket(name: "gg.azoy.sword.\(route)", limit: 1, interval: 2)
        bucket.take(1)

        self.rateLimits[route] = bucket
      }
    }
  }
  #else
  func handle(rateLimitHeaders headers: [AnyHashable: String], with route: String) {
    let limitHeader = headers["X-RateLimit-Limit"]
    let remainingHeader = headers["X-RateLimit-Remaining"]
    let intervalHeader = headers["X-RateLimit-Reset"]

    if limitHeader != nil && remainingHeader != nil && intervalHeader != nil {
      let limit = Int(limitHeader!)!
      let remaining = Int(remainingHeader!)!
      let interval = Int(Double(intervalHeader!)! - (headers["Date"]!).dateNorm.timeIntervalSince1970)

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
      }
    }else {
      if route != "" && self.rateLimits[route] == nil {
        let bucket = Bucket(name: "gg.azoy.sword.\(route)", limit: 1, interval: 2)
        bucket.take(1)

        self.rateLimits[route] = bucket
      }
    }
  }
  #endif

  /**
   Handles being 429'd
   (Had to make two has HTTPURLResponse has different headers types for macOS and Linux atm, this is fixed in swift 3.1)

   - parameter headers: The received headers from the request
   - parameter sema: The dispatch semaphore to signal
  */
  #if !os(Linux)
  func handleRateLimited(with headers: [AnyHashable: Any], and sema: DispatchSemaphore) {
    let retryAfter = Int(headers["retry-after"] as! String)!
    let global = headers["x-ratelimit-global"]

    guard global == nil else {
      self.globallyLocked = true
      self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(retryAfter)) {
        self.globalUnlock()
      }

      sema.signal()
      return
    }
  }
  #else
  func handleRateLimited(with headers: [AnyHashable: String]) {
    let retryAfter = Int(headers["Retry-After"]!)!
    let global = headers["X-RateLimit-Global"]

    guard global == nil else {
      self.globallyLocked = true
      self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(retryAfter)) {
        self.globalUnlock()
      }

      sema.signal()
      return
    }
  }
  #endif

}
