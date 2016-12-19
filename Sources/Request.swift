import Foundation

struct Request {

  let token: String

  let session = URLSession.shared
  let sema = DispatchSemaphore(value: 0)

  init(_ token: String) {
    self.token = token
  }

  func request(_ url: String, with headers: [String: String] = [:], with method: String = "GET", completion: @escaping (Error?, Any?) -> Void) {

    var request = URLRequest(url: URL(string: url)!)
    request.httpMethod = method

    for (header, value) in headers {
      request.addValue(value, forHTTPHeaderField: header)
    }

    let task = session.dataTask(with: request) { data, response, error in
      let response = response as! HTTPURLResponse

      if error != nil {
        completion(.unknown, nil)
        self.sema.signal()
        return
      }

      if response.statusCode != 200 && response.statusCode != 201 {
        completion(response.status, nil)
        self.sema.signal()
        return
      }

      do {
        let returnedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        completion(nil, returnedData as Any?)
      }catch {
        completion(.unknown, nil)
      }

      self.sema.signal()
    }

    task.resume()

    sema.wait()

  }

}
