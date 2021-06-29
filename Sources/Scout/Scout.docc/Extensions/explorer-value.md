# ``Scout/ExplorerValue``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

`ExplorerValue` is the back bone of serializable ``PathExplorer`` (JSON, Plist, YAML). It's the type that implements all the logic to conform to `PathExplorer`. Then ``CodablePathExplorer`` simply interfaces it with the proper data format to conform to ``SerializablePathExplorer``. Also, it's the type that is used to encode and decode to those formats.

But it also allows to use your own types to inject them in a `PathExplorer`. Read more with <doc:custom-types-explorerValue>
