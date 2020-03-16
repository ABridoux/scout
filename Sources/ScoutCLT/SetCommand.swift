import ArgumentParser
import Scout
import Foundation

private let discussion =
"""
Note: If the path is invalid, the program will retrun an error
=====

Given the following XML (as input stream or file)

<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
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

Examples
========

`scout set "urlset->[1]->changefreq":yearly` will change the second url #changefreq# key value to "yearly"

`scout set "urlset->[0]->priority":2.0` will change the first url #priority# key value to 2.0.0

`scout set "urlset->[1]->changefreq":yearly` "urlset->[0]->priority":2.0` will change both he second url #changefreq# key value to "yearly" and the first url #priority# key value to 2.0.0

`scout set "urlset->[0]->changefreq":#frequence#` will change the first url #changefreq# key name to #frequence#
"""

struct SetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set",
        abstract: "Change a value at a given path. Set the value between sharp signs to change the key name",
        discussion: discussion)

    @Argument(help: PathAndValue.help)
    var pathsAndValues: [PathAndValue]

    @Option(name: [.short, .customLong("--input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try set(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try set(from: streamInput)
        }
    }

    func set(from data: Data) throws {

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {
            try pathsAndValues.forEach {
                if $0.changeKey {
                    try json.set($0.readingPath, keyNameTo: $0.value)
                } else {
                    try json.set($0.readingPath, to: $0.value)
                }
            }

            try ScoutCommand.output(output, dataWith: json)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            try pathsAndValues.forEach {
                if $0.changeKey {
                    try plist.set($0.readingPath, keyNameTo: $0.value)
                } else {
                    try plist.set($0.readingPath, to: $0.value)
                }
            }

            try ScoutCommand.output(output, dataWith: plist)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            try pathsAndValues.forEach {
                if $0.changeKey {
                    try xml.set($0.readingPath, keyNameTo: $0.value)
                } else {
                    try xml.set($0.readingPath, to: $0.value)
                }
            }

            try ScoutCommand.output(output, dataWith: xml)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }
}

