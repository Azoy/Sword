import XCTest
@testable import Sword

class SwordTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Sword().text, "Hello, World!")
    }


    static var allTests : [(String, (SwordTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
