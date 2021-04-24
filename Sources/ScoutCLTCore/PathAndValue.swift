//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout

/// Represents a reading path and an associated value, like `path.component[0]=value`.
///
/// ### Forcing a type
/// The `value` property can be forced to be a string or a double when the automatic type inferring will return another type.
/// For instance with "123", the value will be treated as an `Int`, so specifying `string` rather than `automatic` prevents that.
///
public struct PathAndValue {

    // MARK: - Properties

    public let readingPath: Path
    public let value: ValueType

    public init?(string: String) {
        guard
            let result = Self.parser.run(string),
            result.remainder.isEmpty
        else { return nil }

        readingPath = Path(elements: result.result.pathElements)
        value = result.result.value
    }
}

public indirect enum ValueType: Equatable {
    case string(String)
    case real(String)
    case keyName(String)
    case automatic(String)
    case dictionary([String: ValueType])
}

extension ValueType: ExplorerValueRepresentable {

    public func explorerValue() throws -> ExplorerValue {
        switch self {
        case .string(let string):
            return .string(string)

        case .real(let real):
            guard let double = Double(real) else {
                throw CLTCoreError.valueConversion(value: real, type: "Double")
            }
            return .double(double)

        case .automatic(let string):
            return .init(fromSingle: string)

        case .keyName:
            throw CLTCoreError.wrongUsage("A keyName value cannot be used here")

        case .dictionary(let dict):
            return try .dictionary(dict.mapValues { try $0.explorerValue() })
        }
    }
}
