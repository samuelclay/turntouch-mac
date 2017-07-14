//
//  SonosController.h
//  Sonos Controller
//
//  Created by Axel Möller on 16/11/13.
//  Copyright (c) 2013 Appreviation AB. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@interface SonosController : NSObject

@property (nonatomic, strong) NSString * _Nonnull ip;
@property (nonatomic, assign) int port;
@property (nonatomic, strong) NSString * _Nullable group;
@property (nonatomic, strong) NSString * _Nullable name;
@property (nonatomic, strong) NSString * _Nullable uuid;
@property (nonatomic, assign, getter = isCoordinator) BOOL coordinator;
@property (nonatomic, strong) NSMutableArray * _Nullable slaves;
@property (nonatomic, assign, readonly) NSInteger cachedVolume;

/**
 Creates and returns a Sonos Controller object.
 By default, the SOAP interface on Sonos Devices operate on port 1400, but use initWithIP:port: if you need to specify another port
 
 Use SonosDiscover to create these controllers from a discovery
 */
- (instancetype _Nonnull)initWithIP:(NSString * _Nonnull)ip_;
- (instancetype _Nonnull)initWithIP:(NSString * _Nonnull)ip_ port:(int)port_;

/**
 All SOAP methods returns asynchronus XML data from the Sonos Device in an NSDictionary format for easy reading.
 Some methods returns quick values that are interesting, eg. getVolume:completion: returns an integer containing the volume,
 together with the entire XML response
 
 All methods returns a non-empty NSError object on failure
 */

/**
 Plays a track
 
 @param track The Track URI, may be nil to just play current track
 @param block Objective-C block to call on finish
 */
- (void)play:(NSString * _Nullable)track completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Plays a track with custom URI Metadata, Spotify etc needs this, see playSpotifyTrack:completion:
 
 @param track The track URI
 @param URIMetaData Metadata XML String
 @param block Objective-C block to call on finish
 */
- (void)play:(NSString * _Nonnull)track URIMetaData:(NSString * _Nonnull)URIMetaData completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Plays a Spotify track
 
 @param track Spotify track URI
 @param block Objective-C block to call on finish
 */
- (void)playSpotifyTrack:(NSString * _Nonnull)track completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Play track in queue
 
 @param position. Starts counting at 1
 @param block Objective-C block to call on finish
 */
- (void)playQueuePosition:(int)position completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Pause playback
 
 @param block Objective-C block to call on finish
 */
- (void)pause:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Toggle playback, pause if playing, play if paused
 BOOL in block function contains current playback state
 
 @param block Objective-C block to call on finish
 */
- (void)togglePlayback:(void (^ _Nullable)(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Next track
 
 @param block Objective-C block to call on finish
 */
- (void)next:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Previous track
 
 @param block Objective-C block to call on finish
 */
- (void)previous:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Queue a track
 
 @param track The Track URI, may not be nil
 @param block Objective-C block to call on finish
 */
- (void)queue:(NSString * _Nonnull)track replace:(BOOL)replace completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Queue a track with custom URI Metadata
 Needed for Spotify etc
 
 @param track The Track URI
 @param URIMetaData URI Metadata XML String
 @param block Objective-C block to call on finish
 */
- (void)queue:(NSString * _Nonnull)track URIMetaData:(NSString * _Nonnull)URIMetaData replace:(BOOL)replace completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/*
 Queue a Spotify playlist
 eg. spotify:user:aaa:playlist:xxxxxxxxxx
 
 @param playlist The playlist URI
 @param replace Replace current queue
 @param block Objective-C block to call on finish
 */
- (void)queueSpotifyPlaylist:(NSString * _Nonnull)playlist replace:(BOOL)replace completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Get current volume of device.
 This method passes an NSInteger with the volume level (0-100) to the block. Cached volume can be returned if maxCacheAge > 0.
 
 @param maxCacheAge Allows for returning cached volume if the cached volume is not older than maxCacheAge (in seconds) otherwise a volume request is sent. Values <= 0 will always send volume get requests.
 @param block Objective-C block to call on finish
 */
- (void)getVolume:(NSTimeInterval)maxCacheAge completion:(void (^ _Nullable)(NSInteger volume, NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Get current volume of device.
 This method returns an NSInteger with the volume level (0-100) to the block. Volume is always requested.
 
 @param block Objective-C block to call on finish
 */
- (void)getVolume:(void (^ _Nullable)(NSInteger volume, NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Set volume of device.
 
 @param volume The volume (0-100)
 @param mergeRequests If YES, following volume set requests are not send as long as this request has not been answered. Instead all following setVolume calls will only update the internal state for the desired volume. A second set request for all merged calls to setVolume is then send out when this request has been answered. This avoids multiple set requests being sent out at the same time. If YES, getVolume will also return the internal state for the desired volume to be set, as long as this set request has not yet been answered. Setting mergeRequest to YES allows a smoother user experience when otherwise too many volume set requests would be sent out in parallel and thus arrive very delayed at the Sonos controllers. Consider combining merging the set requests with allowing for returning cached volumes in getVolume to provide the best user experience.
 @param block Objective-C block to call on finish
 */
- (void)setVolume:(NSInteger)volume mergeRequests:(BOOL)mergeRequest completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Set volume of device.
 Does not merge volume set requests.
 
 @param volume The volume (0-100)
 @param block Objective-C block to call on finish
 */

- (void)setVolume:(NSInteger)volume completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Get mute status
 
 @param block Objective-C block to call on finish
 */
- (void)getMute:(void (^ _Nullable)(BOOL mute, NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Set or unset mute on device
 
 @param mute Bool value
 @param block Objective-C block to call on finish
 */
- (void)setMute:(BOOL)mute completion:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Get current track info.
 
 @param block Objective-C block to call on finish
 */
- (void)trackInfo:(void (^ _Nullable)(NSString * _Nullable artist, NSString * _Nullable title, NSString * _Nullable album, NSURL * _Nullable albumArt, NSInteger time, NSInteger duration, NSInteger queueIndex, NSString * _Nullable trackURI, NSString * _Nullable protocol, NSError * _Nullable error))block;

- (void)mediaInfo:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 Playback status
 Returns playback boolean value in block
 
 @param block Objective-C block to call on finish
 */
- (void)playbackStatus:(void (^ _Nullable)(BOOL playing, NSDictionary * _Nullable response, NSError * _Nullable error))block;

/**
 More detailed version of playbackStatus:
 Get status info (playback status). The only interesting data IMO is CurrentTransportState that tells if the playback is active. Thus returns:
 - CurrentTransportState - {PLAYING|PAUSED_PLAYBACK|STOPPED}
 
 @param block Objective-C block to call on finish
 */
- (void)status:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error))block;

- (void)browse:(void (^ _Nullable)(NSDictionary * _Nullable response, NSError * _Nullable error)) block;

@end