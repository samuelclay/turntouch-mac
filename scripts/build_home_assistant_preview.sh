#!/bin/bash
# Build a native browser for testing the integration without the legacy app dependencies.
set -euo pipefail
cd "$(dirname "$0")/.."
preview_app="${TMPDIR:-/tmp}/Turn Touch Home Assistant.app"
mkdir -p "$preview_app/Contents/MacOS"
xcrun clang -fobjc-arc -fmodules -framework Cocoa -framework Security -framework WebKit \
  -I 'Turn Touch Mac/Modes/HomeAssistant' scripts/home_assistant_preview.m \
  'Turn Touch Mac/Modes/HomeAssistant/TTHomeAssistantClient.m' \
  'Turn Touch Mac/Modes/HomeAssistant/TTHomeAssistantWindowController.m' \
  -o "$preview_app/Contents/MacOS/TurnTouchHomeAssistant"
python3 - "$preview_app" <<'PY'
import pathlib, plistlib, sys
(pathlib.Path(sys.argv[1]) / 'Contents/Info.plist').write_bytes(plistlib.dumps({
    'CFBundleExecutable': 'TurnTouchHomeAssistant',
    'CFBundleIdentifier': 'com.turntouch.homeassistant-preview',
    'CFBundleName': 'Turn Touch Home Assistant', 'CFBundlePackageType': 'APPL',
    'NSLocalNetworkUsageDescription': 'Find Home Assistant on your network.',
    'NSBonjourServices': ['_home-assistant._tcp'],
    'NSAppTransportSecurity': {'NSAllowsArbitraryLoads': True}}))
PY
codesign --force --sign - "$preview_app"
printf '%s\n' "$preview_app"
