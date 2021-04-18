//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Lux

final class YAMLInjectorColorDelegate: YAMLDelegate {

    // MARK: - Properties

    let colors: YamlColors

    // MARK: - Initialisation

    init(colors: YamlColors) {
        self.colors = colors
    }

    required init() {
        colors = YamlColors()
        super.init()
    }

    // MARK: - Functions

    override func terminalModifier(for category: YAMLCategory) -> TerminalModifier {
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
