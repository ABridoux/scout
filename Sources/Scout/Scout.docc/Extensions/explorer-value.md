# ``Scout/ExplorerValue``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

`ExplorerValue` is the back bone of serializable ``PathExplorer`` (JSON, Plist, YAML). It's the type that implements all the logic to conform to `PathExplorer`. Then ``SerializablePathExplorer`` simply interfaces it with the proper data format. Also, it's the type that is used to encode and decode to those formats.

But it also allows to use your own types to inject them in a `PathExplorer`. 

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
