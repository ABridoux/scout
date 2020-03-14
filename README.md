# Scout

This library aims to make specifc formats data values reading and writing simple. 
It was inspired by [SwiftyJson](https://github.com/SwiftyJSON/SwiftyJSON) and all the project that followed, while trying to cover more ground, like Xml or Plist. It unifies writing and reading for those different formats. Getting a value in a Json format would be the same as getting a value in a Xml format.

## Why?

With the libraries to encode/decode Json and Plist, one could ask: why would someone need `Scout`? Simple anwser: there is still cases where you do not know the data format. Sometimes, you will just want to read a single value from a Plist file, and you do not want to create the the `struct` to decode this file. Or you simply cannot know in advance the data format.

## Context
I have been working with many Mac admins recently, and many had to deal with Json, Plist and Xml data format. While some where using a format-specific library like [jq](https://stedolan.github.io/jq/) to parse Json, others where using `awk`.  Each approach is valid, though it comes with some compromises.

### Using a format-specic library
You can use a library for each format. But I am not aware today of a library that unifies all of them. So, hat you learnt with [jq](https://stedolan.github.io/jq/) cannot be reused to parse Plist data. You would have to learn to use `PlistBuddy` or the `defaults` command. With `Scout`, you can parse the same way Json, Plist and Xml data.

### Using a generic text-processing tool
Don't get me wrong, `awk` is a wonrderful tool. It can do so many things. But it is not that easy to learn. And you have to find a way to parse each different format. `Scout` is really easy to use, as we will see.

## How to use it

### Swift

### Command Line

## Special thanks
To parse Xml data, as the standard library does not offer simple way to do it, `Scout` uses the wonrderful library of Marko Tadić: [AEXML](https://github.com/tadija/AEXML). He has done an amazing work. And if several Xml parsing and writing libraries exist today, I would defintely recommend his. Marko, you might never read those lines, but thank you again!

