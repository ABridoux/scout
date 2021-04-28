# Commands example
Use these commands with the People files in the playground.
The commands work regardless of the file format you choose with the `-i | --input` option: People.json, People.plist, People.yml or People.xml. The `--format|-f`  on the other hand is required to specify the format of the input.

**Summary**
- [Read a value](#read)
- [Set values](#set)
- [Delete values](#delete)
- [Add values](#add)
- [Listing paths](#listing-paths)
- [Export to another format](#export-to-another-format)

## Read
- Will output an error if a key in the given path does not exist. 
- A negative index can be used to subscript an array starting from the end.

 Output Tom's height: 175
```bash
scout read -i People.json -f json "Tom.height" 
```

 Output Tom's first hobby: cooking
```bash
scout read -i People.xml -f xml "Tom.hobbies[0]" 
```

 Output Tom's last hobby: guitar
```bash
scout read -i People.json -f json "Tom.hobbies[-1]"
```

 Output Suzanne first movie title: Tomorrow is so far
```bash
scout read -i People.yml -f yaml "Suzanne.movies[0].title"
```

 Output Suzanne second movie title from the end: "Yesterday will never go"
```bash
scout read -i People.yml -f yaml "Suzanne.movies[-2].title"
```
 
 Output Robert running records second record first value: 9
```bash
scout read -i People.json -f json "Robert.running_records[1][0]"
```

The following:

```bash
scout read -i People.json -f json "Tom"
```
outputs Tom dictionary:

```json
{
  "age" : 68,
  "hobbies" : [
    "cooking",
    "guitar"
  ],
  "height" : 175
}
```

### Get dictionary or array count

Get a dictionary or an array count with the `[#]` symbol.

Get people count: 3
```bash
scout read -i People.plist -f plist "[#]"
```

Get Suzanne's movies count: 3
```bash
scout read -i People.xml -f xml "Suzanne.movies[#]" 
```

### Get a dictionary keys

You can get a dictionary or an array count with the `{#}` symbol. The keys are returned as an array.

Get Tom dictionary keys list
```bash
scout read -i People.yml -f yaml "Tom{#}"
```

Useful to iterate over a dictionary with the `-e array` export option:

```bash
keys=(`scout read -i People.json -f json ”Tom{#}” —e array`)

for key in $keys;  do
	scout read -i People.json ”Tom.$key”;
done
```

### Get a group sample
#### Array slicing
- Target a slice in an array with square brackets and a double point ':' between the bounds: [lower:upper]
- The upper bound is included
- No lower means 0 like [:10] equals to [0:10]
- No upper means the last index like [10:] equals to [10:-1]
- Use a negative index target the last nth elements like [-3:] to target the last 3 elements, [:-3] to target all but the last two elements and [-4:-2] to target between the last 4th and last 2nd elements

Get Robert first two hobbies
```bash
scout read -i People.json -f json "Robert.hobbies[:1]"
```

Get Robert last two hobbies
```bash
scout read -i People.yml -f yaml "Robert.hobbies[-2:]"
```

Get Suzanne movies titles
```bash
scout read -i People.plist -f plist "Suzanne.movies[:].title"
```

#### Dictionary filtering
- Target specific keys with a regular expression by enclosing it with sharp signs: #.*device.*# to target all the keys containing the word device
- To be validated by the regular expression, the overall key has to be a match

Get Tom keys beginning by "h"
```bash
scout read -i People.json -f json "Tom.#h.*#"
```

Get Tom and Robert hobbies
```bash
scout read -i People.xml -f xml "#Tom|Robert#.hobbies"
```

#### Mixing slicing and filtering

Get Tom and Robert first two hobbies
```bash
scout read -i People.yml -f yaml "#Tom|Robert#.hobbies[:1]"
```

## Set
- Will output an error if a key in the given path does not exist.
- A negative index can be used to subscript an array starting from the end.
- You can set multiple values in one command.
- It's possible to force a type to override the automatic type inferring choice.

 Set Robert age to: 60
```bash
scout set -i People.plist -f plist "Robert.age=60"
```

 Set Suzanne second movie title to: Never gonna die
```bash
scout set -i People.yml -f yaml "Suzanne.movies[1].title=Never gonna die"
```

 Set Tom last hobby to "play music". Set Suzanne job to: comedian.
```bash
scout set -i People.plist -f plist \
"Tom.hobbies[-1]=play music" \
"Suzanne.job=comedian"
```

 Set Robert running records first record third value to: 15
```bash
scout set -i People.xml -f xml "Robert.running_records[0][2]=15"
```

 Set Tom height to the **String** value: 165
```bash
scout set -i People.json -f json "Tom.height=/165/"
```

Set Tom height to the **Real** value: 165 (only useful for Plist files)
```bash
scout set -i People.plist -f plist "Tom.height=~165~" 
```

 Set Tom height key name to "centimeters"
```bash
scout set -i People.json -f json "Tom.height=#centimeters#"
```

Set Suzanne first movie awards to an empty array
```bash
scout set -i People.yml -f yaml "Suzanne.movies[0].awards=[]"
```

Set Suzanne first movie awards to the array made of values: grammy, oscar, cesar
```bash
scout set -i People.yml -f yaml "Suzanne.movies[0].awards=[grammy, oscar, cesar]"
```

## Delete

- Will output an error if a key in the given path does not exist.
- You can delete multiple values in one command.
- A negative index can be used to subscript an array starting from the end.
- The `-r|--recursive` flag can be used to delete an array or dictionary when it is left empty (i.e. it's last value has been deleted)

 Delete Robert second hobby: party
```bash
scout delete -i People.xml -f xml "Robert.hobbies[1]"
```

 Delete Tom last hobby and Suzanne second movie awards
```bash
scout delete -i People.json -f json \
"Tom.hobbies[-1]" \
"Suzanne.movies[1].awards"
```

 Delete Robert hobbies array
```bash
scout delete -i People.yml -f yaml "Robert.hobbies"
```

 Delete all Tom hobbies and recursively the hobbies array
```bash
scout delete -ir People.plist -f plist "Tom.hobbies[1]" "Tom.hobbies[0]"
```

### Delete a group sample
#### Array slicing
- Target a slice in an array with square brackets and a double point ':' between the bounds: [lower:upper]
- The upper bound is included
- No lower means 0 like [:10] equals to [0:10]
- No upper means the last index like [10:] equals to [10:-1]
- Use a negative index target the last nth elements like [-3:] to target the last 3 elements, [:-3] to target all but the last two elements and [-4:-2] to target between the last 4th and last 2nd elements

Delete Robert first two hobbies
```bash
scout delete -i People.json -f json "Robert.hobbies[:1]"
```

Delete Robert last two hobbies
```bash
scout delete -i People.xml -f xml "Robert.hobbies[-2:]"
```

Delete Suzanne movies titles
```bash
scout delete -i People.plist -f plist "Suzanne.movies[:].title"
```

Delete Suzanne movies titles and remove the last movie element as it only as a "title" key with the `-r|--recursive` flag
```bash
scout delete -ir People.plist -f plist "Suzanne.movies[:].title"
```

#### Dictionary filtering
- Target specific keys with a regular expression by enclosing it with sharp signs: #.*device.*# to target all the keys containing the word device
- To be validated by the regular expression, the overall key has to be a match

Delete Tom keys beginning by "h"
```bash
scout delete -i People.xml -f xml "Tom.#h.*#"
```

Delete Tom and Robert hobbies
```bash
scout delete -i People.plist -f plist "#Tom|Robert#.hobbies"
```

#### Mixing slicing and filtering

Delete Tom and Robert first two hobbies
```bash
scout delete -i People.json -f json "#Tom|Robert#.hobbies[:1]"
```

Delete Tom and Robert first two hobbies and Tom hobbies key recursively
```bash
scout delete -ir People.json -f json "#Tom|Robert#.hobbies[:1]"
```

## Add
- Only when a key is the last element in the path will it be created
- When an index is the last element in the path, the new value will be inserted at the index position
- A negative index can be used to subscript an array starting from the end.
- Using the count element `[#]` after an array allows to specify that the value should be added at the end of the array 
- Multiple values can be set in one command.

 Add a surname for Robert: Bob
```bash
scout add -i People.xml -f xml "Robert.surname=Bob"
```

 Add a movie to Suzanne's movies with the title: "Never gonna die"
```bash
scout add -i People.json -f json \
"Suzanne.movies[#]={}" \
"Suzanne.movies[-1].title=Never gonna die"
```

 Add a new value at the end of the array to Robert running records second record
```bash
scout add -i People.yml -f yaml "Robert.running_records[1][#]=20"
```

Add a new record to Robert running records and add a new value into it: 15

```bash
scout add -i People.xml -f xml \
"Robert.running_records[#]=[]" \
"Robert.running_records[-1][#]=15"
```

 Add a new **String** value at the end the array to Robert running records first record
```bash
scout add -i People.plist -f plist "Robert.running_records[0][#]='15'"
```

## Listing paths
- List the paths leading to single values (e.g. strings) or group values (e.g. array) in the data. This list can be used in bash or zsh to iterate over the values in the data.
- Optionally provide an initial path from which the listed paths should start.
- Target single values with the `--single` flag, group values with the `--group` flag or both by default.
- Filter the keys that should be listed in a path with the. `-k|--key` option and a regular expression.
- Filter the value that should be listed in a path with the `v|--value` option and one or more predicates. The variable 'value' will be replaced by th A value validated by any of the predicate will be retrieved. Only the single values will be taken.

List all the paths in the data
```bash
scout paths -i People.yml -f yaml
```
will output
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

List all the paths ending with a "hobbies" key.

```bash
scout paths -i People.xml -f xml -k "hobbies"
```
will output
```
Robert.hobbies
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Tom.hobbies
Tom.hobbies[0]
Tom.hobbies[1]
```

List all the paths ending with a "hobbies" key and whose value is a single value

```bash
scout paths -i People.plist -f plist -k "hobbies" --single
```
will output
```
Robert.hobbies[0]
Robert.hobbies[1]
Robert.hobbies[2]
Tom.hobbies[0]
Tom.hobbies[1]
```

List all the paths whose value is below 70

```bash
scout paths -i People.yml -f yaml -v "value < 70"
```
will output
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

List all the paths whose value is above 20 and below 70

```bash
scout paths -i People.json -f json -v "value > 20 && value < 70"
```
will output
```
Robert.age
Tom.age
```

List all the paths whose value is below 70 and whose key start with "a"

```bash
 scout paths -i People.yml -f yaml -v "value < 70" -k "a.*"
```
will output
```
Robert.age
Tom.age
```

List all the paths in Tom dictionary

```bash
scout paths -i People.plist -f plist "Tom"
```
will output
```
Tom.age
Tom.height
Tom.hobbies
Tom.hobbies[0]
Tom.hobbies[1]
```

List all the paths in Tom and Robert dictionaries leading to group values

```bash
scout paths -i People.xml -f xml "#Tom|Robert#" --group
```
will output
```
Robert
Robert.hobbies
Robert.running_records
Robert.running_records[0]
Robert.running_records[1]
Tom
Tom.hobbies
```

List the paths leading to Suzanne first two movies titles.

```bash
scout paths -i People.yml -f yaml "Suzanne.movies[:1].title"
```
will output
```
Suzanne.movies[0].title
Suzanne.movies[1].title
```

## Export to another format
### Other format
It's possible to export the data to another format with the commands `read`, `set`, `delete`, or `add` and the `-e|--export` option.

**Note about the conversion from XML**
The conversion from XML can change the data structure when a tag has one ore more attributes. In such a case, the key will be transformed to a dictionary with two keys: "attributes" and "value". The "attribute" key will be a dictionary holding the attributes and the "value" key will hold the value of the key.

Output the file People.json as Plist
```
scout read -i People.json -f json -e plist
```
or

```
scout -i People.json -f json -e plist
```

Set a key and output the data as XML
```
scout set "Robert.age=30" -i People.yml -f yaml -e xml
```

Delete a key and output the data as JSON
```bash
scout delete "Robert.age" -i People.xml -f xml -e json
```

### CSV export
Output an array or a dictionary of arrays as CSV with the `--csv-exp` option.

Output Robbert's hobbies as CSV with the default separator.

```bash
scout read -i People.json "Robert.hobbies" --csv-exp ";"
```
will output
```
video games;party;tennis
```


### CSV import
The `csv` command will import a CSV input to JSON, Plist, YAML or XML.
A cool feature when working with named headers is that they will be treated as paths. This can shape very precisely the structure of the converted data.
For instance, the following CSV

```csv
name.first;name.last;hobbies[0];hobbies[1]
Robert;Roni;acting;driving
Suzanne;Calvin;singing;play
Tom;Cattle;surfing;watching movies
```

will be converted to the following Json structure.

```json
[
  {
    "hobbies" : [
      "acting",
      "driving"
    ],
    "name" : {
      "first" : "Robert",
      "last" : "Roni"
    }
  },
  {
    "hobbies" : [
      "singing",
      "play"
    ],
    "name" : {
      "first" : "Suzanne",
      "last" : "Calvin"
    }
  },
  {
    "name" : {
      "first" : "Tom",
      "last" : "Cattle"
    },
    "hobbies" : [
      "surfing",
      "watching movies"
    ]
  }
]
```

When there are no headers, the input will be treated as a one or two dimension(s) array.

#### Command-line
```bash
scout csv -i people.csv -s ";" -f json --headers
```

The `headers|--no-headers` flag is needed to specify whether the CSV string begins with named headers.
It’s also possible to use the standard input to provide the CSV data.