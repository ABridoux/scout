//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ValueType {

    public func get(_ path: Path) throws -> Self {
        try get(path: Slice(path))
    }

    public func get(_ path: PathElement...) throws -> Self {
        try get(path: Slice(path))
    }

    private func get(path: Slice<Path>) throws -> Self {
        guard let firstElement = path.first else { return self }
        let remainder = path.dropFirst()
        let next: ValueType

        switch firstElement {
        case .key(let key): next = try get(key: key)
        case .index(let index): next = try get(index: index)
        case .count: next = try getCount()
        case .keysList: next = try getKeysList()
        case .slice(let bounds): next = try getSlice(for: bounds)
        case .filter(let pattern): next = try getFilter(with: pattern)
        }

        do {
            return try next.get(path: remainder)
        } catch var valueError as ValueTypeError {
            valueError.path.append(firstElement)
            throw valueError
        } catch {
            throw error
        }
    }

    // MARK: - Helpers

    private func get(key: String) throws -> Self {
        switch self {
        case .dictionary(let dict):
            return try dict[key]
                .unwrapOrThrow(.missing(key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys))))

        case .filter(let dict):
            let newDict = try dict.map { try ("\($0.key)_\(key)", $0.value.get(key: key)) }
            return .filter(Dictionary(uniqueKeysWithValues: newDict))

        default:
            throw ValueTypeError.subscriptKeyNoDict
        }
    }

    private func get(index: Int) throws -> Self {

        switch self {
        case .array(let array):
            let index = try computeIndex(from: index, arrayCount: array.count)
            return array[index]

        case .slice(let array):
            let slice = try array.reduce([Self]()) { try $0 + [$1.get(index: index)] }
            return .slice(slice)


        default:
            throw ValueTypeError.subscriptIndexNoArray
        }
    }

    private func getCount() throws -> Self {
        switch self {
        case .array(let array), .slice(let array): return .count(array.count)
        case .dictionary(let dict), .filter(let dict): return .count(dict.count)
        default:
            throw ValueTypeError.wrongUsage(of: .count)
        }
    }

    private func getKeysList() throws -> Self {
        switch self {
        case .dictionary(let dict), .filter(let dict):
            return .keysList(dict.map(\.key).sorted())

        default:
            throw ValueTypeError.wrongUsage(of: .keysList)
        }
    }

    private func getSlice(for bounds: Bounds) throws -> Self {
        switch self {
        case .array(let array):
            let range = try bounds.range(arrayCount: array.count)
            return .slice(Array(array[range]))

        case .slice(let array):
            return try .slice(array.map { try $0.getSlice(for: bounds) })

        case .filter(let dict):
            return try .filter(dict.mapValues { try $0.getSlice(for: bounds) })

        default:
            throw ValueTypeError.wrongUsage(of: .slice(bounds))
        }
    }

    private func getFilter(with pattern: String) throws -> Self {

        switch self {
        case .dictionary(let dict):
            let regex = try NSRegularExpression(with: pattern)
            return .filter(dict.filter { regex.validate($0.key) })

        case .filter(let dict):
            return try .filter(dict.mapValues {try $0.getFilter(with: pattern) })

        case .slice(let array):
            return try .slice(array.map { try $0.getFilter(with: pattern) })

        default:
            throw ValueTypeError.wrongUsage(of: .filter(pattern))
        }
    }
}
