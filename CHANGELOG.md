# Scout

All notable changes to this project will be documented in this file. `Scout` adheres to [Semantic Versioning](http://semver.org).

---
## [4.0.2](https://github.com/ABridoux/scout/tree/4.0.2) (08/05/2021)
### Changed
- Removed useless `indirect` attribute on `ExplorerValue` enum.
- Deprecated `PathExplorer.real` for `PathExplorer.double`.

## [4.0.1](https://github.com/ABridoux/scout/tree/4.0.1) (02/05/2021)
### Fixed
- Date decoding and `PathExplorer.date` [#239]
- `ExplorerXML` add and set features works with `ExplroerXML` values [#241]

## [4.0.0](https://github.com/ABridoux/scout/tree/4.0.0) (28/04/2021)
### Added
- Conversion from CSV input to one of the available formats [#181]
- `Data` and `Date` values support [#197]
- Set and add features support `Codable` values [#199]
- Possibility to read XML attributes
- Better integration with Zsh arrays and associative arrays [#235]

### Changed
- `PathExplorer` is now implemented by `ExplorerValue` for Plist, JSON and YAML [#199]
- Moved from serialisation to `Codable` using `ExplorerValue` for Plist, JSON and YAML. [#206]
- ”Add” features will no more create values on the fly. Only when a key/index is final will it be created/inserted. The method is now to first add an empty array or dictionary. [#210]
- `Path` parsing is now done with a parser rather than with regular expressions [#227]
- Command-line: `--format|-f` now required to specify the input format
- Command-line: `--csv` removed and `--csv-spe` renamed `--csv-exp`
- `PathExplorerXML` renamed to `ExplorerXML` and implements Copy on Write.

## [3.0.3](https://github.com/ABridoux/scout/tree/3.0.3) (08/04/2021)
### Fixed
- Reading from standard input temporary fix for deprecation issue [#191]

## [3.0.2](https://github.com/ABridoux/scout/tree/3.0.2) (22/03/2021)
### Fixed
- Reading from standard input [#191]

## [3.0.1](https://github.com/ABridoux/scout/tree/3.0.1) (06/03/2021)

### Added
- New functions `PathExplorer.array(:)`  and `PathExplorer.dictionary(:)` to get a `PathExplorer` value with a non-nested array and dictionary [#187]

### Fixed
- `PathExplorer.description` with a single value will now only return the value without the data format ceremony [#185]
- `SerializationFormat.Json.serialize(value:)` will throw an error if the value is a single one (rather than crashing at runtime)  [#185]

## [3.0.0](https://github.com/ABridoux/scout/tree/3.0.0) (21/02/2021)

### Added
- YAML support [#132] [#142]
- Conversion from one format to another [#133]
- Disabled colorisation when the output is piped [#140]
- List paths in the data [#151] [#154]
- Array subscript with a negative index [#152]
- Made `Path` implement several `Collection` protocols [#171]

### Changed
- `set` functions adding a value to an array with the index `-1` removed. [#152]
- Array slicing index targets a different range (shifted to the right) [#158]
- `PathExplorer` requirements and default implementations changed [#163]
- Optimized Jaro-Winkler match and removed the public access

## [2.0.0](https://github.com/ABridoux/scout/tree/2.0.0) (05/09/2020)

### Added
- Auto-completion for commands [#94]
- Array slicing [#66]
- Array and dictionaries folding at a certain level [#107]
- Delete empty dictionaries and arrays when left empty [#109]
- Dictionary filtering [#112]
- CSV export [#103]
- *Commands.md* new examples [#117]
- CLT scout command help license [#117]
- Get a dictionary keys [#121]
- CLT *read* command new `--output` option to export the read data or the CSV export into a file.

### Changed
- In-line documentation updated [#117]
- Color bool flag changed for an enumerable flag [#117]
- ArgumentParser updated to 0.3.0 [#117]
- CLT Version command changed for the `--version` `ParsableCommand` parameter [#117]

### Removed
- `-v|--verbose` flag removed. **Breaking change**. The *delete*, *set*, and *add* commands will output the data by default when no `--output` or `--modify` options are specified.

## [1.3.2](https://github.com/ABridoux/scout/tree/1.3.1) (09/08/2020)

### Fixed
- Setting a value was always writing a String rather than inferring the type for JSON and Plist [#96]

## [1.3.1](https://github.com/ABridoux/scout/tree/1.3.1) (27/07/2020)

### Added
- File header [#89]

### Changed
- Documentation updated [#89]

## [1.3.0](https://github.com/ABridoux/scout/tree/1.3.0) (24/07/2020)

### Added
- Get array or dictionary count with `PathElement.count` after an array or a dictionary. The `count` is specified with `[#]` for the command-line tool [#76]

### Changed
- `PathElement` changed for an enum, with a `PathElementRepresentable` to initiate a `Path` [#79]
- `Path` changed for a struct conforming to `Collection`  and `Equatable` [#76]
- Path explorer CRUD functions moved to extensions [#85]

### Deprecated
- `PathExplorerFactory` will be removed in 2.0.0


## [1.2.3](https://github.com/ABridoux/scout/tree/1.2.3) (06/07/2020)

### Changed
- Errors now sent to the standard error output with an error code different from 0 [#74]
- Documentation updated [#74]

### Fixed
- JSON empty string colorisation [#72]


## [1.2.2](https://github.com/ABridoux/scout/tree/1.2.2) (04/07/2020)

### Added
- `--no-color`  flag to prevent colorisation when outputting

### Changed
- Moved the documentation in a `doc` command

### Fixed
- JSON escaped quotes [#68]


## [1.2.1](https://github.com/ABridoux/scout/tree/1.2.1) (19/06/2020)

### Changed

- [Lux](https://github.com/ABridoux/lux) updated to 0.2.1 to handle tag characters in quotes


## [1.2.0](https://github.com/ABridoux/scout/tree/1.2.0) (28/05/2020)

### Added

- Key proposition when subscript key error [#52]
- Custom highlight colors in a plist file [#51]


## [1.1.0](https://github.com/ABridoux/scout/tree/1.1.0) (20/05/2020)

### Added

- Highlight output when outputting a dictionary or array value


## [1.0.2](https://github.com/ABridoux/scout/tree/1.0.2) (30/03/2020)

### Fixed
- `PathExplorerXml` string value not empty because of new line.


## [1.0.1](https://github.com/ABridoux/scout/tree/1.0.1) (30/03/2020)

### Fixed
- CLT read command when other type than string was not working


## [1.0.0](https://github.com/ABridoux/scout/tree/1.0.0) (29/03/2020)

### Added
- License
- CLT: output a dictionary or an array rather than return an error
- Json: backslashes removed when outputting the string


## [0.3.1](https://github.com/ABridoux/scout/tree/0.3.1) (29/03/2020)

### Fixed
- Root element with nested arrays: `[0][2][1].firstKey`

## [0.3.0](https://github.com/ABridoux/scout/tree/0.3.0) (28/03/2020)


### Added
- Reading path for subscript errors. A subscript error now shows precisely where the error occurs.
- CLT force type. Possibility to try to force a type when setting/adding a value. `~25~` for reals, `<25>` for integers and `?Yes?` for booleans.
- Possibility to initialise a boolean with string values like 'y", "NO", "t", "True"...
- `PathExplorer` generic `get` functions to try to convert to a `KeyAllowedType` type.

### Fixed
- It was not possible to initialise a `Path` starting with an array subscript like '[1].key1.key2'


## [0.2.2](https://github.com/ABridoux/scout/tree/0.2.2) (24/03/2020)

### Added
- Github test action
- Nested array support: `array[0][2]...`
- CLT [-m | --modify] option to read and write the data from/to the same file

### Fixed
- Xml value adding when key already existed was not working


## [0.2.1](https://github.com/ABridoux/scout/tree/0.2.1) (22/03/2020)

### Added
- PathExplorer `format` value to indicate the data format
- Playground files to try the CLT
- Get a last element in an array at the end with the negative index
- Setting a value in an array at the end with the negative index

### Fixed
- Custom separator to initialise a path now working
- Initialise and convert to a`KeyAllowedTypeKey` now uses `CustomStringConvertible` to try the `String` option
-  Negative index to initialise a path now working
- Array value setting was not working if the value was not a string
- Inserting a value in an empty array was possible
- Inserting a value in a Xml only worked when the element was the root element


## [0.2.0](https://github.com/ABridoux/scout/tree/0.2.0) (19/03/2020)

### Added
- SwiftLint file to execute SwiftLint analysis
- CLT brackets for key names containing the separator

### Changed
- CLT path to read the values: the separator was changed from `->` to `.`
- CLT path to set the values: the separator was changed from `:` to `=`
- CLT array subscript. Remove the separator e.g. `array.[index]` to `array[index]`


## [0.1.4](https://github.com/ABridoux/scout/tree/0.1.4) (19/03/2020)

### Added
- Possibility to try to force the type of a value when setting or adding
- Command-line tool options to force the string value
- Command-line tool `version` command.
- More in-line documentation
- Readme instructions to use Homebrew

### Changed
- Refactored the `PathExplorerSerialization` and `PahExplorerXml`

### Fixed
- Command-line tool "----input" long option to specify a file input fixed to "--input"


## [0.1.3](https://github.com/ABridoux/scout/tree/0.1.3) (17/03/2020)

### Changed
- Makefile and Package.swift updated

## [0.1.2](https://github.com/ABridoux/scout/tree/0.1.2) (16/03/2020)

### Added
- Instructions to download and use the executable from S3.


## [0.1.1](https://github.com/ABridoux/scout/tree/0.1.1) (16/03/2020)

### Fixed
- Added missing command `clone` in Command line instructions


## [0.1.0](https://github.com/ABridoux/scout/tree/0.1.0) (16/03/2020)

Initial release
