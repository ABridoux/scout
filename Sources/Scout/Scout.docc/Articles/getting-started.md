# Getting started with Scout

Quickly learn how to use Scout's features.

## Overview
Scout uses types conforming to the protocols ``PathExplorer`` and ``SerializablePathExplorer`` to read and manipulate data. If it's possible to define your own types conforming to those protocols, it's also possible to use default implementations if they suit your needs. Those explorers can be found in ``PathExplorers`` and will be used for the examples in this article.

The provided examples will reference this "People" file (here as YAML).

> Note: The "People" files can be  found in the Playground folder.

```yaml
Robert:
  age: 23
  height: 181
  hobbies:
  - video games
  - party
  - tennis
  running_records:
  - - 10
    - 12
    - 9
    - 10
  - - 9
    - 12
    - 11
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

## Read data

The simplest way to read data in any of the supported format is to use one of the ``PathExplorers`` implementation.
For instance, let's imagine that the file is read and converted to a `Data` value. Here's how to make an explorer for the YAML format, using ``SerializablePathExplorer/init(data:)``

```swift
let yaml = try PathExplorers.Yaml(data: data)
```

It's then possible to use the ``PathExplorer/get(_:)-6pa9h`` method to read the "height" value in the "Tom" dictionary.

```swift
let tomHeightYaml = try yaml.get("Tom", "height")
```

This will return a new `PathExplorers.Yaml`. That's the logic of Scout: when reading, setting, deleting or adding values in a `PathExplorer`, the returned value will be another `PathExplorer`. This allows to keep performing operation easily. When the explorer has the right value, use the several options to access its value. For instance here to get Tom's height as a `Double`

```swift
let tomHeight = tomHeightYaml.double
// tomHeight: Double?
```
