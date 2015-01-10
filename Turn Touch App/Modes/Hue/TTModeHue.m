//
//  TTModeHue.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueOptions.h"

@interface TTModeHue()

@end

@implementation TTModeHue

#pragma mark - Mode

+ (NSString *)title {
    return @"Hue";
}

+ (NSString *)description {
    return @"Lights and scenes";
}

+ (NSString *)imageName {
    return @"mode_meditation.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeHueSceneEarlyEvening",
             @"TTModeHueSceneLateEvening",
             @"TTModeHueSleep",
             @"TTModeHueOff"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeHueSceneEarlyEvening {
    return @"Early evening";
}
- (NSString *)titleTTModeHueSceneLateEvening {
    return @"Late evening";
}
- (NSString *)titleTTModeHueSleep {
    return @"Sleep";
}
- (NSString *)titleTTModeHueOff {
    return @"Lights off";
}

#pragma mark - Action Images

- (NSString *)imageTTModeHueSceneEarlyEvening {
    return @"volume_up.png";
}
- (NSString *)imageTTModeHueSceneLateEvening {
    return @"volume_down.png";
}
- (NSString *)imageTTModeHueSleep {
    return @"play.png";
}
- (NSString *)imageTTModeHueOff {
    return @"next_track.png";
}

#pragma mark - Action methods


#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeHueSceneEarlyEvening";
}
- (NSString *)defaultEast {
    return @"TTModeHueSceneLateEvening";
}
- (NSString *)defaultWest {
    return @"TTModeHueOff";
}
- (NSString *)defaultSouth {
    return @"TTModeHueSleep";
}

#pragma mark - Hue Init

- (void)activate {
}

@end
