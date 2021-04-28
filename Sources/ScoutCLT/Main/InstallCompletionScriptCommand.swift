//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser

private let argumentParserDocumentation = "https://github.com/apple/swift-argument-parser/blob/master/Documentation/07%20Completion%20Scripts.md"

struct InstallCompletionScriptCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "install-completion-script",
        abstract: "Install Scout completion script in the right directory",
        discussion: "See \(argumentParserDocumentation)",
        shouldDisplay: false)

    var fileManager: FileManager { .default }
    static let homeDirectory = FileManager.default.homeDirectoryForCurrentUser

    // MARK: - Functions

    func run() throws {

        guard let shell = CompletionShell.autodetected() else {
            throw RuntimeError.completionScriptInstallation(description: "Unable to find the preferred shell")
        }

        var compShell: CompShell

        switch shell {
        case .zsh:
            if fileManager.fileExists(atPath: OhMyZsh.directory.path) { // oh my Zsh
                compShell = OhMyZsh()
            } else if fileManager.fileExists(atPath: Zsh.directory.path) { // zsh
                compShell = Zsh()
            } else {
                throw RuntimeError.completionScriptInstallation(description: "Unable to find \(OhMyZsh.name) or \(Zsh.name) directory. Please refer to \(argumentParserDocumentation)")
            }

        case .bash:
            if fileManager.fileExists(atPath: BashCompletion.completionsDirectory.path) { // bash completion
                compShell = BashCompletion()
            } else { // bash
                compShell = Bash()
            }

        default:
            throw RuntimeError.completionScriptInstallation(description: "Unable to find the preferred shell. Please refer to \(argumentParserDocumentation)")
        }

        let shellType = type(of: compShell)
        print("\(shellType.name) detected. Installing the completion script at \(shellType.completionsDirectory.path)")
        try installScript(for: compShell)
    }

    private func installScript(for shell: CompShell) throws {
        let shellType = type(of: shell)

        if !fileManager.fileExists(atPath: shellType.completionsDirectory.path) {
            print("\(shellType.name) completion directory not found. Creating it at \(shellType.completionsDirectory.path)...")
            try fileManager.createDirectory(at: shellType.completionsDirectory, withIntermediateDirectories: false)
        }

        if fileManager.fileExists(atPath: shellType.completionScript.path) {
            print("Completion script found. Re-installing it...")
            try fileManager.removeItem(at: shellType.completionScript)
        }

        let script = ScoutMainCommand.completionScript(for: shellType.shell)
        guard let data = script.data(using: .utf8) else {
            throw RuntimeError.completionScriptInstallation(description: "Unable to convert the script to valid data")
        }

        fileManager.createFile(atPath: shellType.completionScript.path, contents: data)
        print("Re/Installed completion script.")
    }
}

private protocol CompShell {
    static var shell: CompletionShell { get }
    static var name: String { get }
    static var completionsDirectory: URL { get }
    static var completionScript: URL { get }
}

private struct OhMyZsh: CompShell {
    static let shell = CompletionShell.zsh
    static let name = "Oh My Zsh"
    static let directory = InstallCompletionScriptCommand.homeDirectory.appendingPathComponent(".oh-my-zsh")
    static let completionsDirectory = directory.appendingPathComponent("completions")
    static let completionScript = completionsDirectory.appendingPathComponent("_scout")
}

private struct Zsh: CompShell {
    static let shell = CompletionShell.zsh
    static let name = "Zsh"
    static let directory = InstallCompletionScriptCommand.homeDirectory.appendingPathComponent(".zsh")
    static let completionsDirectory = directory.appendingPathComponent("completion")
    static let completionScript = completionsDirectory.appendingPathComponent("scout.sh")
}

private struct BashCompletion: CompShell {
    static let shell = CompletionShell.bash
    static let name = "Bash Completion"
    static let completionsDirectory = URL(fileURLWithPath: "/usr/local/etc/bash_completion.d")
    static let completionScript = completionsDirectory.appendingPathComponent("_scout")
}

private struct Bash: CompShell {
    static let shell = CompletionShell.bash
    static let name = "Bash"
    static let completionsDirectory = InstallCompletionScriptCommand.homeDirectory.appendingPathComponent(".bash_completions")
    static let completionScript = completionsDirectory.appendingPathComponent("scout.bash")
}
