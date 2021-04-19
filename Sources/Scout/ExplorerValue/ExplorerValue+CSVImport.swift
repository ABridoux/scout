//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import SwiftCSV

extension ExplorerValue {

    static func fromCSV(string: String, separator: Character, hasHeaders: Bool) throws -> ExplorerValue {
        let csv = try CSV(string: string, delimiter: separator, loadColumns: hasHeaders)
        return try from(csv: csv, headers: hasHeaders)
    }

    private static func from(csv: CSV, headers: Bool) throws -> ExplorerValue {
        if headers {
            return try fromArrayOfDictionaries(csv: csv)
        } else if csv.enumeratedRows.count == 1 {
            return .array(csv.enumeratedRows[0].map(ExplorerValue.singleFrom))
        } else {
            return array <^> ([csv.header] + csv.enumeratedRows).map { array <^> $0.map(ExplorerValue.singleFrom) }
        }
    }

    private static func fromArrayOfDictionaries(csv: CSV) throws -> ExplorerValue {
        let headers = try csv.header.map { try (key: $0, path: Path(string: $0)) }.sorted { $0.path.comparedByKeyAndIndexes(with: $1.path) }
        let dicts = try csv.namedRows.map { row -> ExplorerValue in try from(row: row, with: headers) }
        return .array(dicts)
    }

    private static func from(row: [String: String], with headers: [(key: String, path: Path)]) throws -> ExplorerValue {
        var dict = ExplorerValue.dictionary([:])

        try headers.forEach { (key, path) in
            guard let value = row[key] else { return }
            try dict.add(.singleFrom(string: value), at: path)
        }

        return dict
    }
}
