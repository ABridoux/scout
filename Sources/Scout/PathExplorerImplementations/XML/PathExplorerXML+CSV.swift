//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

// MARK: - Public

extension PathExplorerXML {

    public func exportCSV(separator: String?) throws -> String {
        let separator = separator ?? defaultCSVSeparator

        let (headers, values) = try exportCSVHeadersAndValues(separator: separator)
        var csv = ""

        if !headers.isEmpty {
            csv += headers.joined(separator: separator)
            csv.append("\n")
        }

        values.forEach { valuesLine in
            csv += valuesLine.joined(separator: separator)
            csv.append("\n")
        }

        _ = csv.popLast() // remove last new line

        return csv
    }
}

// MARK: - Internal

extension PathExplorerXML {

    func exportCSVHeadersAndValues(separator: String) throws -> (headers: [String], values: [[String]]) {
        var headers = Set<String>()
        var values = [[String]]()

        // epxlore a first time to get the key names
        exploreGroup(element: element) { (key, _) in
            if key != "" {
                headers.insert(key)
            }
        }

        let sortedHeaders = Array(headers).sorted()
        var headersIndexes = [String: Int]()
        let headersCount = headers.count
        for (index, header) in sortedHeaders.enumerated() {
            headersIndexes[header] = index
        }

        // explore a second time to get the values
        element.children.forEach { child in
            var valuesLine = headersCount > 0 ? Array(repeating: "NULL", count: headersCount) : [String]()

            let pathContainsDictFilter = readingPath.contains { element in
                if case .filter = element {
                    return true
                } else {
                    return false
                }
            }

            if valuesLine.isEmpty, pathContainsDictFilter {
                // dictionary of arrays so add the label
                valuesLine.append(child.name)
            }

            exploreGroup(element: child) { (key, value) in
                let value = value.escapingCSV(separator)
                if let index = headersIndexes[key] {
                    valuesLine[index] = value
                } else {
                    valuesLine.append(value)
                }
            }

            values.append(valuesLine)
        }

        return (sortedHeaders, values)
    }

    func exploreGroup(key: String = "", element: AEXMLElement, toExecute block: (String, String) -> Void) {
        guard !element.children.isEmpty else {
            block(key, element.string)
            return
        }

        let childrenName = element.commonChildrenName
        for (index, child) in element.children.enumerated() {
            let newKey: String
            if child.name.components(separatedBy: GroupSample.keySeparator).last == childrenName { // array
                newKey = key == "" ? key : key + PathElement.index(index).description
            } else { // dictionary
                newKey = key == "" ? child.name : key + GroupSample.keySeparator + child.name
            }

            exploreGroup(key: newKey, element: child, toExecute: block)
        }
    }
}
