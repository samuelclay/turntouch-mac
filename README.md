# Turn Touch Mac OS App
> A native Objective-C app for configuring and using the Turn Touch smart wooden remote on Mac OS X.

<a href="https://turntouch.com"><img src="https://s3.amazonaws.com/static.newsblur.com/turntouch/blog/1*1_w7IlHISYWdQjIGPcxRkQ.jpeg" width="400"><br />Available at turntouch.com</a>

[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


## Screenshots of Turn Touch on OS X

App | Modes
:----:|:----:
| ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.56.01%20PM) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.56.18%20PM) |

How It Works | Tap a button | Hold a button | Multiple actions | HUD
:---:|:---:|:---:|:---:|:---:
| ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.47%20PM) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.49%20PM) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.51%20PM) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.52%20PM) | ![](Screenshots/Screen%20Shot%202019-01-04%20at%20Jan%204%2012.55.55%20PM) | 

## Screenshots of Turn Touch on iPad

How It Works | Tap a button | Hold a button | Multiple actions | HUD
:---:|:---:|:---:|:---:|:---:
| ![](Screenshots/Simulator%20Screen%20Shot%20Sep%2022,%202016,%20Sep%2022%202.02.22%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%2022,%202016,%20Sep%2022%202.02.23%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%2022,%202016,%20Sep%2022%202.02.24%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%2022,%202016,%20Sep%2022%202.02.26%20PM.png) | ![](Screenshots/Simulator%20Screen%20Shot%20Sep%2022,%202016,%20Sep%2022%202.02.27%20PM.png) | 

## Features

[Turn Touch](https://turntouch.com) is a smart home remote control carved out of beautiful mahogany wood. This is a remote control for Hue lights, Sonos speakers, and all the other connected devices in your home. Turn Touch works on iOS and macOS, giving you control of your music, videos, presentations, and more. 

- [x] **Extraordinary design**: This isn't yet another plastic remote. Turn Touch is carved from solid wood and worked to a show-stopping, textured finish. 
- [x] **Well connected**: Turn Touch connects to most smart devices in your home that speak WiFi. And this is just the first version. Over time, there's no telling what you'll be able to control.
- [x] **Always ready**: Turn Touch is always on, always connected, and always ready to take your breath away. Once you connect your Turn Touch via Bluetooth it stays connected and always available, even without the Turn Touch app actively running. And there's no delay, when you press a button the result is instant.
- [x] **Built to last**: Not only will your Turn Touch stand up to drops and shock — its entire circuit board can be inexpensively replaced with newer, future wireless tech. You won't have to buy a new remote every time Apple comes out with a new phone. And instead of flimsy plastic clasps, a set of 8 strong magnets invisibly hold the remote together. 

## Requirements

- iOS 12.0+
- Xcode 10.1

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install all of the dependencies:

```
pod install
```

#### Running on a device

To use Turn Touch you must run the iOS app on a device. Works with both iPhone and iPad.

## Contribute

We would love you for the contribution to the **Turn Touch iOS app**. 

Here's what you will need to do to add a new app:

1. Copy one of the [/Turn Touch iOS/Modes](Turn%20Touch%20iOS/Modes) apps. If you can't choose, use the Music app, as it's pretty easy to clean.
2. Add your app to the list of available apps in [/Turn Touch iOS/Models/TTModeMap.swift](Turn%20Touch%20iOS/Models/TTModeMap.swift)
3. Make sure to test on your iOS device
4. Submit a Pull Request with the app improvement or addition.

## Turn Touch open source repositories and documentation

Everything about Turn Touch is open source and well documented. Here are all of Turn Touch's repos:

* [Turn Touch Mac OS app](https://github.com/samuelclay/turntouch-app/)
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

[https://github.com/samuelclay/turntouch-ios](https://github.com/samuelclay)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
