//
//  Request.swift
//  Sword
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Dispatch

/// HTTP Handler
extension Sword {

  // MARK: Functions

  /**
   Actual HTTP Request

   - parameter url: URL to request
   - parameter body: Optional Data to send to server
   - parameter file: Optional for when files
   - parameter reason: Optional for when user wants to specify audit-log reason
   - parameter authorization: Whether or not the Authorization header is required by Discord
   - parameter method: Type of HTTP Method
   - parameter rateLimited: Whether or not the HTTP request needs to be rate limited
  */
  func request(_ endpoint: Endpoint, body: [String: Any]? = nil, reason: String? = nil, file: String? = nil, authorization: Bool = true, rateLimited: Bool = true, then completion: @escaping (Any?, RequestError?) -> ()) {
    let sema = DispatchSemaphore(value: 0) //Provide a way to urlsession from command line

    let endpointInfo = endpoint.httpInfo

    let route = self.getRoute(for: endpointInfo.url)

    let realUrl = "https://discordapp.com/api/v7\(endpointInfo.url)"

    var request = URLRequest(url: URL(string: realUrl)!)
    request.httpMethod = endpointInfo.method.rawValue.uppercased()

    if authorization {
      request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
    }
    
    if reason != nil {
      request.addValue(reason!, forHTTPHeaderField: "X-Audit-Log-Reason")
    }

    request.addValue("DiscordBot (https://github.com/Azoy/Sword, 0.5.0)", forHTTPHeaderField: "User-Agent")

    if body != nil {
      request.httpBody = body!.createBody()

      if body!["array"] != nil {
        request.httpBody = (body!["array"] as! [Any]).createBody()
      }

      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    #if os(macOS)
    if file != nil {
      let boundary = createBoundary()
      var payloadJson = body?.encode()

      if body?["array"] != nil {
        payloadJson = (body?["array"] as? [Any])?.encode()
      }

      request.httpBody = try? self.createMultipartBody(with: payloadJson, fileUrl: file!, boundary: boundary)
      request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    }
    #endif

    let task = self.session.dataTask(with: request) { [unowned self, sema] data, response, error in
      let response = response as! HTTPURLResponse
      let headers = response.allHeaderFields

      if error != nil {
        completion(nil, .unknown)
        sema.signal()
        return
      }

      if response.statusCode == 204 {
        completion(nil, nil)
        sema.signal()
        return
      }

      if response.statusCode != 200 && response.statusCode != 201 {

        if response.statusCode == 429 {
          print("[Sword] You're being rate limited. (This shouldn't happen, check your system clock)")

          let retryAfter = Int(headers["retry-after"] as! String)!
          let global = headers["x-ratelimit-global"] as? Bool

          guard global == nil else {
            self.isGloballyLocked = true
            self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(retryAfter)) { [unowned self] in
              self.globalUnlock()
            }

            sema.signal()
            return
          }

          self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(retryAfter)) {
            self.request(endpoint, body: body, file: file, authorization: authorization, rateLimited: rateLimited, then: completion)
          }
        }

        if response.statusCode >= 500 {
          self.globalQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            self.request(endpoint, body: body, file: file, authorization: authorization, rateLimited: rateLimited, then: completion)
          }

          sema.signal()
          return
        }

        completion(nil, response.status)
        sema.signal()
        return
      }

      if rateLimited {
        self.handleRateLimitHeaders(headers["x-ratelimit-limit"], headers["x-ratelimit-remaining"], headers["x-ratelimit-reset"], (headers["Date"] as! String).dateNorm.timeIntervalSince1970, route)
      }

      do {
        let returnedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        completion(returnedData, nil)
      }catch {
        completion(nil, .unknown)
      }

      sema.signal()
    }

    let apiCall = { [unowned self, sema] in
      guard rateLimited, self.rateLimits[route] != nil else {
        task.resume()

        sema.wait()
        return
      }

      let item = DispatchWorkItem {
        task.resume()

        sema.wait()
      }

      self.rateLimits[route]!.queue(item)
    }

    if !self.isGloballyLocked {
      apiCall()
    }else {
      self.globalRequestQueue.append(apiCall)
    }

  }

}
