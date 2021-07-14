# Mastering Paths

``Path``s are provided to a ``PathExplorer`` to navigate through or manipulate data precisely. 

## Overview

Basically, a `Path` is a collection of ``PathElement``s in a specific order. The sequence of `PathElement`s lets the explorer know what value to target next. When navigating to a value is not possible, the explorer will throw an error.

The examples in this article will refer to this json file, stored in a ``PathExplorers/Json`` value referred to as `json`. 

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
let secondHobby = try json.get(path: path).string
print(secondHobby)
// "party"
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

The following `ducks` array shows how negative indexes are handled with `PathElement.index`

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
let count = try json.get(path: path).int
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
print(tomKeys)
// ["age", "hobbies", "height"]
```

## Scope groups

When working with arrays and dictionaries, it might be useful to be able to target a specific part in the values. For instance to exclude the first and last value in an array, or to target only keys starting with a certain prefix in a dictionary.

Those features are available with ``PathElement/slice(_:)`` to slice an array and ``PathElement/filter(_:)`` to filter keys in a dictionary.

### Slice arrays

With ``PathElement/slice(_:)``, it's possible to target a contiguous part of an array. For instance to get Robert's first two hobbies.

> note: When represented as a `String`, the slice element is specified as two integers separated by a double point and enclosed by squared brackets like `[0:2]` or `[2:-4]`. When the left value is the first index, it is omitted. The same goes for the right value when it's the last valid index.

```swift
let path = Path(elements: "Robert", "hobbies", .slice(0, 1))
let robertFirstTwoHobbies = try json.get(path: path).array(of: String.self)
print(robertFirstTwoHobbies) // ["video games", "party"]
```

Similarly with the ``PathElement/index(_:)``, it's possible to use negative indexes. Here to get Suzanne last two movies' titles.
```swift
let path = Path(elements: "Suzanne", "movies", .slice(-2, -1), "title")
let titles = try json.get(path: path).array(of: String.self)
print(titles)
// ["Yesterday will never go", "What about today?"]
```

The following `ducks` array explains how positive and negative indexes are interpreted with `PathElement.slice`
```
["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
[  0   ,   1   ,    2    ,    3    ,    4   ] (Positive)
[ -5   ,  -4   ,   -3    ,   -2    ,   -1   ] (Negative)
```

- `ducks[0:2]` targets `["Riri", "Fifi", "Loulou"]`
- `ducks[2:-2]` targets `["Loulou", "Donald"]`
- `ducks[-3:-1]` targets `["Loulou", "Donald", "Daisy"]`

### Filter dictionaries

``PathElement/filter(_:)`` lets you provide a regular expression to match certain keys in a dictionary. All the keys that do not fully match the expression will be filtered.

For instance, to get all keys in Tom's dictionary that start with "h".

```swift
let path = Path(elements: "Tom", .filter("h.*"))
let filteredTom = try json.get(path: path)
print(filteredTom)
```
```json
{
  "hobbies" : [
    "cooking",
    "guitar"
  ],
  "height" : 175
}
```

Or to get Tom and Robert first hobby.

```swift
let path = Path(elements: .filter("Tom|Robert"), "hobbies", 0)
let firstHobbies = try json.get(path: path).dictionary(of: String.self)
print(firstHobbies)
// ["Tom": "cooking", "Robert": "video games"]
```

### Mixing up

It's possible to mix both array slicing and dictionary filtering in a same path. For instance to get Tom and Robert first two hobbies.

```swift
let path = Path(elements: .filter("Tom|Robert"), "hobbies", .slide(.first, 1)) 
let hobbies = try json.get(path: path)
print(hobbies)
```

```json
{
  "Tom" : [
    "cooking",
    "guitar"
  ],
  "Robert" : [
    "video games",
    "party"
  ]
}
```

## Literals and PathElementRepresentable
Using plain strings and numbers is made possible because ``PathElement`` implements `ExpressibleByStringLiteral` and `ExpressibleByIntLiteral`. But when it comes to use variables as `PathElement`, it is required to specify the element.

For instance with the first example path to target Robert's second hobby.

```swift
let robertKey = "Robert"
let hobbiesKey = "hobbies"
let hobbyIndex = 1
let path = Path(elements: .key(robertKey), .key(hobbiesKey), .index(hobbyIndex))
```

As this syntax might be a bit heavy, it's possible to use ``PathElementRepresentable`` to create the `Path` with  ``Path/init(_:)-1b2iy``. With it, the code above can be rewritten like so.

```swift
let robertKey = "Robert"
let hobbiesKey = "hobbies"
let hobbyIndex = 1
let path = Path(robertKey, hobbiesKey, hobbyIndex)
```

The drawback is that this is possible only for `PathElement.index` and `PathElement.key`. When dealing with other elements like ``PathElement/count``, it is required to specify the `PathElement` type.

```swift
Path(robertKey, hobbiesKey, PathElement.count)
```

The convenience overloads for the `PathExplorer` functions similarly works with `PathElement` and `PathElementRepresentable`. 
