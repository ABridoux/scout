# Commands example
Use these commands with the People files in the playground.
The commands work regardless of the file format you choose with the `-i | --input` option: People.json, People.plist, or People.xml.

## Get
- Will output an error if a key in the given path does not exist. 

 Output Tom's height: 175
```bash
scout read "people.Tom.height" -i People.json
```

 Output Tom's last hobby: guitar
```bash
scout read "people.Tom.hobbies[-1]" -i People.json
```

 Output Tom's first hobby: cooking
```bash
scout read "people.Tom.hobbies[1]" -i People.json
```

 Output Suzanne first movie title: Tomorrow is so far
```bash
scout read "people.Suzanne.movies[0].title" -i People.xml
```
 
 Output Robert running records second record first value
```bash
scout read "people.Robert.running_records[1][0]" -i People.json
```

The following:

```bash
scout read "people.Tom" -i People.json
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

You can get a dictionary or an array count with the `[#]` symbol.

Get people count: 3
```bash
scout read "people[#]" -i People.plist
```

Get Suzanne's movies count: 3
```bash
scout read "people.Suzanne.movies[#]" -i People.xml
```

### Get a group sample
#### Array slicing
- Target a slice in an array with square brackets and a double point ':' between the bounds: [lower:upper]
- No lower means 0 like [:10] equals to [0:10]
- No upper means the last index like [10:] equals to [10:-1]
- Use a negative index for the lower bound to target the last nth elements like [-4:] to target the last 4 elements

Get Robert first two hobbies
```bash
scout read -i People.json "people.Robert.hobbies[:1]"
```

Get Robert last two hobbies
```bash
scout read -i People.json "people.Robert.hobbies[-2:]"
```

Get Suzanne movies titles
```bash
scout read -i People.plist "people.Suzanne.movies[:].title"
```

#### Dictionary filtering
- Target specific keys with a regular expression by enclosing it with sharp signs: #.*device.*# to target all the keys containing the word device
- To be validated by the regular expression, the overall key has to be a match

Get Tom keys beginning by "h"
```bash
scout read -i People.json "people.Tom.#h.*#"
```

Get Tom and Robert hobbies
```bash
scout read -i People.xml "people.#Tom|Robert#.hobbies"
```

#### Mixing slicing and filtering

Get Tom and Robert first two hobbies
```bash
scout read -i People.xml "people.#Tom|Robert#.hobbies[:1]"
```


## Set
- Will output an error if a key in the given path does not exist.
- You can set multiple values in one command.
- The `-v` flag is specified to let you see the modified data.

 Set Robert age to: 60
```bash
scout set "people.Robert.age"=60 -i People.plist -v
```

 Set Suzanne second movie title to: Never gonna die
```bash
scout set "people.Suzanne.movies[1].title"="Never gonna die" -iv People.json
```

 Set Tom last hobby to "play music". Set Suzanne job to: comedian.
```bash
scout set \
"people.Tom.hobbies[-1]"="playing music" \
"people.Suzanne.job=comedian" \
-iv People.plist
```

 Set Robert running records first record third value to: 15
```bash
scout set "people.Robert.running_records[0][2]"=15 -i People.xml -v
```

 Set Tom height to the **String** value: 165
```bash
scout set "people.Tom.height=/165/" -iv People.json
```

Set Tom height to the **Real** value: 165 (only useful for Plist files, as Json does not care about integer/real and Xml has only string values)
```bash
scout set "people.Tom.height=~165~" -iv People.plist
```

 Set Tom height key name to "centimeters"
```bash
scout set "people.Tom.height=#centimeters#" -i People.json -v
```


## Delete

- Will output an error if a key in the given path does not exist.
- You can delete multiple values in one command.
- The `-v` flag is specified to let you see the modified data.

 Delete Robert second hobby
```bash
scout delete "people.Robert.hobbies[1]" -i People.xml -v
```
 Delete Tom last hobby and Suzanne second movie awards
```bash
scout delete \
"people.Tom.hobbies[-1]" \
"people.Suzanne.movies[1].awards" \
-I People.json -v
```

 Delete Robert hobbies array
```bash
scout delete "people.Robert.hobbies" -i People.plist -v
```

 Delete Robert running records first record third value
```bash
scout delete "people.Robert.running_records[0][2]" -i People.plist -v
```

### Get a group sample
#### Array slicing
- Target a slice in an array with square brackets and a double point ':' between the bounds: [lower:upper]
- No lower means 0 like [:10] equals to [0:10]
- No upper means the last index like [10:] equals to [10:-1]
- Use a negative index for the lower bound to target the last nth elements like [-4:] to target the last 4 elements

Delete Robert first two hobbies
```bash
scout delete -iv People.json "people.Robert.hobbies[:1]"
```

Delete Robert last two hobbies
```bash
scout delete -iv People.xml "people.Robert.hobbies[-2:]"
```

Delete Suzanne movies titles
```bash
scout delete -iv People.plist "people.Suzanne.movies[:].title"
```

Delete Suzanne movies titles and remove the last movie element as it only as a "title" key with the `-r|--recursive` flag
```bash
scout delete -ivr People.json "people.Suzanne.movies[:].title"
```

#### Dictionary filtering
- Target specific keys with a regular expression by enclosing it with sharp signs: #.*device.*# to target all the keys containing the word device
- To be validated by the regular expression, the overall key has to be a match

Delete Tom keys beginning by "h"
```bash
scout delete -iv People.xml "people.Tom.#h.*#"
```

Delete Tom and Robert hobbies
```bash
scout delete -iv People.plist "people.#Tom|Robert#.hobbies"
```

#### Mixing slicing and filtering

Delete Tom and Robert first two hobbies
```bash
scout delete -iv People.json "people.#Tom|Robert#.hobbies[:1]"
```

Delete Tom and Robert first two hobbies and Tom hobbies key recursively
```bash
scout delete -ivr People.json "people.#Tom|Robert#.hobbies[:1]"
```

## Add
- If a key in the given path does not exist, it will be created. Thus, to add a dictionary or an array, you have to specify one child key. Otherwise scout will consider that it is a single value which should be added.
- That said, using the index `-1` to specify the end of an array with the `add` command will make the program add a new key rather than read the last value of the array (like it does for the other commands). 
- You can set multiple values in one command.
-  The `-v` flag is specified to let you see the modified data.

 Add a surname for Robert: Bob
```bash
scout add "people.Robert.surname"=Bob -i People.xml -v
```

 Add a movie to Suzanne's movies with the title: Never gonna die
```bash
scout add "people.Suzanne.movies[-1].title"="Never gonna die" -i People.json -v
```

 Add a new secret loves array for Suzanne with one element: Candies. Add a new surname for Robert: Bob. Add a new hobby for Tom at the end of the hobbies array: sleeping.
```bash
scout add \
"people.Suzanne.secretLoves[0]"=Candies \
"people.Robert.surname"=Bob \
"people.Tom.hobbies[-1]"=sleeping \
-i People.plist -v
```

 Add a new value at the end of the array to Robert running records second record
```bash
scout add "people.Robert.running_records[1][-1]"=20 -i People.json -v
```

 (Tricky one) Add a new record to Robert running records and add a new value into it: 15

```bash
scout add "people.Robert.running_records[-1][0]"=15 -i People.xml -v
```

 Add a new **String** value at the end the array to Robert running records first record
```bash
scout add "people.Robert.running_records[0][-1]=/15/" -i People.plist -v
```