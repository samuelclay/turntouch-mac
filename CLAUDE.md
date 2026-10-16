# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Turn Touch Mac is a native Objective-C macOS application for configuring and using the Turn Touch smart wooden remote. It connects to the remote via Bluetooth LE and maps button presses (in four directions: North, East, West, South) to actions in various "modes" (apps like Music, Hue, Sonos, etc.).

## Build Commands

```bash
# Install dependencies (required first time and when Podfile changes)
pod install

# Build and run from Xcode
open "Turn Touch Mac.xcworkspace"
# Then use Cmd+R in Xcode to build and run
```

**Important**: Always open the `.xcworkspace` file (not `.xcodeproj`) since the project uses CocoaPods.

## Architecture

### Core Components

- **TTAppDelegate** (`Turn Touch Mac/TTAppDelegate.m`) - App entry point. Owns the main singletons: `modeMap`, `bluetoothMonitor`, `hudController`, `panelController`. Access via `NSAppDelegate` macro.

- **TTBluetoothMonitor** (`Turn Touch Mac/Bluetooth/`) - Manages Bluetooth LE connection to Turn Touch remotes. Handles device discovery, pairing, and button press notifications via `TTButtonTimer`.

- **TTModeMap** (`Turn Touch Mac/Models/TTModeMap.m`) - Central controller for mode/action configuration. Maps button directions to modes and actions. Stores user preferences. Manages keyboard shortcuts via MASShortcut.

- **TTMode** (`Turn Touch Mac/Models/TTMode.m`) - Base class for all modes. Implements the `TTModeProtocol`.

### Mode System

The remote has four directions (NORTH, EAST, WEST, SOUTH), each mapped to a "mode". Each mode provides multiple "actions" that can be assigned to directions within that mode.

Available modes are registered in `TTModeMap.m:44-59`:
- TTModeMac, TTModeMusic, TTModeTV, TTModeHue, TTModeNest, TTModeIfttt, TTModeSonos, TTModeWemo, TTModeAlarmClock, TTModeSpotify, TTModeAirfoil, TTModeVideo, TTModeNews, TTModeWeb, TTModePresentation, TTModeCustom

### Adding a New Mode

1. Create a new folder under `Turn Touch Mac/Modes/YourMode/`
2. Create `TTModeYourMode.h` and `TTModeYourMode.m` extending `TTMode` and implementing `TTModeProtocol`
3. Required protocol methods:
   - `+ (NSString *)title` - Display name
   - `+ (NSString *)description` - Short description
   - `+ (NSString *)imageName` - Icon filename
   - `- (NSArray *)actions` - List of action identifiers (e.g., `@[@"TTModeYourModeAction1", ...]`)
   - `- (NSString *)defaultNorth/East/West/South` - Default action for each direction
4. For each action `TTModeYourModeActionName`, implement:
   - `- (void)runTTModeYourModeActionName` - Single press handler
   - `- (void)doubleRunTTModeYourModeActionName` - Double press handler (optional)
   - `- (NSString *)titleTTModeYourModeActionName` - Display title
   - `- (NSString *)imageTTModeYourModeActionName` - Action icon
5. Add `@"TTModeYourMode"` to the `availableModes` array in `TTModeMap.m`

See `TTModeMusic` as a reference implementation.

### Key Patterns

- **Dynamic method dispatch**: Actions are invoked via `runDirection:` which constructs selector names dynamically (e.g., `runTTModeMusicVolumeUp`).
- **NSUserDefaults**: All preferences stored with `TT:` prefix keys.
- **Scripting Bridge**: Used for controlling apps like iTunes/Music, Keynote, etc. Scripting definition files (`.h`) are in mode folders.
- **Batch Actions**: Multiple actions can be triggered from a single button press.

### Dependencies (via CocoaPods)

- AFNetworking - HTTP networking
- Sparkle - Auto-updates
- MASShortcut - Global keyboard shortcuts
