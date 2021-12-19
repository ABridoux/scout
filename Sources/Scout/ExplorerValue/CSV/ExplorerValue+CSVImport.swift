//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import SwiftCSV

extension ExplorerValue {

    private typealias Tree = PathTree<ExplorerValue?>

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
        let rootTree = Tree.root()
        let headers = try csv.header
            .map { try (key: $0, path: Path(string: $0)) } // transform keys to paths
            .sorted { $0.path.comparedByKeyAndIndexes(with: $1.path) } // sort by path
            .map { ($0.key, rootTree.insert(path: $0.path)) } // insert paths in the PathTree

        let dicts = try csv.namedRows.compactMap { row -> ExplorerValue? in
            try from(row: row, with: headers, rootTree: rootTree)
        }

        return .array(dicts)
    }

    private static func from(row: [String: String], with keysTrees: [(key: String, path: Tree)], rootTree: Tree) throws -> ExplorerValue? {
        keysTrees.forEach { (key, tree) in
            if let value = row[key] {
                tree.value = .leaf(value: .singleFrom(string: value))
            } else {
                tree.value = .leaf(value: nil)
            }
        }

        return try ExplorerValue.newValue(exploring: rootTree)
    }
}
