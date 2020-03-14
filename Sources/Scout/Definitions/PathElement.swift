import Foundation

/// Components to subscript a `PathExplorer`
public protocol PathElement {}

extension String: PathElement {}
extension Int: PathElement {}
