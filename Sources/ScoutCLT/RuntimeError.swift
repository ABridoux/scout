import Foundation

enum RuntimeError: LocalizedError {
    case invalidData(String)
    case noValueAt(path: String)
    case unknownFormat(String)

    var errorDescription: String? {
        switch self {
        case .invalidData(let description): return description
        case .noValueAt(let path): return "No single value at '\(path)'. Either Dictionary or Array to subscript."
        case .unknownFormat(let description): return description
        }
    }
}
