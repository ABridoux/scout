//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Scout

/// Type serving only the purpose to map dictionaries or arrays
/// returned by a `PathExplorer` to a `String` value.
public struct GroupExportValue: ExplorerValueCreatable {

    public let value: String

    /// - throws: if the value is not single.
    public init(from explorerValue: ExplorerValue) throws {
        switch explorerValue {
        case .string(let string): value = string
        case .int(let int): value = int.description
        case .double(let double): value = double.description
        case .bool(let bool): value = bool.description
        case .data(let data): value = data.base64EncodedString()
        case .date(let date): value = date.description
        case .dictionary: throw CLTCoreError.wrongUsage("Trying to export a dictionary of values that are not single")
        case .array: throw CLTCoreError.wrongUsage("Trying to export an array of values that are not single")
        }
    }
}
