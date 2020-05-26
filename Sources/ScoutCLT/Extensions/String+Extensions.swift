import Foundation

extension String {

    /// Replace the `~` in the file path
    var replacingTilde: String {
        guard let tildeIndex = firstIndex(of: "~") else { return self }

        let userHomeDirectory = FileManager.default.homeDirectoryForCurrentUser.relativePath
        let afterIndex = index(after: tildeIndex)
        let pathAfterHome = String(self[afterIndex...])
        return userHomeDirectory + pathAfterHome
    }

    var reset: String { "\u{001B}[0m" }
    var bold: String { "\u{001B}[1m\(self)\u{001B}[22m" }
    var validation: String { "\u{001B}[32m\(self)\u{001B}[39m"}
    var error: String { "\u{001B}[91m\(self)\u{001B}[39m"}

}
