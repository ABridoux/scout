# Scout

All notable changes to this project will be documented in this file. `Scout` adheres to [Semantic Versioning](http://semver.org).

---
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
