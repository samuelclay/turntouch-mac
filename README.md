# Turn Touch Mac OS App
> A native Objective-C app for configuring and using the Turn Touch smart wooden remote on Mac OS X.

<a href="https://turntouch.com"><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*1_w7IlHISYWdQjIGPcxRkQ.jpeg" width="400"><br />Available at turntouch.com</a>

[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


## Screenshots of Turn Touch on OS X

App | Modes
:----:|:----:
| ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.56.01%20PM.png) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.56.18%20PM.png) |

How It Works | Tap a button | Hold a button | Multiple actions | HUD
:---:|:---:|:---:|:---:|:---:
| ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.47%20PM.png) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.49%20PM.png) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.51%20PM.png) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.52%20PM.png) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.55%20PM.png) | 

## Features

[Turn Touch](https://turntouch.com) is a smart home remote control carved out of beautiful mahogany wood. This is a remote control for Hue lights, Sonos speakers, and all the other connected devices in your home. Turn Touch works on iOS and macOS, giving you control of your music, videos, presentations, and more. 

- [x] **Extraordinary design**: This isn't yet another plastic remote. Turn Touch is carved from solid wood and worked to a show-stopping, textured finish. 
- [x] **Well connected**: Turn Touch connects to most smart devices in your home that speak WiFi. And this is just the first version. Over time, there's no telling what you'll be able to control.
- [x] **Always ready**: Turn Touch is always on, always connected, and always ready to take your breath away. Once you connect your Turn Touch via Bluetooth it stays connected and always available, even without the Turn Touch app actively running. And there's no delay, when you press a button the result is instant.
- [x] **Built to last**: Not only will your Turn Touch stand up to drops and shock — its entire circuit board can be inexpensively replaced with newer, future wireless tech. You won't have to buy a new remote every time Apple comes out with a new phone. And instead of flimsy plastic clasps, a set of 8 strong magnets invisibly hold the remote together. 

## Requirements

- macOS 10.13+
- A current Xcode with the macOS SDK (verified with Xcode 27)

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install all of the dependencies:

```
pod install
```

#### Running on a Mac

Works on all Macs running the latest OS.

### Mac release verification

Follow [the Mac release procedure](docs/mac-release.md) before publishing an update
or replacing the installed production app. The required signing and notarization
check is:

```sh
python3 scripts/verify_mac_update.py '/path/to/previous/Turn Touch Mac.app' '/path/to/new/Turn Touch Mac.app'
```

Use unmodified apps extracted from the previous public ZIP and the candidate ZIP.
The script verifies sealed resources, the candidate's stapled notarization ticket
and Gatekeeper acceptance, increasing build number, bundle ID, and signing
compatibility using the previous release's actual Sparkle framework. Any nonzero
exit blocks publication. Also verify the interactive update and relaunch; the
script alone does not prove that UI flow completed. See the procedure for packaging,
live download verification, and recovery from a local development build.

## Contribute

We would love you for the contribution to the **Turn Touch Mac OS app**. 

Here's what you will need to do to add a new app:

1. Copy one of the [/Turn Touch Mac/Modes](Turn%20Touch%20Mac/Modes) apps. If you can't choose, use the Music app, as it's pretty easy to clean.
2. Add your app to the list of available apps in [/Turn Touch Mac/Models/TTModeMap.m](Turn%20Touch%20Mac/Models/TTModeMap.m)
3. Make sure to test on your Mac
4. Submit a Pull Request with the app improvement or addition.

## Turn Touch open source repositories and documentation

Everything about Turn Touch is open source and well documented. Here are all of Turn Touch's repos:

* [Turn Touch Mac OS app](https://github.com/samuelclay/turntouch-mac/)
* [Turn Touch iOS app](https://github.com/samuelclay/turntouch-ios/)
* [Turn Touch remote firmware and board layout](https://github.com/samuelclay/turntouch-remote/)
* [Turn Touch enclosure, CAD, and CAM](https://github.com/samuelclay/turntouch-enclosure/)

The entire Turn Touch build process is also documented:
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/">Everything you need to build your own Turn Touch smart remote<br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*1_w7IlHISYWdQjIGPcxRkQ.jpeg" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#firmware">Step one: Laying out the buttons and writing the firmware <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*K_ERgjIZiFIX5yDOa5JJ7g.png" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#cad">Step two: Designing the remote to have perfect button clicks <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*iXMqpq5IsfudAeT3GZlLFA.png" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#cnc">Step three: CNC machining and fixturing to accurately cut wood <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*SYmywFE5tY3GBO9t9lcTiA.png" width="400"></a>
* <a href="http://ofbrooklyn.com/2019/01/3/building-turntouch/#laser">Step four: Inlaying the mother of pearl <br /><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*kl8WDuTd0RpCkkipLeHx0g.png" width="400"></a>

## Author

Samuel Clay – [@samuelclay](https://twitter.com/samuelclay) – [samuelclay.com](http://samuelclay.com)

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/samuelclay/turntouch-mac](https://github.com/samuelclay)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com


## Home Assistant (Mac integration)

Choose **Home Assistant** in Turn Touch's app picker. Select a remote button and
open **Choose Home Assistant action…** to configure it. The native browser finds
local Home Assistant servers using Bonjour (`_home-assistant._tcp`), or accepts
an HTTP/HTTPS server URL. Sign in to your own Home Assistant instance, or use a
long-lived token from its profile security page. Tokens stay in macOS Keychain;
button preferences contain only the server URL, entity ID, action, name, and data.

Search by friendly name, entity ID, device name, or area. The initial list shows
entities with callable actions; use **All entities** to include read-only sensors.
Choose an action, optionally add its JSON data, use **Test action** to run it now,
and **Save to button** to assign it. Examples include lights and switches on/off/
toggle, scene activation, scripts, cover controls, media controls, and automation
runs. Automations check their conditions by default; explicitly passing
`{"skip_condition": true}` overrides that. Blueprints are templates: choose the
script or automation created from a blueprint.

No custom Home Assistant integration or cloud relay is required. The Mac must be
awake, running Turn Touch, and able to reach Home Assistant to forward remote
presses. Mobile clients can use the same REST/WebSocket protocol and binding
shape, but iOS and Android UI/background execution are separate follow-up work.
This first version targets individual entities (including Home Assistant group
entities). Device/area registries improve search; it does not yet assign entire
areas as action targets, generate native forms for every action field, or publish
remote button events into Home Assistant.

### Implementation and authentication

`Turn Touch Mac/Modes/HomeAssistant/` contains the API client, native browser,
mode, and button-options adapter. REST retrieves states/services and executes
`POST /api/services/{domain}/{service}`. WebSocket registry lookups add device and
area names when the signed-in user's permissions allow them; otherwise entity
search still works. Catalog refresh is explicit, not a continuous state stream.
Unavailable entities cannot be tested. Read-only sensors have no invented actions.

Sign-in uses a nonpersistent WebKit window with Home Assistant's OAuth flow,
client ID `https://turntouch.com`, and same-origin callback
`https://turntouch.com/home-assistant/callback`. The native view intercepts that
callback before loading it, validates random state, and exchanges the code locally.
A hosted callback page or Home Assistant plugin is unnecessary for this flow.
Refresh tokens renew access tokens. For a future system-browser/custom-scheme
login, publish Home Assistant's `rel="redirect_uri"` link on the client website.
Disconnect removes credentials from this Mac; existing Home Assistant sessions
can also be revoked from the Home Assistant user profile.

### Development checks

Run `python3 scripts/test_home_assistant.py` for production-client HTTP tests
against a loopback Home Assistant fixture plus native AppKit browser tests.
These cover exact action payloads, target restrictions, authentication failures,
redirect rejection, OAuth refresh, Keychain persistence/removal, scene behavior,
search, saved selection, edits surviving refresh, and binding validation.
They do not establish physical remote/Bluetooth delivery.

Run `python3 scripts/build_mac_local.py --launch` to build, ad-hoc sign, and open
the full app natively. Add `--universal` to include both Apple Silicon and Intel.
The local script targets macOS 12 because Xcode 27 no longer builds for older
versions. The project retains the released app’s macOS 10.13 setting; building
for that minimum requires a compatible older Xcode and separate runtime testing.
Home Assistant uses REST, with optional device/area registry enrichment through
WebSocket on macOS 10.15 or later. The resulting app is
`/tmp/turntouch-native-build/Build/Products/Debug/Turn Touch Mac.app`.

Keep this ad-hoc signed development build at its build path; do not replace the
production app in `/Applications` with it. Sparkle checks an update against the
installed app's signing identity. A local ad-hoc build cannot establish trust in
the Developer ID signed release, even when its displayed version is the same.
To recover such an installation, quit it and replace the app bundle with the
signed, notarized app from [the official download](https://turntouch.com/download).
Keep the existing preferences and Keychain items.

Follow [Mac release verification](#mac-release-verification) for production builds.

The released Hue v2 implementation is retained, including its live event stream,
existing bridge credentials, scene selections, and reconnection behavior. It is
source-built and supports both Intel and Apple Silicon. The temporary Hue v1
replacement has been removed. Govee, Kasa, and Nanoleaf integrations and the
released Bluetooth, layout, and Sparkle updater fixes are retained.
Run `python3 scripts/test_hue_v2.py` to verify v2 action failures, partial errors,
authentication, redirect rejection, and exact payloads against a local fixture.

Google shut down Works with Nest in September 2023. The legacy Nest mode now
uses Home Assistant and explains that existing Nest buttons need to be assigned
again. Its old Firebase dependency and retired Nest implementation are excluded
from both application targets. Historical vendor files are retained in the tree,
but neither the Hue SDK nor Firebase is linked or embedded in the app. Sparkle
already includes an Apple Silicon slice; the other dependencies build from source.

For a standalone Home Assistant integration browser,
run `bash scripts/build_home_assistant_preview.sh` and open the printed `.app` path.
The preview uses the production browser/client; **Save to button** is disabled
because it is not attached to a remote button. The main Turn Touch app supplies
the save handler. Previously authorized credentials can be restored for a
discovered server from Keychain.

## Localization

The app supports English and 20 translations, automatic device-language detection,
a first-launch chooser, and Language at the top of Settings. See
[the localization workflow](localization/README.md) for extraction, incremental
AI translation, catalog validation, and localized store screenshot preparation.
[Validation results](localization/VALIDATION.md) record the current build and UI checks.
