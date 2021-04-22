//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    public func exportCSV(separator: String?) throws -> String {
        try _exportCSV(separator: separator ?? defaultCSVSeparator)
    }

    private func _exportCSV(separator: String) throws -> String {
        if children.allSatisfy(\.isSingle) { // array of singles
            return try exportAsArrayOfSingles(separator: separator)
        } else if differentiableChildren { // dictionary of arrays
            return try exportAsDictionaryOfArrays(separator: separator)
        } else if children.allSatisfy(\.childrenHaveCommonName) { // array of arrays
            return try exportAsArrayOfArrays(separator: separator)
        } else { // array of dictionaries (or else)
            return try exportCSVAsArrayOfDictionaries(separator: separator)
        }
    }

    private func exportAsArrayOfSingles(separator: String) throws -> String {
        children.reduce("") { (csvString, explorer) in "\(csvString)\(explorer.description.escapingCSV(separator))\(separator)" }
    }

    private func exportAsArrayOfArrays(separator: String) throws -> String {
        var csvString = try children.reduce("") { (csvString, explorerXML) in
            try "\(csvString)\(explorerXML.exportAsArrayOfSingles(separator: separator))\n"
        }

        csvString.removeLast()
        return csvString
    }

    private func exportAsDictionaryOfArrays(separator: String) throws -> String {
        var csvString = try children
            .sorted { $0.name < $1.name }
            .reduce("") { (csvString, explorer) in
            try "\(csvString)\(explorer.name)\(separator)\(explorer.exportAsArrayOfSingles(separator: separator))\n"
        }

        csvString.removeLast()
        return csvString
    }

    private func exportCSVAsArrayOfDictionaries(separator: String) throws -> String {
        let headers = try self.headers().sortedByKeysAndIndexes()
        let headersLine = headers.reduce("") { "\($0)\($1.description.escapingCSV(separator))\(separator)" } + "\n"

        var csvString = children.reduce(headersLine) { (csvString, explorer) in
            let line = explorer.reduceWithMemory(initial: "", paths: headers) { (csvString, result) in

                let string: String
                switch result {
                case .success(let explorer): string = explorer.description.escapingCSV(separator)
                case .failure: string = nullCSVValue
                }
                return "\(csvString)\(string)\(separator)"
            }
            return "\(csvString)\(line)\n"
        }

        csvString.removeLast()
        return csvString
    }

    private func headers() throws -> Set<Path> {
        try children.reduce(into: Set<Path>()) { (paths, explorer) in
            try explorer.listPaths(filter: .targetOnly(.single)).forEach { paths.insert($0 )}
        }
    }
}
