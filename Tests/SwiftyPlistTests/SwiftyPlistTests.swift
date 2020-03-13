import XCTest
@testable import SwiftyPlist

final class SwiftyPlistTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftyPlist().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
