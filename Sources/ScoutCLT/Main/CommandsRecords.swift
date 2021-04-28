//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser

extension NameSpecification {

    static let dataFormat: NameSpecification = [.customShort("f", allowingJoined: true), .customLong("format")]
    static let inputFilePath: NameSpecification = [.short, .customLong("input")]
    static let outputFilePath: NameSpecification = [.short, .customLong("output")]
    static let modifyFilePath: NameSpecification = [.short, .customLong("modify")]
    static let fold: NameSpecification = [.short, .long]
    static let csvSeparator: NameSpecification = [.customLong("csv-export")]
    static let export: NameSpecification = [.short, .customLong("export")]
}

extension ArgumentHelp {

    static let dataFormat = ArgumentHelp("The data format of the input")
    static let inputFilePath = ArgumentHelp("A file path from which to read the data")
    static let outputFilePath = ArgumentHelp("Write the modified data into the file at the given path")
    static let modifyFilePath = ArgumentHelp("Read and write the data into the same file at the given path")
    static let colorise = ArgumentHelp("Highlight the output. --no-color or --nc to prevent it")
    static let fold = ArgumentHelp("Fold the data at the given depth level")
    static let csvSeparator  = ArgumentHelp("Convert the array data into CSV with the given separator")
    static let export = ArgumentHelp("Convert the data to the specified format")
}
