//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public enum SerializationError: LocalizedError {

    case dataToString
    case stringToData
    case notCSVExportable(description: String)

    public var errorDescription: String? {
        switch self {
        case .dataToString: return "The data value cannot be represented as a String"
        case .stringToData: return "The string value cannot be represented as Data"
        case .notCSVExportable(let description): return "The value is not properly exportable to CSV. \(description)"
        }
    }
}
