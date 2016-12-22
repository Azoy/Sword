import Foundation

class Request {

  let token: String

  let session = URLSession.shared
  let sema = DispatchSemaphore(value: 0)

  var rateLimits: [String: [String: Bucket]] = [:]

  init(_ token: String) {
    self.token = token
  }

  func getRoute(for url: String) -> String {
    let regex = try! NSRegularExpression(pattern: "/([a-z-]+)/(?:[0-9]{17,})+?", options: .caseInsensitive)

    let string = url as NSString
    guard let result = regex.firstMatch(in: url, options: [], range: NSMakeRange(0, string.length)) else {
      return ""
    }

    let matches = (1..<result.numberOfRanges).map {
      string.substring(with: result.rangeAt($0))
    }

    return matches.first!
  }

  func request(_ url: String, body: Data? = nil, authorization: Bool = false, method: String = "GET", rateLimited: Bool = true, completion: @escaping (Error?, Any?) -> Void) {
    let route = self.getRoute(for: url)

    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = method

    if authorization {
      request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
    }

    request.addValue("DiscordBot (https://github.com/Azoy/Sword, 0.1.0)", forHTTPHeaderField: "User-Agent")

    if method == "POST" {
      request.httpBody = body!
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    let task = session.dataTask(with: request) { data, response, error in
      let response = response as! HTTPURLResponse
      let headers = response.allHeaderFields

      if error != nil {
        completion(.unknown, nil)
        self.sema.signal()
        return
      }

      if response.statusCode == 204 {
        completion(nil, nil)
        self.sema.signal()
        return
      }

      if response.statusCode != 200 && response.statusCode != 201 {

        if response.statusCode == 429 {
          print(headers)
        }

        self.sema.signal()
        return
      }

      if rateLimited && self.rateLimits[route]?[method] == nil {
        let limit = headers["X-Rate-Limit"] as! Int
        let interval = Int((headers["X-RateLimit-Reset"] as! Double) - Date().timeIntervalSince1970)
        print(limit)
        print(interval)
        let bucket = Bucket(name: "gg.azoy.sword.\(route).\(method)", limit: limit, interval: interval)
        bucket.take(1)
        self.rateLimits[route] = [method: bucket]
      }

      do {
        let returnedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        completion(nil, returnedData)
      }catch {
        completion(.unknown, nil)
      }

      self.sema.signal()
    }

    if rateLimited && self.rateLimits[route]?[method] != nil {
      let item = DispatchWorkItem {
        task.resume()
      }
      self.rateLimits[route]![method]!.queue(item)
    }else {
      task.resume()
    }

    sema.wait()

  }

}
