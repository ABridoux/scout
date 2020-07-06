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

    static var prefix: String { "\u{001B}[" }
    static var colorReset: String { "\(Self.prefix)39m" }
    static var reset: String { "\(Self.prefix)0m" }
    var mainColor: String { colored(with: 88) }

    var bold: String { "\(Self.prefix)1;39m\(self)\(Self.prefix)22m" }
    var error: String { "\(Self.colorPrefix(91))\(self)\(Self.colorReset)"}

    static func colorPrefix(_ code: Int) -> String { "\(prefix)38;5;\(code)m" }
    func colored(with code: Int) -> String { "\(Self.colorPrefix(code))\(self)\(Self.reset)" }
}
