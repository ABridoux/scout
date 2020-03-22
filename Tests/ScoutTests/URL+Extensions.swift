import Foundation

extension URL {

    private static let peopleURL: URL = {
        /**https://stackoverflow.com/questions/57555856/get-url-to-a-local-file-with-spm-swift-package-manager/57708634#57708634 */
        let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
        return currentFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Playground", isDirectory: true)
            .appendingPathComponent("People")
    }()

    static let peopleJson: URL = { Self.peopleURL.appendingPathExtension("json") }()
    static let peoplePlist: URL = { Self.peopleURL.appendingPathExtension("plist") }()
    static let peopleXml: URL = { Self.peopleURL.appendingPathExtension("xml") }()
}
