#!/bin/sh

set -ev

KEYSSET_FILE_PATH="${SRCROOT}/Tests/Resources/test-keysset.plist"

if [ "${TRAVIS}" = "true" ]; then
	cat > $KEYSSET_FILE_PATH <<EOF
		<?xml version="1.0" encoding="UTF-8"?>
		<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
		<plist version="1.0">
		<dict>
			<key>pub-key</key>
			<string>$PUBLISH_KEY</string>
			<key>sub-key</key>
			<string>$SUBSCRIBE_KEY</string>
		</dict>
		</plist>
EOF
fi