//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

extension ExplorerValue: CustomStringConvertible {

    public var description: String {
        switch self {
        case .int(let int): return int.description
        case .double(let double): return double.description
        case .string(let string): return string
        case .bool(let bool): return bool.description
        case .data(let data): return data.base64EncodedString()
        case .date(let date): return date.description
        case .array(let array):
            let elements = array.map(\.description).joined(separator: ",")
            return "[\(elements)]"
        case .dictionary(let dict):
            let elements = dict.map { "\($0.key): \($0.value)" }.joined(separator: ",")
            return "[\(elements)]"
        }
    }
}

extension ExplorerValue: CustomDebugStringConvertible {

    public var debugDescription: String { description }
}
