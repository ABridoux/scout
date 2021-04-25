//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ScoutCLTCore
import ArgumentParser

private let _abstract =
"""


\(header: "Value specification")

Specify a path with an associated value.
Like "firstKey.secondKey[index].thirdKey=value".

The following notes indicates how to specify the value.

\(subheader: "Automatic")
Let Scout automatically infer the type.
Ex: 123 will be treated as an integer, and Endo as a string.

\(subheader: "String")
Force the specified value to be a string.
Usage: enclose the value with single quotes 'value' or slash /value/.

\(subheader: "Real")
Force the specified value to be a real (Plist only).
Usage: enclose the value with tildes: ~value~.

\(subheader: "Array")
Usage: enclose a list of values and separate them with commas ','.
Use single quote to specify strings with commas.
It's possible to nest arrays or dictionaries.

Examples
````````
[Endo, 'String, with a comma', 123, ~40~]
[Endo, [values, in , nested, array]]

\(subheader: "Dictionary")
Usage: enclose a list of (key, value) pairs separated with a double point ':' and separate them with commas ','.
Use single quote to specify strings with commas or a key with a commas.
It's possible to nest dictionaries or arrays.

Examples
````````
[Riri: 20, Fifi: duck, Loulou: '60']
[ducks: [Riri, Fifi, Loulou], mouses: [Mickey: 20, Minnie: 30]]

"""

extension PathAndValue: ExpressibleByArgument {

    static var abstract: String { _abstract }

    static var help: ArgumentHelp { ArgumentHelp(abstract, valueName: "path=value") }

    public init?(argument: String) {
        self.init(string: argument)
    }
}
