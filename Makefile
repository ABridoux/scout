install:
	swift build -c release
	install .build/release/ScoutCLT /usr/local/bin/scout 