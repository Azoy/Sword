import Foundation

class Request {

  let token: String

  let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())

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

    let matches = (0..<result.numberOfRanges).map {
      string.substring(with: result.rangeAt($0))
    }

    return matches.first!
  }

  func request(_ url: String, body: Data? = nil, authorization: Bool = false, method: String = "GET", rateLimited: Bool = true, completion: @escaping (Error?, Any?) -> ()) {
    let sema = DispatchSemaphore(value: 0)

    let route = rateLimited ? self.getRoute(for: url) : ""

    let realUrl = "https://discordapp.com/api\(url)"

    var request = URLRequest(url: URL(string: realUrl)!)
    request.httpMethod = method

    if authorization {
      request.addValue("Bot \(token)", forHTTPHeaderField: "Authorization")
    }

    request.addValue("DiscordBot (https://github.com/Azoy/Sword, 0.1.0)", forHTTPHeaderField: "User-Agent")

    if method == "POST" {
      request.httpBody = body
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    let task = self.session.dataTask(with: request) { data, response, error in
      let response = response as! HTTPURLResponse
      let headers = response.allHeaderFields

      if error != nil {
        completion(.unknown, nil)
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
          print(self.rateLimits[route]![method]!.queue)
        }

        sema.signal()
        return
      }

      if rateLimited && self.rateLimits[route]?[method] == nil {
        let limit = Int(headers["x-ratelimit-limit"] as! String)!
        let interval = Int(Double(headers["x-ratelimit-reset"] as! String)! - Date().timeIntervalSince1970)
        let bucket = Bucket(name: "gg.azoy.sword.\(route).\(method)", limit: limit, interval: interval)
        bucket.take(1)

        if self.rateLimits[route] == nil {
          self.rateLimits[route] = [method: bucket]
        }else {
          self.rateLimits[route]![method] = bucket
        }
      }

      do {
        let returnedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        completion(nil, returnedData)
      }catch {
        completion(.unknown, nil)
      }

      sema.signal()
    }

    if rateLimited && self.rateLimits[route] != nil && self.rateLimits[route]?[method] != nil {
      let item = DispatchWorkItem {
        task.resume()

        sema.wait()
      }
      self.rateLimits[route]![method]!.queue(item)
    }else {
      task.resume()

      sema.wait()
    }

  }

}
