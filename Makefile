prefix ?= /usr/local
bindir = $(prefix)/bin

install:
	swift build -c release
	install .build/release/ScoutCLT "$(bindir)/scout"
	
uninstall:
	rm -f "$(bindir)/scout" 
	
clean:
	rm -rf .build