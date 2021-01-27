//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Storage

private struct IndexedSlice {
    var index: Int
    var lowerBound: Int
    var upperBound: Int
}

private struct Indexed<Value> {
    var index: Int
    var value: Value
}

private struct IndexedCollection<Value>: Collection {
    typealias Element = Indexed<Value>

    var elements: [Element]

    var startIndex: Int { elements.startIndex }
    var endIndex: Int { elements.endIndex }

    init() {
        elements = []
    }

    subscript(position: Int) -> Element { elements[position] }
    func index(after i: Int) -> Int { elements.index(after: i) }

    func makeIterator() -> IndexingIterator<[Element]> {
        elements.makeIterator()
    }

    mutating func append(index: Int, value: Value) {
        elements.append(.init(index: index, value: value))
    }

    mutating func popLast() -> Element? { elements.popLast() }
    mutating func removeAll() { elements.removeAll() }
}

private struct IndexedElements {
    var indexes = IndexedCollection<Int>()
    var slices = [IndexedSlice]()
    var keys = IndexedCollection<String>()
    var filters = IndexedCollection<String>()
}

private extension Array where Element == IndexedSlice {

    mutating func append(index: Int, lower: Int, upper: Int) {
        append(.init(index: index, lowerBound: lower, upperBound: upper))
    }
}

// MARK: - Functions

extension Path {

    /// Compute the path by changing the special path elements like slices or filters
    ///
    /// Filters are removed. Slices are changed to indexes to target the path.
    /// #### Complexity
    /// O(n) with `n` number of elements in the path
    public func flattened() -> Path {
        var indexedElements = getIndexesElements()
        var newElements = elements
        var indexesToRemove = [Int]()

        update(slices: &indexedElements.slices, with: &indexedElements.indexes, in: &newElements, indexesToRemove: &indexesToRemove)
        update(filters: indexedElements.filters, with: indexedElements.keys, in: &newElements, indexesToRemove: &indexesToRemove)

        // remove the indexes used to replaced the slices and the keys used to replace the filters
        indexesToRemove.sorted { $1 < $0 }.forEach { newElements.remove(at: $0) }

        // remove the left filters
        newElements.removeAll { element in
            if case .filter = element {
                return true
            }
            return false
        }

        return Path(newElements)
    }

    private func getIndexesElements() -> IndexedElements {
        var indexElements = IndexedElements()

        enumerated().forEach { (index, element) in
            switch element {

            case .count, .keysList:
                break

            case .key(let name):
                indexElements.keys.append(index: index, value: name)

            case .filter(let pattern):
                indexElements.filters.append(index: index, value: pattern)

            case .index(let indexValue):
                indexElements.indexes.append(index: index, value: indexValue)

            case .slice(let bounds):
                guard
                    let lowerBound = bounds.lastComputedLower,
                    let upperBound = bounds.lastComputedUpper
                else { break }
                #warning("Handle negative indexes when added")

                indexElements.slices.append(index: index, lower: lowerBound, upper: upperBound)
                indexElements.indexes.removeAll()
            }
        }

        return indexElements
    }

    private func update(
        slices: inout [IndexedSlice],
        with indexes: inout IndexedCollection<Int>,
        in newElements: inout [PathElement],
        indexesToRemove: inout [Int]) {

        // change the slices with the gathered idnexes
        if slices.count == 1, indexes.count == 1, let firstSlice = slices.first, let index = indexes.first {
            // specific use case with one slice
            let newIndex = firstSlice.lowerBound + index.value
            newElements[firstSlice.index] = .index(newIndex)
            indexesToRemove.append(index.index)
            slices.removeFirst()

        } else if let firstSlice = slices.first, let lastIndex = indexes.popLast() {
            // with several slices, the first slice replacement index is determined
            // by the last index
            let newIndex = firstSlice.lowerBound + lastIndex.value
            newElements[firstSlice.index] = .index(newIndex)
            indexesToRemove.append(lastIndex.index)
            slices.removeFirst()
        }

        slices.enumerated().forEach { (index, slice) in
            // for each slice, take the last remaining index, compute the final index value
            // and replace the slice with the index computed value
            let arrayIndex = indexes[index]
            let newIndex = slice.lowerBound + arrayIndex.value
            newElements[slice.index] = .index(newIndex)
            indexesToRemove.append(arrayIndex.index)
        }
    }

    private func update(
        filters: IndexedCollection<String>,
        with keys: IndexedCollection<String>,
        in newElements: inout [PathElement],
        indexesToRemove: inout [Int]) {

        // replace the filters with the corresponding key
        var filtersIterator = filters.reversed().makeIterator()
        var keysIterator = keys.reversed().makeIterator()

        while let filter = filtersIterator.next(), let key = keysIterator.next() {
            guard
                let regex = try? NSRegularExpression(pattern: filter.value),
                regex.validate(key.value)
            else { continue }

            newElements[filter.index] = .key(key.value)
            indexesToRemove.append(key.index)
        }
    }
}
