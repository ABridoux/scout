//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout

final class SerializationFormatTests: XCTestCase {

    func testJsonThrowsSingleValue() throws {
        XCTAssertThrowsError(try SerializationFormats.Json.serialize(value: 2))
    }
}
