//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class String_JaroWinklerTests: XCTestCase {

    let target = "verson"
    let propositions: Set<String> = ["tag", "date", "name", "owner", "release", "version", "forest", "mouse", "versionning"]

    func testMartha() {
        let distance = "MARTHA".jaroWinklerDistance(from: "MARHTA")

        XCTAssertEqual(distance, 0.961, accuracy: 0.3)
    }

    func testDWAYNE() {
        let distance = "DWAYNE".jaroWinklerDistance(from: "DUANE")

        XCTAssertEqual(distance, 0.84, accuracy: 0.3)
    }

    func testDIXON() {
        let distance = "DIXON".jaroWinklerDistance(from: "DICKSONX")

        XCTAssertEqual(distance, 0.813, accuracy: 0.3)
    }

    func testBestMatch() {
        let result = target.bestJaroWinklerMatchIn(propositions: propositions)
        XCTAssertEqual(result, "version")
    }
}
