//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest

final class JSONFormatSerializationTests: XCTestCase {

    func testMeasureAllowFragment() throws {
        let jsonData = try Data(contentsOf: .peopleJson)

        measure {
            _ = try! Json(data: jsonData)
        }
    }
}
