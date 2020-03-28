import XCTest
@testable import Scout

final class KeyTypeTests: XCTestCase {

    func testInitBoolFromString1() throws {
        XCTAssertEqual(try Bool(value: "t"), true)
    }

    func testInitBoolFromString2() throws {
        XCTAssertEqual(try Bool(value: "NO"), false)
    }

    func testInitIntFromString() throws {
        XCTAssertEqual(try Int(value: "150"), 150)
    }

    func testInitDoubleFromString() throws {
        XCTAssertEqual(try Double(value: "150.5"), 150.5)
    }
}
