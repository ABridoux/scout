//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout
import ScoutCLTCore

final class ExportCommandTests: XCTestCase {

    func testExportCSV() throws {
        var command = StubCommand()
        command.csv = true

        XCTAssertEqual(try command.export(), .csv(separator: nil))
    }

    func testExportCSVSeparator() throws {
        var command = StubCommand()
        command.csvSeparator = "/"

        XCTAssertEqual(try command.export(), .csv(separator: "/"))
    }

    func testExportDataFormat() throws {
        var command = StubCommand()
        command.exportFormat = .plist

        XCTAssertEqual(try command.export(), .dataFormat(format: .plist))
    }

    func testExportCSVAndDataFormatThrows() throws {
        var command = StubCommand()
        command.csv = true
        command.exportFormat = .plist

        XCTAssertThrowsError(try command.export())
    }
}

extension ExportCommandTests {

    struct StubCommand: ExportCommand {
        var csv = false
        var csvSeparator: String?
        var exportFormat: DataFormat?
    }
}
