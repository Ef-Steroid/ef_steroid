#
# Copyright 2022-2022 MOK KAH WAI and contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Run this script in the root project directory.

set -x

#FLUTTER_MACOS_ARTIFACTS_DIR="build/macos/Build/Products/Release"
APP_NAME="Ef Steroid.app"
#APP_PATH="$FLUTTER_MACOS_ARTIFACTS_DIR/$APP_NAME"

ARTIFACTS_DIR="artifacts"

rm -rf "$ARTIFACTS_DIR"
mkdir "$ARTIFACTS_DIR"
#cp -a "$APP_PATH" "$ARTIFACTS_DIR"

#ARTIFACT_APP_PATH="$ARTIFACTS_DIR/$APP_NAME"

CERTIFICATE_NAME="Developer ID Application: KAH WAI MOK (YB9M5F7RAZ)"

xcodebuild -workspace macos/Runner.xcworkspace -config Release -scheme Runner -archivePath artifacts/Runner.xcarchive archive
xcodebuild -archivePath artifacts/Runner.xcarchive -exportArchive -exportPath artifacts -exportOptionsPlist macos/ExportOptions.plist

EF_STEROID_INSTALLER_DMG_DIR="Ef Steroid Installer"
EF_STEROID_INSTALLER_DMG_NAME="Ef Steroid Installer.dmg"
EF_STEROID_INSTALLER_DMG_PATH="$EF_STEROID_INSTALLER_DMG_DIR/$EF_STEROID_INSTALLER_DMG_NAME"

rm -rf "$EF_STEROID_INSTALLER_DMG_DIR"
mkdir "$EF_STEROID_INSTALLER_DMG_DIR"

# Create a disk image (dmg)
create-dmg --volname "$EF_STEROID_INSTALLER_DMG_DIR" --window-pos 200 120 --window-size 800 400 --app-drop-link 600 185 "$EF_STEROID_INSTALLER_DMG_PATH" "$ARTIFACTS_DIR/$APP_NAME"

# Sign the disk image (dmg)
codesign --force --sign "$CERTIFICATE_NAME" "$EF_STEROID_INSTALLER_DMG_PATH"

echo "Notarizing the disk image..."

# Notarize the disk image (dmg)
# $1 - App Store Connect API key. File system path to the private key.
# $2 - App Store Connect API Key ID. Usually 10 alphanumeric characters.
# $3 - App Store Connect API Issuer ID. UUID format.
xcrun notarytool submit "$EF_STEROID_INSTALLER_DMG_PATH" -k "$1" -d "$2" -i "$3" --progress --wait

echo "Stapling the disk image (dmg)..."

# Staple the disk image (dmg) with the returned ticket
xcrun stapler staple "$EF_STEROID_INSTALLER_DMG_PATH"

echo "::set-output name=ef_steroid_installer_dmg_dir::$EF_STEROID_INSTALLER_DMG_DIR"
