//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class ExplorerValueDecoderTests: XCTestCase {

    func testDecode_SimpleStruct() throws {
        struct Toto: Codable, Equatable {
            var string: String
            var int: Int
            var double: Double
            var bool: Bool
        }

        let value: ExplorerValue = ["string": "toto", "int": 1, "double": 2.3, "bool": false]
        let toto = try Toto(from: ExplorerValueDecoder(value))

        let expected = Toto(string: "toto", int: 1, double: 2.3, bool: false)
        XCTAssertEqual(toto, expected)
    }

    func testDecode_WithEnum() throws {
        struct Toto: Codable, Equatable {
            enum State: String, Codable {
                case active, canceled
            }
            var state: State
        }

        let value: ExplorerValue = ["state": "active"]
        let toto = try Toto(from: ExplorerValueDecoder(value))

        let expected = Toto(state: .active)
        XCTAssertEqual(toto, expected)
    }

    func testDecode_InArray() throws {
        struct Toto: Codable, Equatable {
            var name: String
        }

        let value: ExplorerValue = [["name": "Riri"], ["name": "Fifi"], ["name": "Loulou"]]
        let toto = try [Toto](from: ExplorerValueDecoder(value))

        let expected = [Toto(name: "Riri"), Toto(name: "Fifi"), Toto(name: "Loulou")]
        XCTAssertEqual(toto, expected)
    }

    func testDecode_Nested() throws {
        struct Nested: Codable, Equatable {
            var name: String
        }

        struct Toto: Codable, Equatable {
            var nested: Nested
        }

        let value: ExplorerValue = ["nested": ["name": "Riri"]]
        let toto = try Toto(from: ExplorerValueDecoder(value))

        let expected = Toto(nested: Nested(name: "Riri"))
        XCTAssertEqual(toto, expected)
    }

    func testDecode_Data() throws {
        struct Toto: Codable, Equatable {
            var data: Data
        }

        let value: ExplorerValue = ["data": .data("here".data(using: .utf8)!)]
        let toto = try Toto(from: ExplorerValueDecoder(value))

        let expected = Toto(data: "here".data(using: .utf8)!)
        XCTAssertEqual(String(data: toto.data, encoding: .utf8), String(data: expected.data, encoding: .utf8))
    }

    func testDecode_Nil() throws {
        struct Toto: Codable, Equatable {
            var string: String?
        }

        let value: ExplorerValue = [:]
        let toto = try Toto(from: ExplorerValueDecoder(value))

        let expected = Toto(string: nil)
        XCTAssertEqual(toto, expected)
    }
}
