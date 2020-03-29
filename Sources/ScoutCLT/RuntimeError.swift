import Foundation

enum RuntimeError: LocalizedError {
    case invalidData(String)
    case noValueAt(path: String)
    case unknownFormat(String)

    var errorDescription: String? {
        switch self {
        case .invalidData(let description): return description
        case .noValueAt(let path): return "No value at '\(path)'"
        case .unknownFormat(let description): return description
        }
    }
}
