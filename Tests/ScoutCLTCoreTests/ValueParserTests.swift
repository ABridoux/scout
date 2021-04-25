//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

@testable import ScoutCLTCore
import XCTest
import Parsing

final class ValueParserTest: XCTestCase {

    // MARK: - Single

    func testReal() {
        test(
            parser: PathAndValue.ValueParsers.real,
            on: "~25~",
            expected: .real("25")
        )
    }

    func testKeyName() {
        test(
            parser: PathAndValue.ValueParsers.keyName,
            on: "#Toto#",
            expected: .keyName("Toto")
        )
    }

    func testString() {
        test(
            parser: PathAndValue.ValueParsers.string,
            on: "/123/",
            expected: .string("123")
        )
    }

    func testAutomatic() {
        test(
            parser: PathAndValue.ValueParsers.automatic,
            on: "123",
            expected: .automatic("123")
        )
    }

    // MARK: - Dictionary

    func testDictionaryElement_Automatic() {
        let result = PathAndValue.ValueParsers.dictionaryElement.run("Endo: dog")?.result

        XCTAssertEqual(result?.key, "Endo")
        XCTAssertEqual(result?.value, .automatic("dog"))
    }

    func testDictionaryElement_Automatic_StringKey() {
        let result = PathAndValue.ValueParsers.dictionaryElement.run(" 'Endo:' : dog")?.result

        XCTAssertEqual(result?.key, "Endo:")
        XCTAssertEqual(result?.value, .automatic("dog"))
    }

    func testDictionary_Automatic() {
        test(
            parser: PathAndValue.ValueParsers.dictionary,
            on: "[Endo: dog]",
            expected: .dictionary(["Endo": .automatic("dog")])
        )
    }

    func testDictionaryElement_String() {
        let result = PathAndValue.ValueParsers.dictionaryElement.run("Endo: '123'")?.result

        XCTAssertEqual(result?.key, "Endo")
        XCTAssertEqual(result?.value, .string("123"))
    }

    func testDictionary_String() {
        test(
            parser: PathAndValue.ValueParsers.dictionary,
            on: "[Endo: '123']",
            expected: ["Endo": .string("123")]
        )
    }

    func testDictionary_Heterogeneous_Flat() {
        test(
            parser: PathAndValue.ValueParsers.dictionary,
            on: "[Endo: dog, Socrate: 'cat', Riri: 123]",
            expected:
                ["Endo": .automatic("dog"),
                 "Socrate": .string("cat"),
                 "Riri": .automatic("123")]
        )
    }

    func testDictionary_Heterogeneous_Nested() {
        test(
            parser: PathAndValue.ValueParsers.dictionary,
            on: "[ducks: [Riri: foolish, Fifi: brave, Loulou: visionary]]",
            expected:
                ["ducks":
                    ["Riri": .automatic("foolish"), "Fifi": .automatic("brave"), "Loulou": .automatic("visionary")]
                ]
        )
    }

    func testDictionary_ThrowsIfDuplicateKeys() {
        test(
            parser: PathAndValue.ValueParsers.dictionary,
            on: "[ducks: [Riri: foolish, Riri: brave, Loulou: visionary]]",
            expected: ["ducks": .error("Duplicate key 'Riri' in the dictionary [Riri: foolish, Riri: brave, Loulou: visionary]")]
        )
    }

    func testDictionary_Empty() {
        test(
            parser: PathAndValue.ValueParsers.parser,
            on: "[:]",
            expected: [:]
        )
    }

    // MARK: - Array

    func testArray_Automatic() {
        test(
            parser: PathAndValue.ValueParsers.array,
            on: "[123, 456, 789]",
            expected: [.automatic("123"), .automatic("456"), .automatic("789")]
        )
    }

    func testArray_Heterogeneous() {
        test(
            parser: PathAndValue.ValueParsers.array,
            on: "[123, '456', ~789~]",
            expected: [.automatic("123"), .string("456"), .real("789")]
        )
    }

    func testArray_Heterogeneous_Nested() {
        test(
            parser: PathAndValue.ValueParsers.array,
            on: "[123, [456, 789]]",
            expected: [.automatic("123"), [.automatic("456"), .automatic("789")]]
        )
    }

    func testArray_Empty() {
        test(
            parser: PathAndValue.ValueParsers.parser,
            on: "[]",
            expected: []
        )
    }

    // MARK: - Mixing nested

    func testMixing1() {
        test(
            parser: PathAndValue.ValueParsers.parser,
            on: "[[name: Endo, age: 11], [name: Socrate, age: 23]]",
            expected: [
                ["name": .automatic("Endo"), "age": .automatic("11")],
                ["name": .automatic("Socrate"), "age": .automatic("23")]
            ]
        )
    }

    func testMixing2() {
        test(
            parser: PathAndValue.ValueParsers.parser,
            on: "[Riri: [123, 456], Fifi: [789], Loulou: ~23~]",
            expected: [
                "Riri": [.automatic("123"), .automatic("456")],
                "Fifi": [.automatic("789")],
                "Loulou": .real("23")
            ]
        )
    }
}

extension ValueParserTest {

    func test(
        parser: Parser<ValueType>,
        on string: String,
        expected: ValueType,
        file: StaticString = #file,
        line: UInt = #line) {
        let result = parser.run(string)

        XCTAssertEqual(result?.0, expected, file: file, line: line)
    }
}
