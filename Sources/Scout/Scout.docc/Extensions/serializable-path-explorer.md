# ``Scout/SerializablePathExplorer``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

Protocol refining ``PathExplorer`` to offer features like conversion to another format or serialization. Explorers in ``PathExplorers`` implement this protocol.

## Topics

### Initializers

- ``init(data:)``
- ``fromCSV(string:separator:hasHeaders:)``

### Get format info

- ``format``

### Export as Data

- ``exportData()``
- ``exportData(to:)``
- ``exportData(to:rootName:)``

### Export as String

- ``exportString()``
- ``exportString(to:)``
- ``exportString(to:rootName:)``

### Export as CSV

- ``exportCSV()``
- ``exportCSV(separator:)``

### Export folded String

- ``exportFoldedString(upTo:)``
- ``folded(upTo:)``
