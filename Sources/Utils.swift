import Foundation

extension Date {

  //Computed variable to get milliseconds since 1970
  var milliseconds: Int {
    return Int((self.timeIntervalSince1970 * 1000.0).rounded())
  }

}

extension String {

  //Computed property to get date from string
  var date: Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

    return dateFormat.date(from: self)!
  }

  //Computed property to get date from string (specifically the Date header from requests)
  var dateNorm: Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "E, d MMM yyyy HH:mm:ss Z"

    return dateFormat.date(from: self)!
  }

}

extension Data {

  //Function to append data
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      append(data)
    }
  }

}
