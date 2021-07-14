# ``Scout/PathExplorer``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

Unifies the operations that can be performed with an explorer.

## Topics

### Initializers

An explorer takes an ``ExplorerValue`` to be instantiated.

- ``init(value:name:)``
- ``init(value:)``

### Accessing read values

- ``string``
- ``int``
- ``double``
- ``bool``
- ``data``
- ``date``
- ``array(of:)``
- ``dictionary(of:)``

### Singularity

- ``isSingle``
- ``isGroup``

### Reading values

All functions perform the same operation but offer to work with an array, variadic parameters or a ``Path``.

- ``get(_:)-8vyte``
- ``get(_:)-6pa9h``
- ``get(_:)-2ghf1``

### Setting values

All functions perform the same operation but offer to work with an array, variadic parameters or a ``Path``.

- ``set(_:to:)-5fgny``
- ``set(_:to:)-6yk0i``
- ``set(_:to:)-9d877``
- ``set(_:to:)-376n0``

### Setting values in a new explorer

The "setting" functions are the counterpart of the "set" ones, but will return a new explorer rather than modify it.

- ``setting(_:to:)-7q3g``
- ``setting(_:to:)-9vtr8``
- ``setting(_:to:)-5tdzy``
- ``setting(_:to:)-n2ij``

### Setting key names

All functions perform the same operation but offer to work with an array, variadic parameters or a ``Path``.

- ``set(_:keyNameTo:)-9i6hd``
- ``set(_:keyNameTo:)-5j60r``
- ``set(_:keyNameTo:)-1zwfv``

### Settings key names in a new explorer

The "setting key name" functions are the counterpart of the "set" ones, but will return a new explorer rather than modify it.

- ``setting(_:keyNameTo:)-7ar89``
- ``setting(_:keyNameTo:)-1vrh``
- ``setting(_:keyNameTo:)-1fmyp``

### Deleting values

All functions perform the same operation but offer to work with an array, variadic parameters or a ``Path``.

- ``delete(_:deleteIfEmpty:)-g45f``
- ``delete(_:)``
- ``delete(_:deleteIfEmpty:)-40w9g``
- ``delete(_:deleteIfEmpty:)-2uxwq``

### Deleting values in a new explorer

The "deleting" functions are the counterpart of the "set" ones, but will return a new explorer rather than modify it.

- ``deleting(_:deleteIfEmpty:)-32ufs``
- ``deleting(_:deleteIfEmpty:)-1byw9``
- ``deleting(_:deleteIfEmpty:)-2u4ud``

### Adding values

All functions perform the same operation but offer to work with an array, variadic parameters or a ``Path``.

- ``add(_:at:)-861h4``
- ``add(_:at:)-6wo3i``
- ``add(_:at:)-2kii6``
- ``add(_:at:)-2zxor``

### Adding values in a new explorer

The "adding" functions are the counterpart of the "set" ones, but will return a new explorer rather than modify it.

- ``adding(_:at:)-7fd9c``
- ``adding(_:at:)-4ju9b``
- ``adding(_:at:)-68mxp``
- ``adding(_:at:)-5uv86``

### Listing paths

List paths listing to keys based on regular expression or values based on filters.

- ``listPaths(startingAt:filter:)-4tkeq``
- ``listPaths(startingAt:)``
- ``listPaths(startingAt:filter:)-8y0x2``


### Deprecated

- ``real``
