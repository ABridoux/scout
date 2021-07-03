# Paths listing

`PathExplorer` list path features is useful to get all paths leading to a value or a key.

## Overview

In this article, learn how to use the paths listing feature to precisely get the paths you want.


The examples will refer to the following JSON file.

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
      [ 9,
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

The reference to the JSON will be held by a ``PathExplorers/Json`` value.

```swift
let json = try PathExplorers.Json(data: data)
```

## Basics

Let's first see how we can list *all* the path in the file. The command

```swift
print(json.listPaths())
```
should output
```
Robert
Robert.age
Robert.height
Robert.hobbies
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Robert.running_records
Robert.running_records[0]
Robert.running_records[0][0]
Robert.running_records[0][1]
Robert.running_records[0][2]
Robert.running_records[0][3]
Robert.running_records[1]
Robert.running_records[1][0]
Robert.running_records[1][1]
Robert.running_records[1][2]
Suzanne
Suzanne.job
Suzanne.movies
Suzanne.movies[0]
Suzanne.movies[0].awards
Suzanne.movies[0].title
Suzanne.movies[1]
Suzanne.movies[1].awards
Suzanne.movies[1].title
Suzanne.movies[2]
Suzanne.movies[2].title
Tom
Tom.age
Tom.height
Tom.hobbies
Tom.hobbies[0]
Tom.hobbies[1]
```

> Note: A `Path` is more clearly represented as a `String` with a separator (default is `'.'`). That's what you get by calling `path.description`. It's also the way paths are outputted in the terminal when using the `scout` command-line tool.

## Single and group values

It's possible to target only single values (e.g. string, number...), group values (e.g. array, dictionary) or both using a ``PathsFilter``.
The default target is both single and group.

For instance, to target only single values.
```swift
let path = json.listPaths(
    filter: .targetOnly(.single)
)
print(paths)
```

output:
```
Robert.age
Robert.height
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Robert.running_records[0][0]
Robert.running_records[0][1]
Robert.running_records[0][2]
Robert.running_records[0][3]
Robert.running_records[1][0]
Robert.running_records[1][1]
Robert.running_records[1][2]
Suzanne.job
Suzanne.movies[0].awards
Suzanne.movies[0].title
Suzanne.movies[1].awards
Suzanne.movies[1].title
Suzanne.movies[2].title
Tom.age
Tom.height
Tom.hobbies[0]
Tom.hobbies[1]
```

Similarly, to target only group values.
```swift
let path = json.listPaths(
    filter: .targetOnly(.group)
)
print(paths)
```

outputs:
```
Robert
Robert.hobbies
Robert.running_records
Robert.running_records[0]
Robert.running_records[1]
Suzanne
Suzanne.movies
Suzanne.movies[0]
Suzanne.movies[1]
Suzanne.movies[2]
Tom
Tom.hobbies
```

## Initial path

To avoid listing all paths meeting the requirements, it's possible to target paths having a prefix ``PathExplorer/listPaths(startingAt:)``.

For instance to target only paths in the "Robert" dictionary".
```swift
let path = json.listPaths(
    startingAt: "Robert"
)
print(paths)
```

outputs:
```
Robert.age
Robert.height
Robert.hobbies
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Robert.running_records
Robert.running_records[0]
Robert.running_records[0][0]
Robert.running_records[0][1]
Robert.running_records[0][2]
Robert.running_records[0][3]
Robert.running_records[1]
Robert.running_records[1][0]
Robert.running_records[1][1]
Robert.running_records[1][2]
```

Do note that it's possible to use any ``PathElement`` in the provided initial path.

For instance to target paths in the Robert *or* Tom dictionaries.

```swift
let path = json.listPaths(
    startingAt: .filter("Robert|Tom")
)
print(paths)
```

outputs:
```
Robert
Robert.age
Robert.height
Robert.hobbies
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Robert.running_records
Robert.running_records[0]
Robert.running_records[0][0]
Robert.running_records[0][1]
Robert.running_records[0][2]
Robert.running_records[0][3]
Robert.running_records[1]
Robert.running_records[1][0]
Robert.running_records[1][1]
Robert.running_records[1][2]
Tom
Tom.age
Tom.height
Tom.hobbies
Tom.hobbies[0]
Tom.hobbies[1]
```

A last example with paths leading to Suzanne's movies titles.

```swift
let path = json.listPaths(
    startingAt: "Suzanne", "movies", .slice(.first, .last), "title"
)
print(paths)
```

outputs:
```
Suzanne.movies[0].title
Suzanne.movies[1].title
Suzanne.movies[2].title
```

## Filter keys

It's possible to provide a regular expression to filter the paths final key. Only the paths that contain a key validated by the regular expression will be retrieved. It's required to provide a `NSRegularExpression`. Meanwhile, the convenience initialiser ``PathsFilter/key(pattern:target:)`` takes a `String` pattern and tries to convert to a `NSRegularExpression.` 

List all the paths leading to a key "hobbies".

```swift
let path = try json.listPaths(
    filter: .key(pattern: "hobbies")
)
print(paths)
```

outputs:
```
Robert.hobbies
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Tom.hobbies
Tom.hobbies[0]
Tom.hobbies[1]
```

List all the paths leading to a key starting with "h".

```swift
let path = try json.listPaths(
    filter: .key(pattern: "h.*")
)
print(paths)
```

outputs:
```
Robert.height
Robert.hobbies
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Tom.height
Tom.hobbies
Tom.hobbies[0]
Tom.hobbies[1]
```

## Filter values

The values can be filtered with one ore more predicates with ``PathsFilter/value(_:)``. When such a filter is specified, only the single values are targeted.
A path whose value is validated by one of the provided predicates is retrieved.

> note: Two kinds of predicates are offered: ``PathsFilter/ExpressionPredicate`` that takes a `String` boolean expression and ``PathsFilter/FunctionPredicate`` that takes a function to filter the values. Both implement the ``ValuePredicate`` protocol.

List the paths leading to a value below 70 with a ``PathsFilter/FunctionPredicate``

```swift
let predicate = PathsFilter.FunctionPredicate { value in
    switch value {
        case let .int(int):
            return int < 70
        case let .double(double):
            return double < 70
        default:
            return false // ignore other values
    }
}

let path = try json.listPaths(
    filter: .value(predicate)
)
print(paths)
```

outputs:
```
Robert.age
Robert.running_records[0][0]
Robert.running_records[0][1]
Robert.running_records[0][2]
Robert.running_records[0][3]
Robert.running_records[1][0]
Robert.running_records[1][1]
Robert.running_records[1][2]
Tom.age
```

> note: Returning false or throwing an error when the ``ExplorerValue`` parameter has not a proper type for the predicate depends on your needs.

To mention it once, the  ``PathsFilter/ExpressionPredicate`` is used with a `String` boolean expression. If it's mainly used for the command-line tool, it's possible to use in Swift. The code above could be written like so 

```swift
let path = try json.listPaths(
    filter: .value("value < 70")
)
```

The name 'value' is used to specify the value that will be filtered, and is replaced by the value to evaluate at runtime by Scout.

It's possible to specify several predicates. Doing so, a value will be validated as long as one predicate validates it.

For instance to get string values starting with 'guit' *and* values that are greater than 20.

```swift
let prefixPredicate = PathsFilter.FunctionPredicate { value in
    guard case let .string(string) = value else { return false }
    return string.hasPrefix("guit")
}

let comparisonPredicate = PathsFilter.FunctionPredicate { value in
    guard case let .int(int) = value else { return false }
    return int > 20
}

let paths = try json.listPaths(
    filter: .value(prefixPredicate, comparisonPredicate)
)
```

outputs:

```
Robert.age
Robert.height
Tom.age
Tom.height
Tom.hobbies[1]
```

## Mixing up

Finally, it's worthing noting that all features to filter paths can be mixed up.

For instance to list paths leading to Robert hobbies that contain the word "game".

```swift
let gamePredicate = PathsFilter.FunctionPredicate { value in
    guard case let .string(string) = value else { return false }
    return string.contains("games")
}

let paths = try json.listPaths(
    startingAt: "Robert", "hobbies",
    filter: .value(gamePredicate)
)
```

outputs:

```
Robert.hobbies[0]
```

List paths leading to Robert or Tom hobbies arrays (group values).

```swift
let paths = try json.listPaths(
    startingAt: .filter("Tom|Robert"),
    filter: .key(pattern: "hobbies", target: .group)
)
```

outputs:
```
Robert.hobbies
Tom.hobbies
```
