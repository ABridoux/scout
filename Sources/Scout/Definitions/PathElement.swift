import Foundation

/// Components to subscript a `PathExplorer`
public protocol PathElement: Codable {}

extension String: PathElement {}
extension Int: PathElement {}
