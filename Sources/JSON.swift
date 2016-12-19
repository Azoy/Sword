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

protocol JSONable {
  func encode() -> String
}

extension Dictionary: JSONable {}
extension Array: JSONable {}

extension JSONable {
  func encode() -> String {
    let data = try? JSONSerialization.data(withJSONObject: self, options: [])
    return String(data: data!, encoding: .utf8)!
  }
}
