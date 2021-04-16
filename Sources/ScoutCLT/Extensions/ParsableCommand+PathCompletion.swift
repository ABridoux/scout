//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout

/// A PathExplorer without the Self requirement to try to get a path.
protocol PathExplorerGet {
    func tryToGet(_ path: Path) throws
}

extension CodablePathExplorer: PathExplorerGet {
    func tryToGet(_ path: Path) throws {
        _ = try get(path)
    }
}

extension ExplorerXML: PathExplorerGet {
    func tryToGet(_ path: Path) throws {
        _ = try get(path)
    }
}
