//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class ExplorerValueEncoderTests: XCTestCase {

    func testEncode_SimpleStruct() throws {
        struct Toto: Codable {
            var string: String
            var int: Int
            var double: Double
            var bool: Bool
        }

        let toto = Toto(string: "toto", int: 1, double: 2.5, bool: true)
        let encoder = ExplorerValueEncoder()
        try toto.encode(to: encoder)

        XCTAssertEqual(encoder.value, ["string": "toto", "int": 1, "double": 2.5, "bool": true])
    }

    func testEncode_StructWithEnum() throws {
        struct Toto: Codable {
            enum State: String, Codable {
                case active, canceled
            }
            var state: State
        }

        let toto = Toto(state: .canceled)
        let encoder = ExplorerValueEncoder()
        try toto.encode(to: encoder)

        XCTAssertEqual(encoder.value, ["state": "canceled"])
    }

    func testEncode_Array() throws {
        struct Toto: Codable {
            var name: String
        }

        let array: [Toto] = [Toto(name: "Riri"), Toto(name: "Fifi"), Toto(name: "Loulou")]
        let encoder = ExplorerValueEncoder()
        try array.encode(to: encoder)

        XCTAssertEqual(encoder.value, [["name": "Riri"], ["name": "Fifi"], ["name": "Loulou"]])
    }

    func testEncode_Nested() throws {
        struct Nested: Codable {
            var name: String
        }

        struct Toto: Codable {
            var nested: Nested
        }

        let toto = Toto(nested: Nested(name: "toto"))
        let encoder = ExplorerValueEncoder()
        try toto.encode(to: encoder)

        XCTAssertEqual(encoder.value, ["nested": ["name": "toto"]])
    }

    func testEncode_Data() throws {
        struct Toto: Codable, Equatable {
            var data: Data
        }
        let data = "here".data(using: .utf8)!

        let toto = Toto(data: data)
        let encoder = ExplorerValueEncoder()
        try toto.encode(to: encoder)

        XCTAssertEqual(encoder.value, ["data": .data(data)])
    }

    func testEncode_Nil() throws {
        struct Toto: Codable, Equatable {
            var string: String?
        }

        let toto = Toto(string: nil)
        let encoder = ExplorerValueEncoder()
        try toto.encode(to: encoder)

        XCTAssertEqual(encoder.value, [:])
    }
}
