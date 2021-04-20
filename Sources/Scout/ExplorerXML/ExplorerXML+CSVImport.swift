//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import AEXML
import SwiftCSV

extension ExplorerXML {

    public static func fromCSV(string: String, separator: Character, hasHeaders: Bool) throws -> ExplorerXML {
        let csv = try CSV(string: string, delimiter: separator, loadColumns: hasHeaders)
        return try from(csv: csv, headers: hasHeaders)
    }

    private static func from(csv: CSV, headers: Bool) throws -> ExplorerXML {
        if headers {
            return try fromArrayOfDictionaries(csv: csv)
        } else if csv.enumeratedRows.count == 1 {
            let explorer = ExplorerXML(name: Element.defaultName)
            csv.enumeratedRows[0].forEach { explorer.addChild(ExplorerXML(name: Element.defaultName, value: $0)) }
            return explorer
        } else {
            let explorer = ExplorerXML(name: Element.defaultName)
            let rows = [csv.header] + csv.enumeratedRows
            rows.forEach { row in
                let childArray = ExplorerXML(name: Element.defaultName)
                row.forEach { childArray.addChild(ExplorerXML(name: Element.defaultName, value: $0)) }
                explorer.addChild(childArray)
            }

            return explorer
        }
    }

    private static func fromArrayOfDictionaries(csv: CSV) throws -> ExplorerXML {
        let headers = try csv.header.map { try (key: $0, path: Path(string: $0)) }.sorted { $0.path.comparedByKeyAndIndexes(with: $1.path) }

        let explorer = ExplorerXML(name: Element.defaultName)

        try csv.namedRows.forEach { row in
            let child = try from(row: row, with: headers)
            explorer.addChild(child)
        }

        return explorer
    }

    private static func from(row: [String: String], with headers: [(key: String, path: Path)]) throws -> ExplorerXML {
        var explorer = ExplorerXML(value: [:])

        try headers.forEach { (key, path) in
            guard let value = row[key] else { return }
            try explorer.add(.singleFrom(string: value), at: path)
        }

        return explorer
    }
}
