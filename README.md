<p  align="center">
<img src="Resources/scout-logo.png" height=512px" />
<br>
Swift package<br>
    <a href="#">
        <img src="https://img.shields.io/badge/Swift-5.6-orange" />
    </a>
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://codecov.io/gh/ABridoux/scout">
        <img src="https://codecov.io/gh/ABridoux/scout/branch/master/graph/badge.svg" />
    </a>
    <br/>
Install<br>
    <a href="#">
        <img src="https://img.shields.io/badge/platforms-mac+linux-brightgreen.svg?style=flat" alt="Mac + Linux" />
    </a>
    <a href="https://github.com/ABridoux/scout/releases">
        <img src="https://img.shields.io/badge/cli-tool-informational">
    </a>
     <a href="https://github.com/ABridoux/scout/releases">
        <img src="https://img.shields.io/badge/install-pkg%2Bzip-blue" />
    </a>
    <a href="#">
        <img src="https://img.shields.io/github/downloads/ABridoux/scout/total">
    </a>
    <br/>
</p>

# Scout <a href="https://github.com/ABridoux/scout/releases"><img src="https://img.shields.io/github/v/release/Abridoux/scout?color=lightgrey&label=latest"/></a>

This library aims to make specific formats data values reading and writing simple when the data format is not known at build time.
It was inspired by [SwiftyJson](https://github.com/SwiftyJSON/SwiftyJSON) and all the projects that followed, while trying to cover more ground, like Xml or Plist. It unifies writing and reading for those different formats. Getting a value in a Json format would be the same as getting a value in a Xml format.

Supported formats:
- JSON
- Plist
- YAML
- XML

#### Minimum requirements
- Swift: 5.6+
- macOS: 10.13+
- iOS: 10.0+
- tvOS: 10.0+
- watchOS: 4.0+

## Summary
- [Why](#why)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Special thanks](#special-thanks)
- [Contributing](#contributing)

### Wiki

The **Swift** wiki can be found on the [Github pages](https://abridoux.github.io/scout/documentation/scout).
The **command-line** wiki can be found on [Woody's Findings](https://www.woodys-findings.com/scout/wiki-command-line/home) .

### News
- Checkout what's new in **Scout** 4.0.0 [here](https://www.woodys-findings.com/scout/news-4.0.0).
- Checkout what’s new in **Scout** 3.0.0 [here](https://www.woodys-findings.com/scout/news-3.0.0).

## Why?

With the Foundation libraries to encode/decode Json and Plist, one could ask: why would someone need Scout? Simple answer: there are still cases where you do not know the data format. Sometimes, you will just want to read a single value from a Plist file, and you do not want to create the the `struct` to decode this file. Or you simply cannot know the data format at build time.

### Context
I have been working with many Mac admins recently, and many had to deal with Json, Plist and Xml data. While some were using a format-specific library like [jq](https://stedolan.github.io/jq/) to parse Json, others were using **awk**.  Each approach is valid, though it comes with some tradeoffs.

#### Using a format-specific library
You can use a library for each format. But I am not aware today of a library that unifies all of them. So, what you learned with [jq](https://stedolan.github.io/jq/) cannot be reused to parse Plist data. You would have to learn to use **PlistBuddy** or the **defaults** command. With Scout, you can parse the same way Json, Plist and Xml data.

#### Using a generic text-processing tool
Don't get me wrong, **awk** is a wonderful tool. It can do so many things. But it is not that easy to learn. And you have to find a way to parse each different format. **Scout** is [really easy to use](https://www.woodys-findings.com/scout/wiki-command-line/examples).

<br>

## Features
- CRUD functions for JSON, Plist, XML and YAML data format
    - Read, Set, Delete or Add a value at a specific path in the data
    - Subscript dictionary with a dot "."
    - Subscript arrays with an index between brackets [index]. Negative indexes allowed.
    - Set a key name
    - Force a type
    - Dictionary and array count
    - Dictionary keys
    - XML attributes reading
    - Delete array or dictionary when deleting all its values 
    - Array slicing for *read* and *delete* commands 
    - Dictionary filtering for *read* and *delete* commands 
- List paths in the data to iterate over the values
- Stream or file input
- Find best match in case of a typo
- Data formats conversion (e.g. JSON -> Plist, YAML -> XML)
- CSV export for arrays and dictionaries of arrays 
- CSV import with precise data structure shaping
- Export to a Zsh array or associative array
- Syntax highlighting
- Folding at a depth level
- Auto-completion for commands 

### Insights

The wiki ([Swift](https://abridoux.github.io/scout/documentation/scout) | [Command-line](https://www.woodys-findings.com/scout/wiki-command-line/home)) gives more details to use those features. Also, the [Playground](Playground) folder offers several commands to play with a *People* file in several formats. The same commands can be found on this [page](https://www.woodys-findings.com/scout/wiki-command-line/examples).

#### CRUD functions for JSON, Plist and XML data format
- add a value (Create)
- read a value (Read)
- set a value (Update)
- delete a value (Delete)

Subscript dictionary with a dot "." like "dictionary.key"

Subscript arrays with an index between brackets [index] like "array[index]".
Negative indexes allowed.

##### Set key name
Set a key name rather than its value.

##### Try to force a type
Prevent the automatic inferring of a type and try to force one when setting or adding a value.

##### Dictionary and array count
Get a dictionary or an array count with the `[#]` symbol

##### Dictionary keys list
Get a dictionary keys list with the `{#}` symbol.

##### Delete arrays or dictionaries when left empty
With the *delete* command, it is possible to specify that a dictionary or an array should be deleted when all its keys are also being deleted.

##### Array slicing
Specify a slice of an array to read it or to delete it with `[lower:upper]` syntax. Omitting lower bound ~ 0, omitting upper bound ~ last index. Works with negative indexes like `[-4:-3]` to specify a slice from the last 5th to the last 3rd element. With negative slice, omitting the upper bound ~ last index like `[-3:]` to get the last 4 elements of the array.

##### Dictionary filtering
Specify a regular expression between sharp signs '#' to filter the keys of a dictionary, like `people.#h.*#` to target all the keys starting with "h" in the dictionary 'people'. A key is a valid match when it is entirely validated by the regular expression.

#### List paths
It's possible to list the paths in the data to iterate over the values. The paths can be retrieved as an array in a shell script to be used in a loop.
This list can be filtered to target only single or group values, specific keys or values, or paths starting from a base.

You can [learn more](https://www.woodys-findings.com/scout/wiki-command-line/list-paths) about this feature. Also, [scripting recipes](https://www.woodys-findings.com/scout/wiki-command-line/scripting-recipes) are provided with use cases using this feature.

#### Stream or file input
Set the input as a file with the input option `-i | --input` or as the last process/command output with a pipe:
```bash
scout "path.to.value" -i File.yml -f yaml
# is the same as
cat File | scout "path.to.value" -f yaml
```

#### Find best match in case of a typo
Scout uses the Jaro-Winkler distance to indicate which key is the closest to an unresolved key.

#### Syntax highlighting
Scout will highlight the output when reading or outputting (with the verbose flag) a dictionary or an array value. This is done with the [Lux](https://github.com/ABridoux/lux) library. You can try it with the following command.

```bash
curl --silent "https://api.github.com/repos/ABridoux/scout/releases/latest" | scout
```

![](Resources/syntax-highlight.png)

Another example with one of the playground files and the following command:

```bash
scout read -i People.plist -f plist "people.Robert.age=2"
```

When dealing with large files (although it is not recommended to output large files in the terminal), highlighting the output might bring to slowdowns. It's possible to deactivate the colorisation with the flag `--no-color` or `--nc`. This is automatic when writing the output in a file or when the program output is piped.

#### Data formats conversion
The library offer a conversion feature from a supported format to another one like Plist -> JSON or YAML -> XML. Read or modify the data and export it to another format.
[Learn more](https://www.woodys-findings.com/scout/wiki-command-line/conversion)

#### CSV export
Export data when dealing with arrays or a dictionary of arrays.

#### CSV import
Convert CSV input to one of the available formats. When the CSV has named headers, specify how the data structure should be built (array, dictionary) using paths.

#### Zsh arrays
Export a 1-dimension array to a Zsh array with the `-e array` option and to an associative array with the `-e dictionary` option.

##### Customise colors
You can specify your own colors set as explained [here](https://www.woodys-findings.com/scout/wiki-command-line/highlighting). Also, some presets for the macOS terminal default styles can be found in the [Highlight presets folder](Highlight-presets)

#### Folding
Fold arrays or dictionaries at a certain depth level to make the data more readable

#### Auto-completion of commands
When auto-completion is enabled on the shell, use `scout install-completion-script`, then the `source` command if needed to get auto-completion for scout commands.

<br>

## Installation

### Command Line

#### Homebrew
Use the following command.

```bash
brew install ABridoux/formulae/scout
```
It will **download the notarized executable** from the [latest release](https://github.com/ABridoux/scout/releases/latest/download/scout.zip).


#### Download

You can download the [latest version of the executable](https://github.com/ABridoux/scout/releases/latest/download/scout.zip) from the [releases](https://github.com/ABridoux/scout/releases). Note that the **executable is notarized**. Also, a [scout package](https://github.com/ABridoux/scout/releases/latest/download/scout.pkg) is provided.

After having unzipped the file, you can install it if you want to.

```bash
$ install scout /usr/local/bin/
```

Here is a command which downloads the latest version of the program and install it in */usr/local/bin*. 
Run it to download and install the latest version of the program. It erases the current version you may have. The last line is optional and installs the script to auto-complete the commands.

```bash
curl -LO https://github.com/ABridoux/scout/releases/latest/download/scout.zip && \
unzip scout.zip && \
rm scout.zip && \
install scout /usr/local/bin && \
rm scout
```

##### Note
- To find all scout versions, please browse the [releases](https://github.com/ABridoux/scout/releases) page.
- When deploying a package (with a MDM for example), it might be useful to add the version to the name. To get scout latest version: simply run `scout --version` (`scout version` version < 2.0.0)  to get your **installed scout version**, or ` curl --silent "https://api.github.com/repos/ABridoux/scout/releases/latest" | scout tag_name` to get the latest version **available on the Github repository**.

#### Auto-completion
You can run `scout install-completion-script` to install the script to auto-complete commands depending on your shell. After this command, you might want to run the `source` command for the changes to be effective.

Bash: `source ~/.bashrc` <br />
Zsh: `source ~/.zshrc`

### Swift package

Start by importing the package in your file *Packages.swift*.
```swift
let package = Package (
    ...
    dependencies: [
        .package(url: "https://github.com/ABridoux/scout", from: "3.0.0")
    ],
    ...
)
```
You can then `import Scout` in a file.

<br>

## Usage

### Playground
You can find and try examples with one file *People* using the different available formats in the [Playground folder](Playground). The folder contains a *Commands.md* file so that you can see how to use the same commands with the different formats.

## Special thanks
First of all, many thanks to all contributors of this library. Their help is truly appreciated.

To parse and edit XML data, as the standard library does not offer a simple way to do it, **Scout** uses the wonderful library of Marko Tadić: [AEXML](https://github.com/tadija/AEXML). He has done an amazing work. And if several XML parsing and writing libraries exist today, I would definitely recommend his. Marko, you might never read those lines, but thank you!
The same goes for the [Yams](https://github.com/jpsim/Yams) and its contributors. Thank you for this project.

Thanks also to the team at Apple behind the [ArgumentParser](https://github.com/apple/swift-argument-parser) library. They have done an incredible work to make command line tools in Swift easy to implement.

Finally, thanks to [Thijs Xhaflaire](https://github.com/txhaflaire/) and [Armin Briegel](https://github.com/scriptingosx) for their ideas and helpful feedback.

### References
Font used for the logo: Ver Army by [Damien Gosset](http://sweeep.fr/cv/index.php?c=fonts).

<br>

## Contributing
Scout is open-source and under a [MIT license](License). If you want to make a change or to add a new feature, please [open an issue](https://github.com/ABridoux/scout/issues) or [a pull request](https://github.com/ABridoux/scout/pull/new). You can learn more about contributing on this [wiki page](https://github.com/ABridoux/scout/wiki/%5B81%5D-Contributing).
Also, feel free to [report a bug, an error or even a typo](https://github.com/ABridoux/scout/issues).

