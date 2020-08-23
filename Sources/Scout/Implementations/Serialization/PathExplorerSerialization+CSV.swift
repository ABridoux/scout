//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    public func exportCSV(separator: String = ";") throws -> String {
        if value is DictionaryValue {
            let values = try exportCSVDictionary(separator: separator)
            var csv = ""
            values.forEach { line in
                csv.append(contentsOf: line.joined(separator: separator))
                csv.append(contentsOf: "\n")
            }
            _ = csv.popLast() // remove the new line
            return csv

        } else if value is ArrayValue {
            return try exportCSVArray(separator: separator)
        } else {
            throw PathExplorerError.csvExportWrongGroupValue
        }
    }

    public func exportCSVArray(separator: String = ";") throws -> String {
        let array = try cast(value, as: .array, orThrow: .csvExportWrongGroupValue)
        var csv = ""

        guard let firstValue = array.first else { return csv }

        switch firstValue {

        case is DictionaryValue:
            let (headers, values) = try exportCSVArrayOfDictionaries(separator: separator)
            // headers
            csv.append(headers.joined(separator: separator))
            csv.append(contentsOf: "\n")

            // values
            values.forEach { line in
                csv.append(contentsOf: line.joined(separator: separator))
                csv.append(contentsOf: "\n")
            }

            _ = csv.popLast() // remove the new line

        case is ArrayValue:
            let values = try exportCSVArrayOfArrays(separator: separator)
            values.forEach { line in
                csv.append(contentsOf: line.joined(separator: separator))
                csv.append(contentsOf: "\n")
            }
            _ = csv.popLast() // remove the new line

        default:
            array.forEach { value in
                let stringValue = String(describing: value).escapingCSV(separator)
                csv.append(stringValue + separator)
            }

            _ = csv.popLast() // remove the last space
        }

        return csv
    }

    func exportCSVArrayOfArrays(separator: String) throws -> [[String]] {
        let array = try cast(value, as: .array, orThrow: .csvExportWrongGroupValue)
        var values = [[String]]()

        for (index, value) in array.enumerated() {
            let array = try cast(value, as: .array, orThrow: .csvExportAmbiguous(expected: "Array", path: readingPath.appending(index)))
            var lineValues = [String]()

            for (subIndex, subValue) in array.enumerated() {
                guard !isGroup(value: subValue) else {
                    throw PathExplorerError.csvExportAmbiguous(expected: "Single", path: readingPath.appending(index, subIndex))
                }
                lineValues.append(String(describing: subValue))
            }

            values.append(lineValues)
        }

        return values
    }

    func exportCSVArrayOfDictionaries(separator: String) throws -> (headers: [String], values: [[String]]) {
        let array = try cast(value, as: .array, orThrow: .csvExportWrongGroupValue)

        // get the key names with a first tour
        var keyNamesSet = Set<String>()
        for (index, value) in array.enumerated() {
            guard value is DictionaryValue else {
                throw PathExplorerError.csvExportAmbiguous(expected: "Dictionary", path: readingPath.appending(index))
            }
            exploreGroup(value: value) { (key, _) in
                keyNamesSet.insert(key)
            }
        }

        let keyNames = Array(keyNamesSet).sorted()
        var headersIndexes = [String: Int]()
        for (index, key) in keyNames.enumerated() {
            headersIndexes[key] = index
        }
        var values = [[String]]()
        let headersCount = keyNames.count

        // parse the array once more to get the values
        array.forEach { value in
            var newValues: [String] = Array(repeating: "NULL", count: headersCount)

            exploreGroup(value: value) { (key, value) in
                let index = headersIndexes[key, default: 0]
                newValues[index] = String(describing: value).escapingCSV(separator)
            }

            values.append(newValues)
        }

        return (keyNames, values)
    }

    func exportCSVDictionary(separator: String) throws -> [[String]] {
        let dict = try cast(value, as: .dictionary, orThrow: .csvExportWrongGroupValue)
        var values = [[String]]()

        try dict.forEach { (_, value) in
            let array = try cast(value, as: .array, orThrow: .csvExportWrongGroupValue)
            values.append(array.map { String(describing: $0).escapingCSV(separator) })
        }

        return values

    }

    func exploreGroup(key: String = "", value: Any, toExecute block: (String, Any) -> Void) {
        if let dict = value as? DictionaryValue {
            dict.forEach { (keyValue, value) in
                var newKey = keyValue
                if key != "" {
                    newKey = key + Path.defaultSeparator + keyValue
                }
                if !isGroup(value: value) {
                    block(newKey, value)
                }
                exploreGroup(key: newKey, value: value, toExecute: block)
            }
        } else if let array = value as? ArrayValue {
            for (index, value) in array.enumerated() {
                let newKey = key == "" ? key : key + PathElement.index(index).description

                if key != "" && !isGroup(value: value) {
                    block(newKey, value)
                }
                exploreGroup(key: newKey, value: value, toExecute: block)
            }
        } else {
            block(key, value)
        }
    }
}
