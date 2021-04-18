//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

extension ExplorerValue {

    func exportCSV(separator: String) throws -> String {
        switch self {
        case .array(let array):
            return try exportCSV(array: array, separator: separator)

        case .dictionary(let dict):
            return try exportCSV(dictionary: dict, separator: separator)

        default: throw SerializationError.notCSVExportable(description: "")
        }
    }

    private func toCSV(separator: String) -> String {
        switch self {
        case .string, .bool, .int, .double, .data:
            return description.escapingCSV(separator)

        case .dictionary(let dict):
            return dict.map { $0.value.toCSV(separator: separator) }.joined(separator: separator) + separator

        case .array(let array):
            return array.map { $0.toCSV(separator: separator) }.joined(separator: separator) + separator
        }
    }

    private func exportCSV(array: ArrayValue, separator: String) throws -> String {
        if let headers = self.headers(in: array)?.sortedByKeysAndIndexes() {
            return try exportCSV(arrayOfDictionaries: array, headers: headers, separator: separator)

        } else if array.allSatisfy(\.isArray) {
            let arrays = array.compactMap(\.array)
            return try exportCSV(arrayOfArrays: arrays, separator: separator)

        } else if array.allSatisfy(\.isSingle) {
            return toCSV(separator: separator)

        } else {
            throw SerializationError.notCSVExportable(
                description: "The value can either be an array of dictionaries, an array of arrays, an array of single values or a dictionary of arrays"
            )
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

    private func exportCSV(arrayOfArrays: [ArrayValue], separator: String) throws -> String {
        var csvString = arrayOfArrays.reduce("") { (csvString, arrayValue) in
            let line = Self.array(arrayValue).toCSV(separator: separator)
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
                    throw SerializationError.notCSVExportable(description: "The array for key \(key) in the dictionary to export is not composed of single values only")
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
    private func headers(in array: ArrayValue) -> Set<Path>? {
        guard array.allSatisfy(\.isDictionary) else { return nil }

        return try? array.reduce(into: Set<Path>()) { (paths, value) in
            try value.listPaths(filter: .targetOnly(.single)).forEach { paths.insert($0) }
        }
    }
}
