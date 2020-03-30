# ---- Colors ----

COLOR_FAILURE='\033[0;31m'
COLOR_SUCCESS='\033[0;32m'
COLOR_NC='\033[0m' # No Color

function error {
	echo "${COLOR_FAILURE}$1${COLOR_NC}"
	exit 1
}

function success {
	echo "${COLOR_SUCCESS}$1${COLOR_NC}"
}
	
# ---- Files ----

json=Playground/People.json
plist=Playground/People.plist
xml=Playground/People.xml

function format {
	 echo "${1##*.}"
}
# ---- Test functions ----

function testGet {
	fileFormat=`format $3`
	expected=$2
	result=`scout $1 -i $3`
	
	if [ "$result" != "$expected" ]; then
		error "Error $fileFormat get. '$1' = $result != $expected"
	fi
}

function testGetAll {
	expected=$2
	
	echo "Testing get at '$1'..."
	
	testGet "$1" "$2" $json
	testGet "$1" "$2" $plist
	testGet "$1" "$2" $xml
	success "All test formats passed"
	echo ""
}

function testSet {
	fileFormat=`format $3`
	modified=`scout set "$1=$2" -i $3 -v`
	valueAtPath=`echo "$modified" | scout $1`
	
	if [ "$valueAtPath" != "$2" ]; then
		error "Error $fileFormat set. '$1': expected $2 and got $valueAtPath"
	fi
}

function testSetAll {
	expected=$2
	
	echo "Testing set at '$1'..."
	
	testSet "$1" "$2" $json
	testSet "$1" "$2" $plist
	testSet "$1" "$2" $xml
	success "All test formats passed"
	echo ""
}

# ---- Tests ----

# Get
echo "-- Testing Get --"
testGetAll people.Tom.height 175
testGetAll people.Tom.hobbies[-1] guitar
testGetAll people.Tom.hobbies[0] cooking
testGetAll people.Suzanne.movies[0].title "Tomorrow is so far"
testGetAll people.Robert.running_records[1][0] 9

# -- Test dictionary --

TomJson='{
  "age" : 68,
  "hobbies" : [
    "cooking",
    "guitar"
  ],
  "height" : 175
}'
testGet people.Tom "$TomJson" $json

TomPlist='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>age</key>
	<integer>68</integer>
	<key>height</key>
	<integer>175</integer>
	<key>hobbies</key>
	<array>
		<string>cooking</string>
		<string>guitar</string>
	</array>
</dict>
</plist>'

testGet people.Tom "$TomPlist" $plist

TomXml='<Tom>
	<height>175</height>
	<age>68</age>
	<hobbies>
		<hobby>cooking</hobby>
		<hobby>guitar</hobby>
	</hobbies>
</Tom>'

testGet people.Tom "$TomXml" $xml

# Set
echo "-- Testing Set --"

testSetAll people.Robert.age 60
testSetAll people.Suzanne.movies[1].title "Never gonna die"
testSetAll people.Robert.running_records[0][2] 15