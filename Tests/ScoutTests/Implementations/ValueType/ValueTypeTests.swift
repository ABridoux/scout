//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class ValueTypeTests: XCTestCase {

    typealias ValueTypeJson = ValueType<CodableFormats.Json>

    func testDecodeDictionary() throws {
        let dict: [String: Any] = ["firstKey": 2, "secondKey": false]
        let data = try JSONSerialization.data(withJSONObject: dict)

        let value = try JSONDecoder().decode(ValueTypeJson.self, from: data)

        XCTAssertEqual(value, .dictionary(["firstKey": 2, "secondKey": false]))
    }

    func testDecodeArray() throws {
        let array: [Any] = [2, false]
        let data = try JSONSerialization.data(withJSONObject: array)

        let value = try JSONDecoder().decode(ValueTypeJson.self, from: data)

        XCTAssertEqual(value, .array([2, false]))
    }

    func testEncodeDictionary() throws {
        let dict = ValueTypeJson.dictionary(["firstKey": "Endo",  "secondKey": 23])

        let data = try JSONEncoder().encode(dict)

        let serializedDict = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let string = try XCTUnwrap(serializedDict["firstKey"] as? String)
        XCTAssertEqual(string, "Endo")
        let double = try XCTUnwrap(serializedDict["secondKey"] as? Double)
        XCTAssertEqual(double, 23)
    }

    func testEncodeArray() throws {
        let array = ValueTypeJson.array(["Endo", 23])

        let data = try JSONEncoder().encode(array)

        let serializedArray = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [Any])
        let string = try XCTUnwrap(serializedArray[0] as? String)
        XCTAssertEqual(string, "Endo")
        let double = try XCTUnwrap(serializedArray[1] as? Double)
        XCTAssertEqual(double, 23)
    }

    func testDecodeNestedDictionary() throws {
        let dict: [String: Any] = ["firstKey": 2, "secondKey": [false]]
        let data = try JSONSerialization.data(withJSONObject: dict)

        let value = try JSONDecoder().decode(ValueTypeJson.self, from: data)

        XCTAssertEqual(value, .dictionary(["firstKey": 2, "secondKey": .array([false])]))
    }

    func testDecodeNestedArray() throws {
        let array: [Any] = [2, [false]]
        let data = try JSONSerialization.data(withJSONObject: array)

        let value = try JSONDecoder().decode(ValueTypeJson.self, from: data)

        XCTAssertEqual(value,
                       .array(
                        [2, .array([false])]
                       )
        )
    }
}
