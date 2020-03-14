import Foundation

public typealias Xml = PathExplorerXML
public typealias Json = PathExplorerSerialization<JsonFormat>
public typealias Plist = PathExplorerSerialization<PlistFormat>

public struct PathExplorerFactory {
    public static func make<T: PathExplorer>(_ type: T.Type, from data: Data) throws -> T {
        try T(data: data)
    }
}
