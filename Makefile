prefix ?= /usr/local
bindir = $(/usr/local)/bin

install:
	swift build -c release
	install ".build/release/ScoutCLT" "$(bindir)/scout"
	
uninstall:
	rm -f "$(bindir)/scout"
	
clean:
	rm -rf .build

.PHONY: build install uninstall clean

