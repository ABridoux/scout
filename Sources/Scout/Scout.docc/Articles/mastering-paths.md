# Mastering Paths

``Path``s are provided to a ``PathExplorer`` to navigate through or manipulate data precisely. 

## Overview

Basically, a `Path` is a collection of ``PathElement``s in a specific order. The sequence of `PathElement`s lets the explorer know what value to target next. When navigating to a value is not possible, the explorer will throw an error.

The examples in this article will refer to this json file, stored in a ``PathExplorers/Json`` value referred to as `json`. To learn more about 

> Note: The full "People" files are used to try Scout and can be found in the Playground folder.

```json
{
  "Tom" : {
    "age" : 68,
    "hobbies" : [
      "cooking",
      "guitar"
    ],
    "height" : 175
  },
  "Robert" : {
    "age" : 23,
    "hobbies" : [
      "video games",
      "party",
      "tennis"
    ],
    "running_records" : [
      [
        10,
        12,
        9,
        10
      ],
      [
        9,
        12,
        11
      ]
    ],
    "height" : 181
  },
  "Suzanne" : {
    "job" : "actress",
    "movies" : [
      {
        "title" : "Tomorrow is so far",
        "awards" : "Best speech for a silent movie"
      },
      {
        "title" : "Yesterday will never go",
        "awards" : "Best title"
      },
      {
        "title" : "What about today?"
      }
    ]
  }
}
```


## Basics

The simplest `PathElement`s are ``PathElement/key(_:)`` and ``PathElement/index(_:)``. As their name suggest, they are used to target a key in a dictionary or an index in an array.

A `Path` can be instantiated from `PathElement`s in an array or as variadic parameters. Then the path can be provided to the `PathExplorer` to read or modify a value. Here are some examples with variadic parameters.

- Make a `Path` targeting Robert's second hobby
```swift
let path = Path(elements: "Robert", "hobbies", 1)
let firstHobby = try json.get(path: path).string
print(firstHobby) // "party"
```

> The `PathExplorer` functions always offer convenience versions to use `PathElement` directly. This is useful to avoid creating a `Path` when it does not already exist or when having a more "scripting" approach.

- Make a `Path` targeting Suzanne's first movie title
```swift
Path(elements: "Suzanne", "movies", 0, "title")
```

With indexes, it's possible to use negative numbers to target indexes *from the end* of the array.
For instance to target Suzanne's last movie:

```swift
Path(elements: "Suzanne", "movies", -1)
```

The following figure shows how negative indexes are handled.

```
["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
[  0   ,   1   ,    2    ,    3    ,    4   ] (Positive)
[ -5   ,  -4   ,   -3    ,   -2    ,   -1   ] (Negative)
```

- `ducks[1]` targets "Fifi"
- `ducks[-2`] targets "Donald"

## Group informations

### Count

Scout offers to get a dictionary or array count with ``PathElement/count``. This element has to be placed when the value is an array or dictionary. The returned `PathExplorer` will be a int single value.

For instance, to get Robert's hobbies count.
```swift
let path = Path(elements: "Robert", "hobbies", .count)
let count = try json.get(path: path).count
print(count) // 3
```

Similarly, to read the keys count in the overall dictionary, the following Path can be used.
```swift
Path(elements: .count)
```

### List keys

Another useful feature is to list all the keys in a dictionary. To do so, the ``PathElement/keysList`` can be used. 
For instance, to list Tom's keys:
```swift
let path = Path(elements: "Tom", .keysList)
let tomKeys = try json.get(path: path).array(of: String.self)
print(tomKeys) // ["age", "hobbies", "height"]
```

## Scope groups


## Literals and PathElementRepresentable
Using plain strings, numbers and booleans is made possible because ``PathElement`` implements `ExpressibleByStringLiteral` and `ExpressibleByIntLiteral`. When it comes to use variables as `PathElement`, it is required to specify the element.

For instance with the first example path to target Robert's second hobby.

```swift
let firstKey = "Robert"
let secondKey = "hobbies"
let firstIndex = 1
let path = Path(elements: [.key(firstKey), .key(secondKey), .index(firstIndex)])
```

As this syntax might be a bit heavy, it's possible to use ``PathElementRepresentable`` to create the `Path` with  ``Path/init(_:)-1b2iy``. With it, the code above can be rewritten like so.

```swift
let firstKey = "Robert"
let secondKey = "hobbies"
let firstIndex = 1
let path = Path(firstKey, secondKey, firstIndex)
```

The drawback is that this is possible only for `PathElement.index` and `PathElement.key`. When dealing with other elements like ``PathElement/count``, it is required to specify the `PathElement` type.
