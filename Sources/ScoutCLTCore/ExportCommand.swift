//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Scout

public enum Export: Equatable {
    case noExport
    case csv(separator: String)
    case dataFormat(format: Scout.DataFormat)
}

public protocol ExportCommand {
    var csvSeparator: String? { get }
    var exportFormat: DataFormat? { get }
}

public extension ExportCommand {

    func exportOption() throws -> Export {
        switch (csvSeparator, exportFormat) {
        case (let separator?, nil): return .csv(separator: separator)
        case (nil, let format?): return .dataFormat(format: format)
        case (nil, nil): return .noExport
        case (.some, .some): throw CLTCoreError.exportConflict
        }
    }

    /// Get the file name of the file path
    func fileName(of filePath: String?) -> String? {
        guard let filePath = filePath else { return nil }
        return URL(fileURLWithPath: filePath).lastPathComponentWithoutExtension
    }
}
