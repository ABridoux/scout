//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Lux

final class JSONInjectorColorDelegate: JSONDelegate {

    // MARK: - Properties

    let colors: JsonColors

    // MARK: - Initialisation

    init(colors: JsonColors) {
        self.colors = colors
    }

    required init() {
        colors = JsonColors()
        super.init()
    }

    // MARK: - Functions

    override func terminalModifier(for category: JSONCategory) -> TerminalModifier {
        var colorCode: Int?

        // retrieve the color code in the colors plist if any
        switch category {
        case .punctuation: colorCode = colors.punctuation
        case .keyName: colorCode = colors.keyName
        case .keyValue: colorCode = colors.keyValue
        }

        if let code = colorCode {
            return TerminalModifier(colorCode: code)
        } else {
            return super.terminalModifier(for: category)
        }
    }
}
