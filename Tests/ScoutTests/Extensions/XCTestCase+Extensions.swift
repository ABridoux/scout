import XCTest
import Scout

extension XCTestCase {

    func XCTAssertErrorsEqual<T>(_ expression: @autoclosure () throws -> T,
                               _ expectedError: PathExplorerError,
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsError(
        _ = try expression(), "") { error in
             guard
                let resultPathExplorerError = error as? PathExplorerError,
                resultPathExplorerError == expectedError
            else {
                XCTFail("The expression did not throw the error \(expectedError)", file: file, line: line)
                return
            }
        }
    }
}
