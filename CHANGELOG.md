# Scout

All notable changes to this project will be documented in this file. `Scout` adheres to [Semantic Versioning](http://semver.org).

---
## [0.2.0](https://github.com/ABridoux/scout/tree/0.2.0) (19/03/2020)

## Added
- SwiftLint file to execute SwiftLint analysis
- CLT brackets for key names containing the separator

## Changed
- CLT path to read the values: the separator was changed from `->` to `.`
- CLT path to set the values: the separator was changed from `:` to `=`
- CLT array subscript. Remove the separator e.g. `array.[index]` to `array[index]`

## [0.1.4](https://github.com/ABridoux/scout/tree/0.1.4) (19/03/2020)

### Added
- Possiblity to try to force the type of a value when setting or adding
- Command-line tool options to force the string value
- Command-line tool `version` command.
- More in-line documentation
- Readme instructions to use Homebrew

## Changed
- Refractored the `PathExplorerSerialization` and `PahExplorerxml`

### Fixed
- Command-line tool ""----input"" long option to specify a file input fixed to "--input"

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
