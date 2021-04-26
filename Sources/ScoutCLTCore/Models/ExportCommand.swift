//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Scout

public enum Export: Equatable {
    case noExport
    case csv(separator: String)
    case dataFormat(format: DataFormat)
    case array
    case dictionary
}

public protocol ExportCommand {
    var csvSeparator: String? { get }
    var exportFormat: ExportFormat? { get }
}

public extension ExportCommand {

    func exportOption() throws -> Export {
        switch (csvSeparator, exportFormat) {
        case (let separator?, nil): return .csv(separator: separator)
        case (nil, let format?):
            switch format {
            case .array: return .array
            case .dict: return .dictionary
            case .json: return .dataFormat(format: .json)
            case .plist: return .dataFormat(format: .plist)
            case .yaml: return .dataFormat(format: .yaml)
            case .xml: return .dataFormat(format: .xml)
            }
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
