//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation

extension Path: ExpressibleByArgument {

    public init?(argument: String) {
        try? self.init(string: argument)
    }

//    public static var defaultCompletionKind: CompletionKind { .custom(evaluatePath) }

    /// Functions which could be used to complete a path.
    /// The arguments completions does not work well with several arguments though, which prevent to use this completion
    static func evaluatePath(_ arguments: [String]) -> [String] {
        var argumentsCopy = arguments

        // try to find the file path inside the arguments. Otherwise, we cannot complete the paths
        guard let file = getFilePath(in: argumentsCopy) else {
            return argumentsCopy
        }

        let data: Data
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: file.replacingTilde))
        } catch {
            return argumentsCopy
        }

        // Hold a path explorer to use it
        let pathExplorer: PathExplorerGet

        if let json = try? Json(data: data) {
            pathExplorer = json
        } else if let plist = try? Plist(data: data) {
            pathExplorer = plist
        } else if let xml = try? Xml(data: data) {
            pathExplorer = xml
        } else {
            return argumentsCopy
        }

        // auto complete only the last argument
        guard var argument = arguments.last else {
            return argumentsCopy
        }

        if argument.hasPrefix("\"") {
            argument.removeFirst()
        }

        do {
            let path = try Path(string: argument)
            let newArgument = complete(path: path, in: data, with: pathExplorer)
            argumentsCopy[arguments.count - 1] = newArgument
        } catch {}

        return argumentsCopy
    }

    /// Try to complete the given path with the given path explorer, returning the path with the
    /// best Jaro-Winkler match if the path last key is incorrect.
    static func complete(path: Path, in data: Data, with pathExplorer: PathExplorerGet) -> String {
        var pathWithoutLast = path
        _ = pathWithoutLast.popLast()

        do {
            try pathExplorer.tryToGet(path)
            return path.description
        } catch let PathExplorerError.subscriptMissingKey(path: _, key: _, bestMatch: bestMatch) {
            if let bestMatch = bestMatch {
                let path = pathWithoutLast.appending(bestMatch).description
                return path
            }
        } catch {}

        return path.description
    }

    /// Try to find the file path argument in the given arguments
    static func getFilePath(in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(where: { $0.hasPrefix("-") && ($0.contains("i") || $0.contains("m")) }) else {
            return nil
        }

        guard index < arguments.count - 1 else { return nil }
        return arguments[index + 1]
    }
}
