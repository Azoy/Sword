import Foundation

extension Date {

  var milliseconds: Int {
    return Int((self.timeIntervalSince1970 * 1000.0).rounded())
  }

}

extension String {

  var date: Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"

    return dateFormat.date(from: self)!
  }

}
