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
            let result = Self.parser.run(string)
        else { return nil }

        if let error = result.result.value.firstError {
            print("An error occurred while parsing the argument '\(string)'")
            print(error)
            return nil
        }

        guard result.remainder.isEmpty else {
            return nil
        }

        readingPath = Path(elements: result.result.pathElements)
        value = result.result.value
    }
}
