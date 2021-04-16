//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension ExplorerValue {

    func exportCSV(separator: String) throws -> String {
        switch self {
        case .array(let array), .slice(let array):
            return try exportCSV(array: array, separator: separator)

        case .dictionary(let dict), .filter(let dict):
            return try exportCSV(dictionary: dict, separator: separator)

        case .keysList: return toCSV(separator: separator)

        default: throw SerializationError.notCSVExportable(description: "")
        }
    }

    private func toCSV(separator: String) -> String {
        switch self {
        case .string, .bool, .int, .double, .data, .count:
            return description.escapingCSV(separator)

        case .dictionary(let dict), .filter(let dict):
            return dict.map { $0.value.toCSV(separator: separator) }.joined(separator: separator) + separator

        case .array(let array), .slice(let array):
            return array.map { $0.toCSV(separator: separator) }.joined(separator: separator) + separator

        case .keysList(let keys):
            return keys.map { $0.escapingCSV(separator) }.joined(separator: separator) + separator
        }
    }

    private func exportCSV(array: ArrayValue, separator: String) throws -> String {
        if let headers = try? self.headers(in: array).sortedByKeysAndIndexes() {
            return try exportCSV(arrayOfDictionaries: array, headers: headers, separator: separator)

        } else if array.allSatisfy(\.isArray) {
            return try exportCSV(arrayOfArrays: array, separator: separator)

        } else if array.allSatisfy(\.isSingle) {
            return toCSV(separator: separator)

        } else {
            throw SerializationError.notCSVExportable(description: "Array is not composed of dictionaries only, arrays only or single values only.")
        }
    }

    private func exportCSV(arrayOfDictionaries: ArrayValue, headers: [Path], separator: String) throws -> String {
        let headersLine = ExplorerValue.array(headers.lazy.map(\.description).map(ExplorerValue.string))
            .toCSV(separator: separator) + "\n"

        var csvString = arrayOfDictionaries.reduce(headersLine) { (csvString, value) in
            let line = value.exploreReduce(initial: "", paths: headers) { (csvString, result) in

                let string: String
                switch result {
                case .success(let explorer): string = explorer.description.escapingCSV(separator)
                case .failure: string = "NULL"
                }
                return "\(csvString)\(string)\(separator)"
            }
            return "\(csvString)\(line)\n"
        }

        csvString.removeLast()
        return csvString
    }

    private func exportCSV(arrayOfArrays: ArrayValue, separator: String) throws -> String {
        var csvString = try arrayOfArrays.reduce("") { (csvString, value) in
            guard value.isArray else { throw ExplorerError.mismatchingType(ArrayValue.self, value: value) }
            let line = value.toCSV(separator: separator)
            return "\(csvString)\(line)\n"
        }

        csvString.removeLast()
        return csvString
    }

    private func exportCSV(dictionary: DictionaryValue, separator: String) throws -> String {
        var csvString = try dictionary
            .sorted { $0.key < $1.key }
            .reduce("") { (csvString, element) in
                let (key, value) = element

                guard let array = value.array, array.allSatisfy(\.isSingle) else {
                    throw ExplorerError.mismatchingType(ArrayValue.self, value: value)
                }

                let line = value.toCSV(separator: separator)
                return "\(csvString)\(key)\(separator)\(line)\n"
        }

        csvString.removeLast()
        return csvString
    }

    /// The headers for the array of dictionaries
    /// #### Complexity
    /// `O(n)` where `n` is the number of elements in the array
    private func headers(in array: ArrayValue) throws -> Set<Path> {
        try array.reduce(into: Set<Path>()) { (paths, value) in
            guard value.isDictionary else { throw ExplorerError.mismatchingType(DictionaryValue.self, value: value) }
            try value.listPaths(filter: .targetOnly(.single)).forEach { paths.insert($0) }
        }
    }
}
