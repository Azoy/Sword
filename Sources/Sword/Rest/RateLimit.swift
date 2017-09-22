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
extension Sword {

  /**
   Gets the "route" for an HTTP request

   - parameter url: URL to get route from
  */
  func getRoute(for url: String) -> String {

    let regex = try! NSRegularExpression(
      pattern: "/([a-z-]+)/(?:[0-9]{17,})+?",
      options: .caseInsensitive
    )

    let string = NSString(string: url)
    let matches = regex.matches(
      in: url,
      options: [],
      range: NSMakeRange(0, string.length)
    )

    guard matches.count > 0 else {
      return url
    }

    var route = ""

    for match in matches {
      let miniRoute = string.substring(with: match.range)
      var parameters = miniRoute.components(separatedBy: "/")

      parameters.remove(at: 0)

      let parameterId = parameters[1]
      parameters[1] = ":id"

      if (parameters[0] == "channels" || parameters[0] == "guilds")
        && route.isEmpty {
        parameters[1] = parameterId
      }

      route += "/" + parameters.joined(separator: "/")
    }

    return route
  }

  /// Used to un clog the global queue full of requests that woudld've resulted in 429 because of global rate limit
  func globalUnlock() {
    self.isGloballyLocked = false
    for request in self.globalRequestQueue {
      request()
    }
  }

  /**
   Handles creating buckets, and making sure the bucket is up to date with the headers

   - parameter headers: The received headers from the request
  */
  func handleRateLimitHeaders(
    _ limitHeader: Any?,
    _ intervalHeader: Any?,
    _ date: Double,
    _ route: String
  ) {
    guard let limitHeader = limitHeader,
      let intervalHeader = intervalHeader else {
      return
    }

    let limit = Int(limitHeader as! String)!
    let interval = Int(intervalHeader as! String)! - Int(date)

    if self.rateLimits[route] == nil {
      let bucket = Bucket(
        name: "me.azoy.sword.rest.\(route)",
        limit: limit,
        interval: interval
      )
      bucket.take(1)

      self.rateLimits[route] = bucket
    }
  }

}
