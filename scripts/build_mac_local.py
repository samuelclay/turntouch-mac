#!/usr/bin/env python3
"""Build and ad-hoc sign the full native Mac app with the installed Xcode."""
import argparse
import pathlib
import platform
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--universal', action='store_true', help='Build both Apple Silicon and Intel')
parser.add_argument('--launch', action='store_true', help='Open the completed local app')
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[1]
build = pathlib.Path('/tmp/turntouch-native-build')
architectures = 'arm64 x86_64' if args.universal else platform.machine()
subprocess.run(['xcodebuild', '-workspace', 'Turn Touch Mac.xcworkspace', '-scheme', 'Turn Touch Mac',
    '-configuration', 'Debug', '-derivedDataPath', str(build), 'CODE_SIGNING_ALLOWED=NO',
    f'ARCHS={architectures}', 'ONLY_ACTIVE_ARCH=NO', 'build'], cwd=root, check=True)
app = build / 'Build/Products/Debug/Turn Touch Mac.app'
subprocess.run(['codesign', '--force', '--deep', '--sign', '-', str(app)], check=True)
subprocess.run(['file', str(app / 'Contents/MacOS/Turn Touch Mac')], check=True)
print(app)
if args.launch:
    subprocess.run(['open', str(app), '--args', '-moveToApplicationsFolderAlertSuppress', 'YES'], check=True)
