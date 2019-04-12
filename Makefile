PREFIX?=/usr/local

build:
	swift build -c release --disable-sandbox

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/xcbox" "$(PREFIX)/bin/xcbox"
	mkdir -p "$(PREFIX)/etc/xcbox"
	cp -rf "Resources" "$(PREFIX)/etc/xcbox"
