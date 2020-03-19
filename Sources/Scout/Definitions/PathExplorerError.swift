import Foundation

enum PathExplorerError: LocalizedError {
    case invalidData(SerializationFormat.Type)
    case invalidValue(Any)
    case valueConversionError(value: Any, type: String)
    case wrongValueForKey(value: Any, element: PathElement)

    case dictionarySubscript(Any)
    case subscriptMissingKey(String)
    case arraySubscript(Any)
    case subscriptWrongIndex(index: Int, arrayCount: Int)

    case stringToDataConversionError
    case dataToStringConversionError
    case invalidPathElement(PathElement)

    case underlyingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidData(let type): return "Cannot intialize a \(String(describing: type)) object with the given data"
        case .invalidValue(let value): return "The key value \(value) is invalid"
        case .valueConversionError(let value, let type): return "Unable to convert the value \(value) to \(type)"
        case .wrongValueForKey(let value, let element): return "Cannot set `\(value)` to key/index #\(element)# which is a Dictionary or an Array"

        case .dictionarySubscript(let key): return "The key #\(key)# is not a Dictionary"
        case .subscriptMissingKey(let key): return "The key #\(key)# cannot be found in the Dictionary"
        case .arraySubscript(let key): return "The key #\(key)# is not an Array"
        case .subscriptWrongIndex(let index, let arrayCount): return "The index \(index) is not within the bounds of the Array: 0...\(arrayCount - 1)"

        case .stringToDataConversionError: return "Unable to convert the input string into data"
        case .dataToStringConversionError: return "Unable to convert the data to a string"
        case .invalidPathElement(let element): return "Invalid path element: \(element)"

        case .underlyingError(let description): return description
        }
    }
}
