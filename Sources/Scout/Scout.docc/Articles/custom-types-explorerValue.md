# Custom types with ExplorerValue

Learn more about the back bone of the serializable ``PathExplorer``s and understand how you can use it to inject your own types when setting or adding values.


## Meet ExplorerValue

`ExplorerValue` is a type implementing the ``PathExplorer`` protocol. As it implements `Codable` too, it can be used as a `PathExplorer` as long as a coder exists for the data format. Thus, JSON, Plist and YAML `PathExplorer`s can use the `ExplorerValue` type to get simple conformance to the protocol.

That's why ``CodablePathExplorer`` is mainly a wrapper around `ExplorerValue` to provide a generic structure implementing `PathExplorer`. ``PathExplorers/Json``, ``PathExplorers/Plist`` and ``PathExplorers/Yaml`` are simply type aliases for `CodablePathExplorer`, and differs only by the generic type ``CodableFormat``.

As `ExplorerValue` conforms to `Codable`, it's possible to provide a custom `Encoder` or `Decoder` rather than using the default ones coming with the ``PathExplorers`` namespace. This allows to specify date coding strategies for example, or to support new data formats in a blink of an eye with a dedicated Encoder/Decoder.

## ExplorerValueCreatable

To take things further, it's also possible to convert any type to an `ExplorerValue` with ``ExplorerValueRepresentable``. This protocol's only requirement is a function that returns an `ExplorerValue`. This way, it's possible to set or add a value of a custom type with a `PathExplorer`.

It's worth to note that making a type conform to `Encodable` is enough to make it `ExplorerValueRepresentable` too. A value of this type will be *encoded* to an `ExplorerValue`. Thus, using the following structure:

```swift
struct Record: Codable, ExplorerValueConvertible {
    var name: String
    var score: Int
}
```

It's possible to set a `Record` value with any `PathExplorer`

```swift
let record = Record(name: "Riri", score: 20)

// plist: CodablePathExplorer<PlistFormat>
try plist.set("ducks", "records", 0, to: record)
```

> Note: Even if primitive types conform to `Encodable`, it would be less efficient to encode them. A simpler implementation for `ExplorerValueRepresentable` is provided. The same goes for an array of a primitive type and for a dictionary where `Value` is a primitive type.


## ExplorerValueCreatable

The counterpart of `ExplorerValueRepresentable` is ``ExplorerValueCreatable``. Types conforming to this protocol declare an initialization from an `ExplorerValue`. This allows to export the value of an `ExplorerValue` to the type.

> Tip: Similarly with `ExplorerValueRepresentable`, a default implementation is provided for primitive types and types conforming to `Decodable`.

With the `Record` structure from above,

```swift
struct Record: Codable, ExplorerValueConvertible {
    var name: String
    var score: Int
}
```

it's possible to try to export a value of a `PathExplorer` as an array of `Record`s with ``PathExplorer/array(of:)``

```swift
// plist: CodablePathExplorer<PlistFormat>
let records = try plist.get("Riri", "records").array(of: Record.self)
```

## ExplorerValueConvertible

``ExplorerValueConvertible`` is simply a type alias for both `ExplorerValueRepresentable` and `ExplorerValueCreatable` protocols. 
