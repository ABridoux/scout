import Foundation

public extension String {

    /// Replace the `~` in the file path
    var replacingTilde: String {
        guard let tildeIndex = firstIndex(of: "~") else { return self }

        let userHomeDirectory = FileManager.default.homeDirectoryForCurrentUser.relativePath
        let afterIndex = index(after: tildeIndex)
        let pathAfterHome = String(self[afterIndex...])
        return userHomeDirectory + pathAfterHome
    }
}
