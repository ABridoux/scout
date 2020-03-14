import Foundation

enum PathExplorerError: LocalizedError {
    case invalidData(SerializationFormat.Type)
    case stringToDataConversionError
    case stringToIntConversionError(String)
    case underlyingError(String)

    var description: String {
        switch self {
        case .invalidData(let type): return "Cannot intialize a \(String(describing: type)) object with the given data"
        case .stringToDataConversionError: return "Unable to convert the input string into data"
        case .stringToIntConversionError(let string): return "Unable to convert \(string) to int"
        case .underlyingError(let description): return description
        }
    }
}
