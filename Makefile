TOOL_NAME = mint
VERSION = 0.6.0

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
BUILD_PATH = .build/release/$(TOOL_NAME)
CURRENT_PATH = $(PWD)
TAR_FILENAME = $(TOOL_NAME)-$(VERSION).tar.gz

.PHONY: install build uninstall format_code update_brew release

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(INSTALL_PATH)

build:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib

uninstall:
	rm -f $(INSTALL_PATH)

format_code:
	swiftformat Tests --stripunusedargs closure-only --header strip
	swiftformat Sources --stripunusedargs closure-only --header strip

update_brew:
	sed -i '' 's|\(url ".*/archive/\)\(.*\)\(.tar\)|\1$(VERSION)\3|' Formula/mint.rb
	sed -i '' 's|\(sha256 "\)\(.*\)\("\)|\1$(SHA)\3|' Formula/mint.rb

	git add .
	git commit -m "Update brew to $(VERSION)"

release: format_code
	sed -i '' 's|\(let version = "\)\(.*\)\("\)|\1$(VERSION)\3|' Sources/Mint/main.swift

	git add .
	git commit -m "Update to $(VERSION)"
	git tag $(VERSION)
