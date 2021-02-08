# Scripting recipes

Script examples using the *People* files.

Print all the (path/single value) pairs in the data.

```bash
file="~/Desktop/Playground/People.json"
scout="/usr/local/bin/scout"

paths=(`scout paths -i $file --single`)

for path in $paths; do
	echo -n "$path: "
	$scout read -i $file $path;
done
About parsing the data
```

---
Invoking scout for each path is not efficient but gives more control. With this example, it's easy to come up with many possibilities to read or modify the data. But if one value has to be set on every path, this flexibility is too expensive to use. It will be possible in Scout 3.1.0 to use "batch" functions to run the program only once when the same value has to be set on every path. Meanwhile, it's possible to build the paths and their new values to then provide them to the program, as shown in the last recipe (Suzanne's movies new titles).

---

Set all "ages" key to 30 in the file People.yml

```bash
file="~/Desktop/Playground/People.yml"
scout="/usr/local/bin/scout"

paths=(`scout paths -i $file -k "age" --single`)

for path in $paths; do
	$scout set -m $file "$path=30"
done
Print the paths leading to values lesser than 30

file="~/Desktop/Playground/People.yml"
scout="/usr/local/bin/scout"

paths=(`$scout paths -i $file -k "age" --single`)

for path in $paths; do
	value=(`$scout read -i $file $path`)

	if [ $value -lt 40 ]; then
		echo "$path"
	fi
done
```

Add a key "language" to all Suzanne's movies with the value "fr" to the file People.plist
```bash
file="~/Desktop/Playground/People.plist"
scout="/usr/local/bin/scout"

paths=(`$scout paths -i $file "Suzanne.movies[:]" --group`)

for path in $paths; do
	$scout add -m $file "$path.language=fr"
done
```

Add a key "awards" with a default value if not present in Suzanne's movies array.
```bash
file="~/Desktop/Playground/People.xml"
scout="/usr/local/bin/scout"

paths=(`$scout paths -i $file "Suzanne.movies[:]" --group`)

for path in $paths; do
	if value=$($scout read -i $file "$path.awards" 2>/dev/null) ; then
		echo "'awards' key found in $path with value '$value'"
	else
		$scout add -m $file "$path.awards=No awards"
	fi
done

```

Set Suzanne movies's title to new ones in the file People.plist
```bash
file="~/Desktop/Playground/People.plist"
scout="/usr/local/bin/scout"

paths=(`$scout paths -i $file "Suzanne.movies[:].title"`)
newTitles=("I was tomorrow"  "I'll be yesterday" "I live in the past future")

for ((i=0; i < ${#newTitles[@]} ; i++)); do
	newTitle=${newTitles[$i+1]}
	path=${paths[$i+1]}

	$scout set -m $file "$path=$newTitle"
done
```

Same as above but call scout only once to set the new titles.
```bash
file="~/Desktop/Playground/People.plist"
scout="/usr/local/bin/scout"

paths=(`$scout paths -i $file "Suzanne.movies[:].title"`)
newTitles=("I was tomorrow"  "I'll be yesterday" "I live in the past future")
pathsAndNewTitles=""

for ((i=0; i < ${#newTitles[@]} ; i++)); do
	newTitle=${newTitles[$i+1]}
	path=${paths[$i+1]}
	pathsAndNewTitles="$pathsAndNewTitles '$path=$newTitle'"
done

$scout set -m $file "$path=$newTitle"
```