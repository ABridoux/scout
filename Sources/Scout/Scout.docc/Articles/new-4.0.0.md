# What's new in Scout  4.0.0

Learn the new features of Scout 4.0.0 as well as what was broken or deprecated

## General

Scout 4.0.0 is a global refactor of the code base. This was a necessary step to offer new features. Also, the code is now more robust, faster and more flexible to welcome new features.

### New data structure

To reach this goal, a new data structure has been chosen to represent a ``PathExplorer`` values. The ``ExplorerValue`` in an indirect enum and thus is a purely functional structure. For Scout features, it allows to write less and cleaner code, but also to remove the need to manage the states a PathExplorer had in the previous versions.

This new data structure also allows to use Codable to encode and decode data, which offers several new possibilities, like customizing a `Coder` to better fit one’s use case, or to set and add Codable types with no effort (more on that).

> Note: The XML parsing has not changed and still uses AEXML. I tried in several ways to use ExplorerValue with a XML coder but this always led to informations loss or strange behaviors. Thus I rather rewrote the XML features with this new ”functional mindset” and I believe it is clearer. Also, small new features like attributes reading are now offered.

### New path parsing
The Path parsing is now done with a Parser rather than with regular expressions. This is more robust and faster. The same goes for parsing a path and its value when adding or setting a value with the command-line tool.

### Breaking changes

- Adding a value to a path with non-existing keys and indexes will not work anymore. Only when an element of the path is the last will it be valid to add a new key. The solution is now to create empty dictionaries or arrays and fill them after.
- Setting or adding values will no more work with `Any` values but with ``ExplorerValueRepresentable``

### New features
- Usage of `Codable` for Plist, JSON and YAML rather than serialization types to encode and decode data. This means that any Encoder or Decoder can be used with it.
- `Data` and `Date` values are now supported.
- It’s now possible to set or add a dictionary or an array value to an explorer. Also, in Swift, a type conforming to ``ExplorerValueRepresentable`` can be set or added. A default implementation is provided for Codable types.
- XML attributes can now be read. In Swift, new options offer to keep the attributes, and to specify a strategy to handle single child elements when exporting a XML explorer.
- Import a CSV file to one of the available formats with a precisely shaped structure.

## ExplorerValue

Serializable PathExplorers like Plist, JSON and YAML or others like XML can use this type to set, add, or read a value.

The new ``ExplorerValue`` is the following enum.

```swift
public indirect enum ExplorerValue {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case data(Data)
    case date(Date)
    case array([ExplorerValue])
    case dictionary([String: ExplorerValue])
}
```

### Expressible

``ExplorerValue`` implements the "Expressible" protocols when it's possible for the types it deals with. This means that it's possible to define an ExplorerValue like the following examples.

```swift
let string: ExplorerValue = "string"
let dict: ExplorerValue = ["foo": "bar"]
let array: ExplorerValue = ["Riri", "Fifi", "Loulou"]
```

### Codable
``ExplorerValue`` conforms to `Codable`. The new SerializablePathExplorer (used for JSON, Plist and XML) uses this conformance to offer initialisation from Data. But this also means that any Coder can be used to read an ExplorerValue from Data. This was already possible to use a different serializer than the default one in the previous implementations. But customizing a Coder is much simpler and now more common in Swift. For instance, setting a custom `Date` decoding strategy is always offered in most coders.

### Conversion with ExplorerValueRepresentable

Setting and adding a value to an explorer now works with ExplorerValue. For instance, to set Tom’s age to 60:

```swift
json.set("Tom", "age", to: .int(60))
```

Of course, convenience types and functions are offered, so the line above can be written like this:

```swift
json.set("Tom", "age", to: 60)
```

This is made possible with the `ExplorerValueRepresentable` protocol. It only requires a function to convert the type to an ExplorerValue.

```swift
protocol ExplorerValueRepresentable {
    func explorerValue() throws -> ExplorerValue
}
```

Default implementations are provided for the values mapped by ExplorerValue like `String`, `Double`, an `Array` if its `Element` conforms to ``ExplorerValueRepresentable`` and a `Dictionary` if its `Value` conforms to ExplorerValueRepresentable. 
Some examples:

```swift
let stringValue = "toto"
try json.set("name", to: stringValue)
let dict = ["firstName": "Riri", "lastName": "Duck"]
try json.set("profile", to: dict)
```

Also, a default implementation for any `Encodable` type is provided. An Encoder is implemented to encode a type to an `ExplorerValue`. Similarly, a `Decoder` is implemented to decode an ExplorerValue to a Decodable type with the protocol ExplorerValueCreatable. A type alias is provided to group both protocols:

```swift
ExplorerValueConvertible = ExplorerValueRepresentable & ExplorerValueCreatable
```

For instance with a simple struct.

```swift
struct Record: Codable, ExplorerValueConvertible {
    var name: String
    var score: Int
}

let record = Record(name: "Riri", score: 20)
```

It’s then possible to set the record value at a specific path.

```swift
plist.set("ducks", "records", 0, to: record)
```

### About XML
The new ``ExplorerXML`` can also set and add `ExplorerValues`, as well as be converted to one. Because XML is not serializable, this process might loose informations. Options to keep attributes and single child strategies are offered. This is useful in the conversion features like XML → JSON. Whenever it’s possible, `ExplorerXML` will keep as much information as possible. When it’s not possible, the type will act consistently. For instance, when setting a new `Array` value, the children of the XML element will all be named "Element".

In Swift, it’s possible to rather set an AEXMLElement to have more freedom on the children. This requires more work, but I believe it’s a good thing to have this possibility. To know how to create and edit AEXMLElements, you can checkout the [repo](https://github.com/tadija/AEXML).

## CSV import

A new CSV import feature is available to convert a CSV input as JSON, Plist, YAML or XML. A cool feature when working with named headers is that they will be treated as paths. This can shape very precisely the structure of the converted data. For instance, the following CSV

```csv
name.first;name.last;hobbies[0];hobbies[1]
Robert;Roni;acting;driving
Suzanne;Calvin;singing;play
Tom;Cattle;surfing;watching movies
```

will be converted to the following Json structure.

```json
[
  {
    "hobbies" : [
      "acting",
      "driving"
    ],
    "name" : {
      "first" : "Robert",
      "last" : "Roni"
    }
  },
  {
    "hobbies" : [
      "singing",
      "play"
    ],
    "name" : {
      "first" : "Suzanne",
      "last" : "Calvin"
    }
  },
  {
    "name" : {
      "first" : "Tom",
      "last" : "Cattle"
    },
    "hobbies" : [
      "surfing",
      "watching movies"
    ]
  }
]
```

When there are no headers, the input will be treated as a one or two dimension(s) array.
To create a `PathExplorer` from a CSV string, use ``SerializablePathExplorer/fromCSV(string:separator:hasHeaders:)`` function.


```swift
let json = PathExplorers.Json.fromCSV(csvString, separator: ";", hasHeaders: true)
```

The `hasHeaders` boolean is needed to specify whether the CSV string begins with named headers.
