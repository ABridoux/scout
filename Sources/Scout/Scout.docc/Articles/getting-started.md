# Getting started with Scout

Quickly learn how to use Scout's features.

## Overview
Scout uses types conforming to the protocols ``PathExplorer`` and ``SerializablePathExplorer`` to read and manipulate data. If it's possible to define your own types conforming to those protocols, it's also possible to use default implementations if they suit your needs. Those explorers can be found in ``PathExplorers`` and will be used for the examples in this article.

The provided examples will reference this "People" file (here as YAML).

> Note: The full "People" files are used to try Scout and can be found in the Playground folder.

```yaml
Robert:
  age: 23
  height: 181
  hobbies:
  - video games
  - party
  - tennis
Suzanne:
  job: actress
  movies:
  - awards: Best speech for a silent movie
    title: Tomorrow is so far
  - awards: Best title
    title: Yesterday will never go
  - title: What about today?
Tom:
  age: 68
  height: 175
  hobbies:
  - cooking
  - guitar
```

## Create a PathExplorer

The simplest way to read data in any of the supported format is to use one of the ``PathExplorers`` implementation and to call ``SerializablePathExplorer/init(data:)``.

For instance, let's imagine that the file is read and converted to a `Data` value. Here's how to make an explorer for the YAML format.

```swift
let yaml = try PathExplorers.Yaml(data: data)
```

Similarly, if the format was Plist:

```swift
let plist = try PathExplorers.Plist(data: data)
```

## Navigate through data

It's then possible to use the ``PathExplorer/get(_:)-2ghf1`` method to read the "height" value in the "Tom" dictionary.

```swift
let tomHeightYaml = try yaml.get("Tom", "height")
```

This will return a new `PathExplorers.Yaml`. That's the logic of Scout: when reading, setting, deleting or adding values in a `PathExplorer`, the returned value will be another `PathExplorer`. This allows to keep performing operation easily. When the explorer has the right value, use one of the several options to access its value. For instance here to get Tom's height as a `Double`

```swift
let tomHeight = tomHeightYaml.double
// tomHeight: Double?
```
More concisely, if you are only interested into getting Tom's height, you could write

```swift
let tomHeight = try yaml.get("Tom", "height").double
```

> Note: As you might have noticed, calling `get()` can throw an error. This is the case for most `PathExplorer` functions. Whenever an element in the provided path does not exist, for instance an index out of bounds, or a missing key, a relevant error will be thrown.

As a last example, here's how to read Robert first hobby inside an array:

```swift
let robertFirstHobby = try yaml.get("Robert", "hobbies", 0)
```

> Tip: Use negative indexes to specify an index from the *end* of the array.

To lean more about ``Path``s and how they can help you targeting specific pieces of data, you can read <doc:mastering-paths>.

## Manipulate data

Using the same logic, it's possible to set, delete or add values.

For instance, to set Robert's age to 45 with the ``PathExplorer/set(_:to:)-9d877`` function:

```swift
var yaml = try PathExplorers.Yaml(data: data)
try yaml.set("Robert", "age", to: 45)
```

Or to add a new key named "score" with a value of 25 to Tom's dictionary with the ``PathExplorer/add(_:at:)-2kii6`` function:

```swift
var yaml = try PathExplorers.Yaml(data: data)
try yaml.add(25, at: "Tom", "score")
```

Those modifications all have specificities, like the "delete" one that can also delete an array or dictionary when left empty. To get more information about those features, please refer to ``PathExplorer``.

Also, it's worth mentioning that there are counterparts of those functions that will rather return a modified copy of the explorer. This is useful to chain operations.

For instance, to set Tom's height to 160, add a new surname key to Robert's dictionary and remove Suzanne second movie: 
```swift
let yaml = try PathExplorers.Yaml(data: data)
let result = yaml
    .setting("Tom", "height", to: 160)
    .adding("Bob", to: "Robert", "surname")
    .deleting("Suzanne", "movies", 1)
```

> Note: Using plain strings, numbers and booleans is made possible because ``PathElement`` implements `ExpressibleByStringLiteral` and `ExpressibleByIntLiteral`.


## Export the results

If ``PathExplorer`` is used to navigate through data, the protocol ``SerializablePathExplorer`` refines it to offer import and export options.

Once you are satisfied with the resulting `SerializablePathExplorer` - regardless of the operations you performed - it's possible to export the explorer as a `Data` value or to another format.
To export it to a `Data` value, use ``SerializablePathExplorer/exportData()`` function.

When needed, it's possible to specify another format when exporting: for instance, if a plist was decoded from a file and has to be converted to a JSON format. See ``SerializablePathExplorer/exportData(to:)`` for more informations.

Similarly, other export features are available like export to a `String` or to a CSV string.
