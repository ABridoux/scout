# Commands example
Use these commands with the People files in the playground.
The commands work regardless of the file format you choose with the `-i | --input` option: People.json, People.plist, or People.xml.

## Get
Will output an error if a key in the given path does not exist. 

##### Output Tom's height: 175
```bash
scout "people.Tom.height" -i People.json
```

##### Output Tom's last hobby: guitar
```bash
scout "people.Tom.hobbies[-1]" -i People.json
```

##### Output Tom's first hobby: cooking
```bash
scout "people.Tom.hobbies[1]" -i People.json
```

##### Output Suzanne first movie title: Tomorrow is so far
```bash
scout "people.Suzanne.movies[0].title" -i People.xml
```

## Set
Will output an error if a key in the given path does not exist. You can set multiple value in one command. The `-v` flag is specified to let you see the modified data.

##### Set Robert age to: 60
```bash
scout set "people.Robert.age"=60 -i People.plist -v
```

##### Set Suzanne second movie title to: Never gonna die
```bash
scout set "people.Suzanne.movies[1].title"="Never gonna die" -i People.json -v
```

##### Set Tom last hobby to: play music. Set Suzanne job to: comedian.
```bash
scout set \
"people.Tom.hobbies[-1]"="playing music" \
"people.Suzanne.job"="comedian" \
-i People.plist -v
```

## Delete

##### Delete Robert second hobby
Will output an error if a key in the given path does not exist. The `-v` flag is specified to let you see the modified data.

```bash
scout delete "people.Robert.hobbies[1]" -i People.xml -v
```
##### Delete Tom last hobby and Suzanne second movie awards
```bash
scout delete \
"people.Tom.hobbies[-1]" \
"people.Suzanne.movies[1].awards" \
-I People.json -v
```

##### Delete Robert hobbies array
```bash
scout delete "people.Robert.hobbies" -i People.plist -v
```

## Add
If a key in the given path does not exist, it will be created. Thus, to add a dictionary or an array, you have to specify one child key. Otherwise scout will consider that it is a single value which should be added. You can set multiple value in one command. The `-v` flag is specified to let you see the modified data.

##### Add a surname for Robert: Bob
```bash
scout add "people.Robert.surname"=Bob -i People.xml -v
```

##### Add a movie to Suzanne's movie with the title: Never gonna die
```bash
scout add "people.Suzanne.movies[-1].title"="Never gonna die" -i People.json -v
```

##### Add a new secret loves array for Suzanne with one element: Candies. Add a new surname for Robert: Bob. Add a new hobby for Tom at the end of the hobbies array: sleeping.
```bash
scout add \
"people.Suzanne.secretLoves[0]"=Candies \
"people.Robert.surname"=Bob \
"people.Tom.hobbies[-1]"=sleeping \
-i People.plist -v
```
