# Scout

This library aims to make specific formats data values reading and writing simple when the data format is not known at build time.
It was inspired by [SwiftyJson](https://github.com/SwiftyJSON/SwiftyJSON) and all the projects that followed, while trying to cover more ground, like Xml or Plist. It unifies writing and reading for those different formats. Getting a value in a Json format would be the same as getting a value in a Xml format.

## Why?

With the Foundation libraries to encode/decode Json and Plist, one could ask: why would someone need **Scout**? Simple answer: there are still cases where you do not know the data format. Sometimes, you will just want to read a single value from a Plist file, and you do not want to create the the `struct` to decode this file. Or you simply cannot know the data format at build time.

## Context
I have been working with many Mac admins recently, and many had to deal with Json, Plist and Xml data. While some where using a format-specific library like [jq](https://stedolan.github.io/jq/) to parse Json, others where using **awk**.  Each approach is valid, though it comes with some compromises.

### Using a format-specific library
You can use a library for each format. But I am not aware today of a library that unifies all of them. So, what you learnt with [jq](https://stedolan.github.io/jq/) cannot be reused to parse Plist data. You would have to learn to use **PlistBuddy** or the **defaults** command. With Scout, you can parse the same way Json, Plist and Xml data.

### Using a generic text-processing tool
Don't get me wrong, **awk** is a wonderful tool. It can do so many things. But it is not that easy to learn. And you have to find a way to parse each different format. **Scout** is really easy to use, as we will see.

## How to use it

### Command Line

#### Installing

##### Homebrew
Use the following command.

```bash
brew install ABridoux/formulae/scout
```

It will **download the executable** from [here](https://abridoux-public.s3.us-east-2.amazonaws.com/scout/scout-latest.zip). There is a [known bug](https://github.com/apple/swift-argument-parser/issues/80) which is resolved by using Swift 5.2 but the Xcode version supporting Swift 5.2 is still in [beta](https://developer.apple.com/download/more/). Moreover, I believe that most Homebrew users do not really care about building the program themselves. If I am wrong, please let me know (by opening an [issue](https://github.com/ABridoux/scout/issues)) for example). Note that you can still build the program by cloning this git as explained below.

##### Git

Use the following lines to clone the repository and to install **scout** (requires Swift 5.2 toolchain to be installed). You can check the *Makefile* to see the commands used to build and install the executable.

```bash
$ git clone https://github.com/ABridoux/scout
$ cd scout
$ make
```

The program should be install in */usr/local/bin*. You can then remove the repository if you do not want to keep it:

```bash
$ cd ..
$ rm -r Scout
```

##### Download

If you cannot use those methods, you can rather download the latest version of the executable [here](https://abridoux-public.s3.us-east-2.amazonaws.com/scout/scout-latest.zip).
After having unzipped the file, you can install it if you want to:

```bash
install scout /usr/local/bin/ 
```

Here is a command which downloads the latest version of the program and install it in */usr/local/bin*. 
Run it to download and install the latest version of the program. It erases the current version you may have.

```bash
curl -o scout.zip https://abridoux-public.s3.us-east-2.amazonaws.com/scout/scout-latest.zip && \
unzip scout.zip && \
rm scout.zip && \
install scout /usr/local/bin && \
rm scout
```

#### Usage examples

Given the following Json (as input stream or file with the `input` option)

```json
{
  "people": {
    "Tom": {
      "height": 175,
      "age": 68,
      "hobbies": [
        "cooking",
        "guitar"
      ]
    },
    "Arnaud": {
      "height": 180,
      "age": 23,
      "hobbies": [
        "video games",
        "party",
        "tennis"
      ]
    }
  }
}
```

##### Reading
`scout "people.Tom.hobbies[0]"` will output "cooking"

`scout "people.Arnaud.height"` will output "180"

##### Setting
`scout set "people.Tom.hobbies[0]"=basket` will change Tom first hobby from "cooking" to "basket"

`scout set "people.Arnaud.height"=160` will change Arnaud's height from 180 to 160

`scout set "people.Tom.hobbies[0]"=basket "people.Arnaud.height"=160` will change Tom first hobby from "cooking" to "basket" **and** change Arnaud's height from 180 to 160

`scout set "people.Tom.age"=#years#` will change Tom age key name from #age# to #years#

`scout set "people.Tom.height"=/175/` will change Tom height from 180 to a **String value** "175"

##### Deleting
`scout delete "people.Tom.height"` will delete Tom height
`scout delete "people.Tom.hobbies[0]"` will delete Tom first hobby

##### Adding
`scout add "people.Franklin.height"=165` will create a new dictionary Franklin and add a height key into it with the value 165

`scout add "people.Tom.hobbies[-1]="Playing music"` will add the hobby "Playing music" to Tom hobbies at the end of the array

`scout add "people.Arnaud.hobbies[1]"=reading` will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party"

`scout add "people.Franklin.hobbies[0]"=football` will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array

`scout add "people.Franklin.height"=/165/` will create a new dictionary Franklin and add a height key into it with the **String value** "165"

#### Options
Each command will have several options, like the possibility to output the modified data to string or into a file.

`cat People.json | scout "people.Tom.height" ` is the same as 
`scout "people.Tom.height -i People.json `

The command
``` bash
scout set \
"people.Tom.height"=190 \
"people.Arnaud.hobbies[1]"=football \
-i People.json -o People.json
```
 will copy the content in the file *People.json*, modify it and write it back to *People.json*.

The command
```bash
scout set \
"people.Tom.height"=190 \
"people.Arnaud.hobbies[1]"=football \
-i People.json -v
```
will output the modified data.

#### Key names containing dots

If a key name contains dots, e.g. `com.company.product`, you can enclose it between brackets:

```bash
scout "bundle.(com.company.product).version"
```

### Swift

Unlike [SwiftyJson](https://github.com/SwiftyJSON/SwiftyJSON), Scout does not offer the `subscript` methods. As those methods do not allow today to throw an error, using them implies to find sometimes strange ways to return value when the key is missing.

#### Import

Start by importing the package in your file *Packages.swift*.
```swift
let package = Package (
    ...
    dependencies: [
        .package(url: "https://github.com/ABridoux/Scout", from: "0.1.0")
    ],
    ...
)
```
You can then import the package when needed.

#### Some remarks
- When setting a value, if a key does not exist in the path, an error will be thrown.
- When adding a value, all the keys which do not exist in the path will be created.
- The type of a value is automatically inferred when setting or adding a key value. You can try to force the type with the `as type` parameter. An error will be thrown if the value is not convertible to the given type.

#### Examples

To explore a format, start by creating the corresponding explorer:

```swift
let json = try PathExplorerFactory.make(Json.self, from: data)
```

Given the following Json

```json
{
  "people": {
    "Tom": {
      "height": 175,
      "age": 68,
      "hobbies": [
        "cooking",
        "guitar"
      ]
    },
    "Arnaud": {
      "height": 180,
      "age": 23,
      "hobbies": [
        "video games",
        "party",
        "tennis"
      ]
    }
  }
}
```
Here are some examples

```swift
// Reading
// --------

try json.get("people", "Tom", "height").int // output 175
try json.get("people", "Arnaud", "hobbies", 2).string // output "party"

// Updating
// -------

// will change Tom's height from 175 to 160
try json.set("people", "Tom", "height", to: 160)

// will change Tom's height from 175 to the String value "160" 
try json.set("people", "Tom", "height", to: 160, as: .string)

// will change Tom's height from 175 to the Double value 160.0
try json.set("people", "Tom", "height", to: 160, as: .real)

// will throw an error as "height" is not convertible to an integer
try json.set("people", "Tom", "height", to: "height", as: .int)

// will change Arnaud second hobby from "party" to "basketball"
try json.set("people", "Arnaud", "hobbies",  1, to: "basketball")

// will change Tom's age key name from #age# to #years#
try json.set("people", "Tom", "age", keyNameTo: "years")

// Deleting
// --------

try json.delete("people", "Tom", "height") // will delete Tom height key

// Adding
// -------

// will add a new dictionary key named "Franklin" into "people" and insert a key named "height" into it with the value 190
try json.add(190, at: "people", "Franklin", "height")

// will add a new dictionary key named "Franklin" into "people" and insert a key named "height" into it with the String value "190"
try json.add(190, at: "people", "Franklin", "height", as: .string)

// will add a new dictionary key named "Franklin" into "people", adding a hobbies array with one element: "basket"
try json.add("basket", at: "people", "Franklin", "hobbies", 0)

// will add a new hobby to Tom's hobbies at the end of the hobbies array
try json.add("football", at: "people", "Tom", "hobbies", -1)

// will add a new key named "color" into "Arnaud" dictionary, with the value "blue"
try json.add("football", at: "people", "Arnaud", "color", "blue")
```

Note that when parsing the same file but with the Plist format, you would just have to change one line.

So use this
```swift
let plist = try PathExplorerFactory.make(Plist.self, from: data)
```
to parse this file

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>people</key>
	<dict>
		<key>Tom</key>
		<dict>
			<key>height</key>
			<integer>175</integer>
			<key>age</key>
			<integer>68</integer>
			<key>hobbies</key>
			<array>
				<string>cooking</string>
				<string>guitar</string>
			</array>
		</dict>
		<key>Arnaud</key>
		<dict>
			<key>height</key>
			<integer>181</integer>
			<key>age</key>
			<integer>23</integer>
			<key>hobbies</key>
			<array>
				<string>video games</string>
				<string>party</string>
				<string>tennis</string>
			</array>
		</dict>
	</dict>
</dict>
</plist>

```

#### Export

If you have modified the path explorer, you can export it to a `Data` or a `String`

```swift
let xml = try PathExplorerFactory.make(Xml.self, from: data)

// do some modifications...

let data = try xml.exportData()
let string = try xml.exportString()
```

## Special thanks
To parse Xml data, as the standard library does not offer simple way to do it, **Scout** uses the wonderful library of Marko Tadić: [AEXML](https://github.com/tadija/AEXML). He has done an amazing work. And if several Xml parsing and writing libraries exist today, I would definitely recommend his. Marko, you might never read those lines, but thank you again!

Thanks also to the team at Apple behind the [ArgumentParser](https://github.com/apple/swift-argument-parser) library. They have done an incredible work to make command line tools in Swift easy to implement.

## Contributing
Scout is open-source and you are free to use it the way you want. If you want to make a change or to add a new feature, please [open a Pull Request](https://github.com/ABridoux/scout/pull/new).
Feel free to [report a bug, an error or even a typo](https://github.com/ABridoux/scout/issues).

