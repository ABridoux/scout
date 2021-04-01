//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension XCTestCase {

    func XCTAssertErrorsEqual<T>(_ expression: @autoclosure () throws -> T,
                               _ expectedError: PathExplorerError,
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsError(
        _ = try expression(), "", file: file, line: line) { error in
             guard
                let resultPathExplorerError = error as? PathExplorerError,
                resultPathExplorerError == expectedError
            else {
                XCTFail("The expression did not throw the error \(expectedError). Error thrown: \(error)", file: file, line: line)
                return
            }
        }
    }

    func XCTAssertErrorsEqual<T>(_ expression: @autoclosure () throws -> T,
                               _ expectedError: ValueTypeError,
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsError(
        _ = try expression(), "", file: file, line: line) { error in
             guard
                let resultPathExplorerError = error as? ValueTypeError,
                resultPathExplorerError == expectedError
            else {
                XCTFail("The expression did not throw the error \(expectedError). Error thrown: \(error)", file: file, line: line)
                return
            }
        }
    }

    func XCTAssertExplorersEqual<P: EquatablePathExplorer>(
        _ p1: @autoclosure () throws -> P,
        _ p2: @autoclosure () throws -> P,
        file: StaticString = #file, line: UInt = #line) rethrows {
        let p1 = try p1()
        let p2 = try p2()

        XCTAssertTrue(p1.isEqual(to: p2), "\(p1) not equal to \(p2)", file: file, line: line)
    }
}
