//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser
import Scout
import Lux

extension ParsableCommand {

    /// Try to read data from the optional `filePath`. Otherwise, return the data from the standard input stream
    func readDataOrInputStream(from filePath: String?) throws -> Data {
        if let filePath = filePath {
            return try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
        }

        // The function `readDataToEndOfFile()` was deprecated since macOS 10.15.4
        // but now (macOS 11.2.2) it seems to be deprecated for never (100_000)).
        return FileHandle.standardInput.readDataToEndOfFile()

//        return try input.data(using: .utf8)
//            .unwrapOrThrow(error: .invalidData("Unable to get data from standard input"))

//        if #available(OSX 10.15.4, *) {
//            do {
//                return try FileHandle
//                    .standardInput
//                    .readToEnd()
//                    .unwrapOrThrow(error: .invalidData("Unable to get data from standard input"))
//                }
//                return standardInputData
//            } catch {
//                throw RuntimeError.invalidData("Error while reading data from standard input. \(error.localizedDescription)")
//            }
//        } else {
//            return FileHandle.standardInput.readDataToEndOfFile()
//        }
    }
}

extension ParsableCommand {

    func colorInjector(for format: Scout.DataFormat) throws -> TextInjector {
        switch format {

        case .json:
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            return jsonInjector

        case .plist:
            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            return plistInjector

        case .yaml:
            let yamlInjector = YAMLInjector(type: .terminal)
            if let colors = try getColorFile()?.yaml {
                yamlInjector.delegate = YAMLInjectorColorDelegate(colors: colors)
            }
            return yamlInjector

        case .xml:
            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            return xmlInjector
        }
    }

    /// Retrieve the color file to colorise the output if one is found
    func getColorFile() throws -> ColorFile? {
        let colorFileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".scout/Colors.plist")
        guard let data = try? Data(contentsOf: colorFileURL) else { return nil }

        return try PropertyListDecoder().decode(ColorFile.self, from: data)
    }
}
