//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum PathExplorerError: LocalizedError, Equatable {

    case invalidData(serializationFormat: String)
    case invalidValue(String)
    case valueConversionError(value: String, type: String)
    case wrongValueForKey(value: String, element: PathElement)
    case wrongGroupValueForKey(group: String, value: String, element: PathElement)
    case wrongUsage(of: PathElement, in: Path)

    case dictionarySubscript(Path)
    case subscriptMissingKey(path: Path, key: String, bestMatch: String?)
    case arraySubscript(Path)
    case subscriptWrongIndex(path: Path, index: Int, arrayCount: Int)
    case keyNameSetOnNonDictionary(path: Path)
    case wrongBounds(Bounds, in: Path, lastValidIndex: Int)
    case wrongRegularExpression(pattern: String, in: Path)

    case stringToDataConversionError
    case dataToStringConversionError
    case invalidPathElement(PathElement)

    case underlyingError(String)
    case groupSampleConversionError(Path)
    case csvExportWrongGroupValue
    case csvExportAmbiguous(expected: String, path: Path)

    public var errorDescription: String? {
        switch self {
        case .invalidData(let type): return "Cannot intialize a \(String(describing: type)) object with the given data"
        case .invalidValue(let value): return "The key value \(value) is invalid"
        case .valueConversionError(let value, let type): return "Unable to convert the value `\(value)` to the type \(type)"
        case .wrongValueForKey(let value, let element): return "Cannot set `\(value)` to key/index #\(element)# which is a Dictionary or an Array"
        case .wrongGroupValueForKey(let group, let value, let element): return "Cannot set `\(value)` to array #\(element)# which is \(group)"
        case .wrongUsage(let element, let path): return "Wrong usage of \(element.description) in '\(path.description)'. \(element.usage)"

        case .dictionarySubscript(let path): return "Cannot subscript the key at '\(path.description)' with a String as it is not a Dictionary"
        case .subscriptMissingKey(let path, let key, let bestMatch):
            let bestMatchString: String

            if let match = bestMatch {
                bestMatchString = "Best match found: #\(match)#"
            } else {
                bestMatchString = "No best match found"
            }

            return "The key #\(key)# cannot be found in the Dictionary '\(path.description)'.\n\(bestMatchString)"

        case .arraySubscript(let path): return "Cannot subscript the key at '\(path.description)' with an Integer as is not an Array"
        case .subscriptWrongIndex(let path, let index, let count): return "The index [\(index)] is not within the bounds (0...\(count - 1)) of the Array  at '\(path.description)'"
        case .keyNameSetOnNonDictionary(path: let path): return "'\(path.description)' is not a dictionary and cannot set the key name of its children if any"

        case .wrongBounds(let bounds, let path, let lastValidIndex): return
            """
            Wrong slice '[\(bounds.lowerString):\(bounds.upperString)]' in '\(path.description)' Last index : \(lastValidIndex).
            Valid slice: 0 <= lowerBound <= upperBound <= lastIndex. Negative bounds are substracted to the last index (-bound -> lastIndex - bound).
            Omit lower to target first index. Omit upper to target last index
            """

        case .wrongRegularExpression(let pattern, let path): return "Wrong regular expression pattern '\(pattern.description)' in '\(path.description)'."

        case .stringToDataConversionError: return "Unable to convert the input string into data"
        case .dataToStringConversionError: return "Unable to convert the data to a string"
        case .invalidPathElement(let element): return "Invalid path element: '\(element)'"

        case .underlyingError(let description): return description
        case .groupSampleConversionError(let path): return "Internal error. Group sample conversion error in '\(path.description)'"
        case .csvExportWrongGroupValue: return "CSV export requires either first object to be an array or a dictionary of arrays"
        case .csvExportAmbiguous(let expectedType, let path): return "Ambiguous type for value at '\(path.description). Expected \(expectedType) as the first value is of type \(expectedType)"
        }
    }
}
