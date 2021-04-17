//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValue {

    // MARK: PathExplorer

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
        _ = try _delete(path: Slice(path), deleteIfEmpty: deleteIfEmpty)
    }

    public func deleting(_ path: Path, deleteIfEmpty: Bool) throws -> ExplorerValue {
        var copy = self
        try copy.delete(path, deleteIfEmpty: deleteIfEmpty)
        return copy
    }

    // MARK: General function

    /// Returns `true` if the end of the path is reached
    private mutating func _delete(path: SlicePath, deleteIfEmpty: Bool) throws -> Bool {
        guard let (head, tail) = path.cutHead() else { return true }

        try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): try delete(key: key, tail: tail, deleteIfEmpty: deleteIfEmpty)
            case .index(let index): try delete(index: index, tail: tail, deleteIfEmpty: deleteIfEmpty)
            case .filter(let pattern): try deleteFilter(with: pattern, tail: tail, deleteIfEmpty: deleteIfEmpty)
            case .slice(let bounds): try deleteSlice(within: bounds, tail: tail, deleteIfEmpty: deleteIfEmpty)
            default:
                throw ExplorerError.wrongUsage(of: head)
            }
        }

        return false
    }

    // MARK: PathElement

    private mutating func delete(key: String, tail: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .dictionary(var dict):
            var value = try dict.getJaroWinkler(key: key)
            let shouldDelete = try value._delete(path: tail, deleteIfEmpty: deleteIfEmpty)

            if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                dict.removeValue(forKey: key)
            } else {
                dict[key] = value
            }

            self = .dictionary(dict)

        default:
            throw ExplorerError.subscriptKeyNoDict
        }
    }

    private mutating func delete(index: Int, tail: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .array(var array):
            let index = try computeIndex(from: index, arrayCount: array.count)
            var value = array[index]
            let shouldDelete = try value._delete(path: tail, deleteIfEmpty: deleteIfEmpty)

            if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                array.remove(at: index)
            } else {
                array[index] = value
            }
            self = .array(array)

        default:
            throw ExplorerError.subscriptIndexNoArray
        }
    }

    private mutating func deleteFilter(with pattern: String, tail: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .dictionary(let dict):
            let regex = try NSRegularExpression(with: pattern)

            let modified = try dict.compactMap { (key, value) -> (String, ExplorerValue)? in
                guard regex.validate(key) else { return (key, value) }
                var value = value
                let shouldDelete = try value._delete(path: tail, deleteIfEmpty: deleteIfEmpty)

                if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                    return nil
                } else {
                    return (key, value)
                }
            }

            self = .dictionary(Dictionary(uniqueKeysWithValues: modified))

        default:
            throw ExplorerError.wrongUsage(of: .filter(pattern))
        }
    }

    private mutating func deleteSlice(within bounds: Bounds, tail: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .array(var array):
            let range = try bounds.range(arrayCount: array.count)
            let newRangeElements = try array[range].compactMap { (element) -> ExplorerValue? in
                var element = element
                let shouldDelete = try element._delete(path: tail, deleteIfEmpty: deleteIfEmpty)

                if shouldDelete || (element.isEmpty && deleteIfEmpty) {
                    return nil
                } else {
                    return element
                }
            }
            array.replaceSubrange(range, with: newRangeElements)
            self = .array(array)

        default:
            throw ExplorerError.wrongUsage(of: .slice(bounds))
        }
    }
}
