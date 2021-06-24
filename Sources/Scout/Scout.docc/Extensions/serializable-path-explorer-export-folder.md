# ``Scout/SerializablePathExplorer/exportFoldedString(upTo:)``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}
### Examples

With the following JSON stored in a `SerializablePathExplorer` named `json`.

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

The following

```swift
json.exportFoldedString(upTo: 2)
```

will return the string:

```json
{
  "Suzanne" : {
    "job" : "actress",
    "movies" : [...]
  },
  "Tom" : {
    "hobbies" : [...],
    "age" : 68,
    "height" : 175
  },
  "Robert" : {
    "running_records" : [...],
    "age" : 23,
    "hobbies" : [...],
    "height" : 181
  }
}
```
