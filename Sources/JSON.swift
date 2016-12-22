import Foundation

extension String {

  func decode() -> Any {
    let data = try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: .allowFragments)

    if let dictionary = data as? [String: Any] {
      return dictionary
    }

    if let array = data as? [Any] {
      return array
    }

    return data!
  }

}

protocol Encodable {
  func encode() -> String
  func createBody() -> Data?
}

extension Dictionary: Encodable {}
extension Array: Encodable {}

extension Encodable {
  func encode() -> String {
    let data = try? JSONSerialization.data(withJSONObject: self, options: [])
    return String(data: data!, encoding: .utf8)!
  }

  func createBody() -> Data? {
    let json = self.encode()
    return json.data(using: .utf8)
  }
}
