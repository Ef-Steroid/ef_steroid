#!/bin/sh

# https://github.com/create-dmg/create-dmg
create-dmg --volname "EfSteroidInstaller" --window-pos 200 120 --window-size 800 400 --app-drop-link 600 185 "$@"


#EXPORT_PATH="$TEMP_DIR/Archive"
#APP_PATH="$EXPORT_PATH/$PRODUCT_NAME.app"
#DMG_PATH="$APP_PATH/$PRODUCT_NAME.dmg"
#
#/usr/bin/xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportOptionsPlist "$SRCROOT/ExportOptions.plist" -exportPath "$EXPORT_PATH"
#
#./Scripts/builddmg.sh "$APP_PATH" "$DMG_PATH"
#
#/usr/bin/open "$EXPORT_PATH"
