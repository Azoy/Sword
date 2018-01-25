import XCTest
@testable import Sword

class SwordTests: XCTestCase {
  func testExample() {
    XCTAssertEqual(Sword().text, "Hello, World!")
  }
  
  
  static var allTests = [
    ("testExample", testExample),
    ]
}
