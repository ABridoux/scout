import Foundation

public enum PathExplorerError: LocalizedError, Equatable {

    case invalidData(serializationFormat: String)
    case invalidValue(String)
    case valueConversionError(value: String, type: String)
    case wrongValueForKey(value: String, element: PathElement)
    case arrayCountWrongUsage(path: Path)

    case dictionarySubscript(Path)
    case subscriptMissingKey(path: Path, key: String, bestMatch: String?)
    case arraySubscript(Path)
    case subscriptWrongIndex(path: Path, index: Int, arrayCount: Int)

    case stringToDataConversionError
    case dataToStringConversionError
    case invalidPathElement(PathElement)

    case underlyingError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidData(let type): return "Cannot intialize a \(String(describing: type)) object with the given data"
        case .invalidValue(let value): return "The key value \(value) is invalid"
        case .valueConversionError(let value, let type): return "Unable to convert the value `\(value)` to the type \(type)"
        case .wrongValueForKey(let value, let element): return "Cannot set `\(value)` to key/index #\(element)# which is a Dictionary or an Array"
        case .arrayCountWrongUsage(let path): return "Wrong usage of array count in '\(path.description)'. Array count should be the last path element after an array."

        case .dictionarySubscript(let path): return "Cannot subscript the key at '\(path.description)' with a String as it is not a Dictionary"
        case .subscriptMissingKey(let path, let key, let bestMatch):
            let bestMatchString: String

            if let match = bestMatch {
                bestMatchString = "Best match found: #\(match)#"
            } else {
                bestMatchString = "No best match found"
            }

            return "The key #\(key)# cannot be found in the Dictionary '\(path.description)'. \(bestMatchString)"

        case .arraySubscript(let path): return "Cannot subscript the key at '\(path.description)' with an Integer as is not an Array"
        case .subscriptWrongIndex(let path, let index, let arrayCount): return "The index #\(index)# is not within the bounds of the Array (0...\(arrayCount - 1)) at '\(path.description)'"

        case .stringToDataConversionError: return "Unable to convert the input string into data"
        case .dataToStringConversionError: return "Unable to convert the data to a string"
        case .invalidPathElement(let element): return "Invalid path element: '\(element)'"

        case .underlyingError(let description): return description
        }
    }
}
