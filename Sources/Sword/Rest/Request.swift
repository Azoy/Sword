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
   - parameter params: Optional URL Query Parameters to send
   - parameter body: Optional Data to send to server
   - parameter file: Optional for when files
   - parameter authorization: Whether or not the Authorization header is required by Discord
   - parameter method: Type of HTTP Method
   - parameter rateLimited: Whether or not the HTTP request needs to be rate limited
   - parameter reason: Optional for when user wants to specify audit-log reason
  */
  func request(
    _ endpoint: Endpoint,
    params: [String: Any]? = nil,
    body: [String: Any]? = nil,
    file: String? = nil,
    authorization: Bool = true,
    rateLimited: Bool = true,
    reason: String? = nil,
    then completion: @escaping (Any?, RequestError?) -> ()
  ) {
    let sema = DispatchSemaphore(value: 0)

    let endpointInfo = endpoint.httpInfo

    var route = self.getRoute(for: endpointInfo.url)

    if route.hasSuffix("/messages/:id") && endpointInfo.method == .delete {
      route += ".delete"
    }

    var urlString = "https://discordapp.com/api/v7\(endpointInfo.url)"

    if let params = params {
      urlString += "?"
      urlString += params.map(
        { key, value in "\(key)=\(value)" }
      ).joined(separator: "&")
    }

    guard let url = URL(string: urlString) else {
      self.error(
        "[Sword] Used an invalid URL: \"\(urlString)\". Please report this."
      )
      return
    }
    
    var request = URLRequest(url: url)

    request.httpMethod = endpointInfo.method.rawValue

    if authorization {
      if self.options.isBot {
        request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
      }else {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
    }

    if let reason = reason {
      request.addValue(
        reason.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!,
        forHTTPHeaderField: "X-Audit-Log-Reason"
      )
    }

    request.addValue(
      "DiscordBot (https://github.com/Azoy/Sword, 0.9.0)",
      forHTTPHeaderField: "User-Agent"
    )

    if let body = body {
      if let array = body["array"] as? [Any] {
        request.httpBody = array.createBody()
      }else {
        request.httpBody = body.createBody()
      }

      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    #if os(macOS)
    if let file = file {
      let boundary = createBoundary()
      
      let payloadJson: String?

      if let array = body?["array"] as? [Any] {
        payloadJson = array.encode()
      }else {
        payloadJson = body?.encode()
      }

      request.httpBody = try? self.createMultipartBody(
        with: payloadJson,
        fileUrl: file, boundary: boundary
      )
      request.addValue(
        "multipart/form-data; boundary=\(boundary)",
        forHTTPHeaderField: "Content-Type"
      )
    }
    #endif

    let task = self.session.dataTask(with: request) {
      [unowned self, unowned sema] data, response, error in
      
      let response = response as! HTTPURLResponse
      let headers = response.allHeaderFields

      if error != nil {
        #if !os(Linux)
        completion(nil, RequestError(error! as NSError))
        #else
        completion(nil, RequestError(error as! NSError))
        #endif
        sema.signal()
        return
      }

      if rateLimited {
        self.handleRateLimitHeaders(
          headers["x-ratelimit-limit"],
          headers["x-ratelimit-reset"],
          (headers["Date"] as! String).httpDate.timeIntervalSince1970,
          route
        )
      }

      if response.statusCode == 204 {
        completion(nil, nil)
        sema.signal()
        return
      }
      
      let returnedData = try? JSONSerialization.jsonObject(
        with: data!,
        options: .allowFragments
      )
      
      if response.statusCode != 200 && response.statusCode != 201 {

        if response.statusCode == 429 {
          print(
            "[Sword] You're being rate limited. (This shouldn't happen, check your system clock)"
          )

          let retryAfter = Int(headers["retry-after"] as! String)!
          let global = headers["x-ratelimit-global"] as? Bool

          guard global == nil else {
            self.isGloballyLocked = true
            self.globalQueue.asyncAfter(
              deadline: DispatchTime.now() + .seconds(retryAfter)
            ) { [unowned self] in
              self.globalUnlock()
            }

            sema.signal()
            return
          }

          self.globalQueue.asyncAfter(
            deadline: DispatchTime.now() + .seconds(retryAfter)
          ) { [unowned self] in
            self.request(
              endpoint,
              body: body,
              file: file,
              authorization: authorization,
              rateLimited: rateLimited,
              then: completion
            )
          }
        }

        if response.statusCode >= 500 {
          self.globalQueue.asyncAfter(
            deadline: DispatchTime.now() + .seconds(3)
          ) { [unowned self] in
            self.request(
              endpoint,
              body: body,
              file: file,
              authorization: authorization,
              rateLimited: rateLimited,
              then: completion
            )
          }

          sema.signal()
          return
        }

        completion(nil, RequestError(response.statusCode, returnedData!))
        sema.signal()
        return
      }

      completion(returnedData, nil)
      
      sema.signal()
    }

    let apiCall = { [unowned self] in
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
