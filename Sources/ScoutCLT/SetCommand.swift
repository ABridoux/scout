import ArgumentParser
import Scout
import Foundation

private let discussion =
"""
Notes
=====
- If the path is invalid, the program will retrun an error
- Enclose the value with sharp signs to change the key name: #keyName#
- Enclose the value with slash signs to force the value as a string: /valueAsString/ (Plist, Json)
- Enclose the value with interrogative signs to force the value as a boolean: ?valueToBoolean? (Plist, Json)
- Enclose the value with tilde signs to force the value as a real: ~valueToReal~ (Plist)
- Enclose the value with chevron signs to force the value as a integer: <valueToInteger> (Plist)
- When accessing an array value by its index, use the index -1 to access to the last element

Examples
========

Given the following XML (as input stream or file)

<?xml version="1.0" encoding="UTF-8"?>
<urlset>
    <url>
        <loc>https://your-website-url.com/posts</loc>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
        <lastmod>2020-03-10</lastmod>
    </url>
    <url>
        <loc>https://your-website-url.com/posts/first-post</loc>
        <changefreq>monthly</changefreq>
        <priority>0.5</priority>
        <lastmod>2020-03-10</lastmod>
    </url>
</urlset>

`scout set "urlset[1].changefreq"=yearly` will change the second url #changefreq# key value to "yearly"

`scout set "urlset[0].priority"=2.0` will change the first url #priority# key value to 2.0

`scout set "urlset[1].changefreq"=yearly` "urlset[0].priority"=2.0` will change both he second url #changefreq# key value to "yearly" and the first url #priority# key value to 2.0

`scout set "urlset[-1].priority"=2.0` will change the last url #priority# key value to 2.0

`scout set "urlset[0].changefreq"=#frequence#` will change the first url #changefreq# key name to #frequence#

`scout set "urlset[0].priority"=/2.0/` will change the first url #priority# key value to the String value "2.0"

`scout set "urlset[0].priority"=~2~` will change the first url #priority# key value to the Real value 2 (Plist only)

"""

struct SetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set",
        abstract: "Change a value at a given path.",
        discussion: discussion)

    @Argument(help: PathAndValue.help)
    var pathsAndValues: [PathAndValue]

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path")
    var modifyFilePath: String?

    @Flag(name: [.short, .long], default: false, inversion: .prefixedNo, help: "Output the modified data")
    var verbose: Bool

    func run() throws {

        if let filePath = modifyFilePath ?? inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try set(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try set(from: streamInput)
        }
    }

    func set(from data: Data) throws {
        let output = modifyFilePath ?? self.output

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {

            try set(pathsAndValues, in: &json)
            try ScoutCommand.output(output, dataWith: json, verbose: verbose)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {

            try set(pathsAndValues, in: &plist)
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {

            try set(pathsAndValues, in: &xml)
            try ScoutCommand.output(output, dataWith: xml, verbose: verbose)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    func set<Explorer: PathExplorer>(_ pathAndValues: [PathAndValue], in explorer: inout Explorer) throws {
        for pathAndValue in pathAndValues {
            let (path, value) = (pathAndValue.readingPath, pathAndValue.value)

            if pathAndValue.changeKey {
                try explorer.set(path, keyNameTo: value)
                continue
            }

            if let forceType = pathAndValue.forceType {
                switch forceType {
                case .string: try explorer.set(path, to: value, as: .string)
                case .real: try explorer.set(path, to: value, as: .real)
                case .int: try explorer.set(path, to: value, as: .int)
                case .bool: try explorer.set(path, to: value, as: .bool)
                }
            } else {
                try explorer.set(path, to: value)
            }
        }
    }
}
