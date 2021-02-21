//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout

public enum Export: Equatable {
    case csv(separator: String?)
    case dataFormat(format: Scout.DataFormat)
}

public protocol ExportCommand {

    var csv: Bool { get }
    var csvSeparator: String? { get }
    var exportFormat: DataFormat? { get }
}

public extension ExportCommand {

    func export() throws -> Export? {
        let csv = self.csv || (csvSeparator != nil)

        switch (csv, exportFormat) {
        case (true, nil): return .csv(separator: csvSeparator)
        case (false, .some(let format)): return .dataFormat(format: format)
        case (false, nil): return nil
        case (true, .some): throw CLTCoreError.exportConflict
        }
    }

    /// Get the file name of the file path
    func fileName(of filePath: String?) -> String? {
        guard let filePath = filePath else { return nil }
        return URL(fileURLWithPath: filePath).lastPathComponentWithoutExtension
    }
}
