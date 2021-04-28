//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout
import ScoutCLTCore

final class ExportCommandTests: XCTestCase {

    func testExportCSVSeparator() throws {
        var command = StubCommand()
        command.csvSeparator = "/"

        XCTAssertEqual(try command.exportOption(), .csv(separator: "/"))
    }

    func testExportDataFormat() throws {
        var command = StubCommand()
        command.exportFormat = .plist

        XCTAssertEqual(try command.exportOption(), .dataFormat(format: .plist))
    }

    func testExportCSVAndDataFormatThrows() throws {
        var command = StubCommand()
        command.csvSeparator = ";"
        command.exportFormat = .plist

        XCTAssertThrowsError(try command.exportOption())
    }
}

extension ExportCommandTests {

    struct StubCommand: ExportCommand {
        var csvSeparator: String?
        var exportFormat: ExportFormat?
    }
}
