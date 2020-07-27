//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Lux

/// Piece of documentation used to be printed
protocol Documentation {
    static var text: String { get }
}

extension Documentation {

    /// Get one example per line
    /// - Parameters:
    ///   - examples: Array of (code, output) to display
    ///   - injector: Injector to use. Default is Zsh.
    /// - Returns: All examples with injected Zsh code
    static func examplesText(from examples: [(code: String, output: String)], with injector: TextInjector = ZshInjector(type: .terminal)) -> String {
        examples.reduce("") { (result, example) in
            "\(result) \(injector.inject(in: example.code)) \(example.output)\n"
        }
    }
}
