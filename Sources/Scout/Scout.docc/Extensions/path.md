# ``Scout/Path``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

Paths are the way to feed a ``PathExplorer`` to navigate through data. `PathExplorer`'s operations will often take a `Path` (or a collection of ``PathElement``s) to target precisely where to run.

Basically, a `Path` is a collection of ``PathElement``s in a specific order. The sequence of `PathElement`s lets the explorer know what value to target next. When navigating to a value is not possible, the explorer will throw an error.

## Topics

### Instantiate an empty Path

- ``init()``
- ``empty``

### Instantiate from PathElement values

- ``init(elements:)-8dch4``
- ``init(elements:)-9i64v``

### Instantiate from PathElementRepresentable values

``PathElementRepresentable`` is a protocol to erase the `PathElement` type when instantiating a `Path` with non-literal values.

- ``init(_:)-1b2iy``
- ``init(_:)-cgb7``
- ``init(arrayLiteral:)``

### Instantiate from a String

A `Path` is easily represented as a `String`, which is especially useful when working in the command-line.

- ``init(string:separator:)``
- ``defaultSeparator``
- ``parser(separator:keyForbiddenCharacters:)``

### Appending elements

`Path` conforms to several collection protocols. Additionally, those convenience functions are offered.

- ``append(_:)-9l194``
- ``appending(_:)-2ptn6``
- ``appending(_:)-3mvwq``

### Flatten a Path

When a `Path` contains special group scoping elements like ``PathElement/slice(_:)`` or ``PathElement/filter(_:)``, specifying a `PathElement.index` or `PathElement.key` will not refer to an immediate dictionary or array. The "flatten" operation will replace the slices and the filters in the `Path` with the proper values when the path is complete. Mainly used in paths listing ``PathExplorer/listPaths(startingAt:)``.

- ``flattened()``

### Map elements (Collection)

- ``Path/compactMapIndexes``
- ``Path/compactMapKeys``
- ``Path/compactMapSlices``
- ``Path/compactMapFilter``

### Compare path (Collection)

- ``Path/commonPrefix(with:)``
