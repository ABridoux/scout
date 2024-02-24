//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - ValueSetter

extension ExplorerXML {

    /// Wrapper to more easily handle setting an ExplorerValue or Element.
    enum ValueSetter {
        case explorerValue(ExplorerValue)
        case explorerXML(ExplorerXML)
    }
}
