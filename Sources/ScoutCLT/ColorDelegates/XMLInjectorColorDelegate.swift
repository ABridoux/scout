//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Lux

final class XMLInjectorColorDelegate: XMLEnhancedDelegate {

    // MARK: - Properties

    let colors: XmlColors

    // MARK: - Initialisation

    init(colors: XmlColors) {
        self.colors = colors
    }

    required init() {
        colors = XmlColors()
        super.init()
    }

    // MARK: - Functions

    override func terminalModifier(for category: XMLEnhancedCategory) -> TerminalModifier {
        var colorCode: Int?

        switch category {
        case .openingTag: colorCode = colors.openingTag
        case .closingTag: colorCode = colors.closingTag
        case .punctuation: colorCode = colors.punctuation
        case .key: colorCode = colors.key
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
