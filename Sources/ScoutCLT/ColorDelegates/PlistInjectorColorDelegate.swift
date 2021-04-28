//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Lux

final class PlistInjectorColorDelegate: PlistDelegate {

    // MARK: - Properties

    let colors: PlistColors

    // MARK: - Initialisation

    init(colors: PlistColors) {
        self.colors = colors
    }

    required init() {
        colors = PlistColors()
        super.init()
    }

    // MARK: - Functions

    override func terminalModifier(for category: PlistCategory) -> TerminalModifier {
        var colorCode: Int?

        switch category {
        case .tag: colorCode = colors.tag
        case .keyName: colorCode = colors.keyName
        case .keyValue: colorCode = colors.keyValue
        case .comment: colorCode = colors.comment
        case .header: colorCode = colors.header
        }

        if let code = colorCode {
            return TerminalModifier(colorCode: code)
        } else {
            return super.terminalModifier(for: category)
        }
    }
}
