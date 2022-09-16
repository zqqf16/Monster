PROJ = Monster.xcodeproj/project.pbxproj
MARKETING_VERSION = $(shell cat $(PROJ)|  sed -n 's/.*MARKETING_VERSION = \(.*\);/\1/p' | head -n 1)
CURRENT_PROJECT_VERSION = $(shell cat $(PROJ)|  sed -n 's/.*CURRENT_PROJECT_VERSION = \(.*\);/\1/p' | head -n 1)
BUILD_VER = $(MARKETING_VERSION)_$(CURRENT_PROJECT_VERSION)
NAME = Monster_$(BUILD_VER)
ARCHIVE_PATH = build/$(NAME).xcarchive
EXPORT_PATH = build/$(NAME)
APP_PATH = $(EXPORT_PATH)/Monster.app
DMG_DIR = $(EXPORT_PATH)/Monster
DIST_DIR = dist
DMG_PATH = $(DIST_DIR)/$(NAME).dmg

all: archive

clean:
	xcodebuild -project Monster.xcodeproj -config Release -scheme Monster -archivePath $(ARCHIVE_PATH) clean
	if [ -d ${ARCHIVE_PATH} ]; then rm -r $(ARCHIVE_PATH); fi;
	if [ -d ${EXPORT_PATH} ]; then rm -r $(EXPORT_PATH); fi;
	if [ -d ${DMG_DIR} ]; then rm -r $(DMG_DIR); fi;

next:
	agvtool next-version

archive:
	xcodebuild -project Monster.xcodeproj -config Release -scheme Monster -archivePath $(ARCHIVE_PATH) archive
	xcodebuild -exportArchive -archivePath $(ARCHIVE_PATH) -exportOptionsPlist exportOptions.plist -exportPath $(EXPORT_PATH)

dmg:
	if [ -f ${DMG_PATH} ]; then rm $(DMG_PATH); fi;
	if [ -d ${DMG_DIR} ]; then rm -r $(DMG_DIR); fi;
	mkdir -p $(DMG_DIR) $(DIST_DIR)
	cp -r $(APP_PATH) $(DMG_DIR)
	ln -s /Applications $(DMG_DIR)/Applications
	hdiutil create -fs HFS+ -srcfolder $(DMG_DIR) -format UDZO -volname Monster $(DMG_PATH)

install:
	cp -r $(APP_PATH) /Applications
