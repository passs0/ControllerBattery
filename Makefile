.PHONY: all app run clean install

all: app

app:
	@chmod +x build.sh
	@./build.sh

run: app
	@open build/LifeBar.app

clean:
	@rm -rf .build build

install: app
	@echo "Installing to /Applications..."
	@cp -R build/LifeBar.app /Applications/
	@echo "Installed LifeBar to /Applications"
