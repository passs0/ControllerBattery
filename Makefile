.PHONY: all app run clean install

all: app

app:
	@chmod +x build.sh
	@./build.sh

run: app
	@open build/ControllerBattery.app

clean:
	@rm -rf .build build

install: app
	@echo "Installing to /Applications..."
	@cp -R build/ControllerBattery.app /Applications/
	@echo "Installed ControllerBattery to /Applications"
