//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum SerializationError: LocalizedError {

    case dataToString
    case stringToData

    public var errorDescription: String? {
        switch self {
        case .dataToString: return "The data value cannot be represented as a String"
        case .stringToData: return "The string value cannot be represented as Data"
        }
    }
}
