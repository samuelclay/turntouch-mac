//
//  TTModeMac.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/23/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMac.h"

@implementation TTModeMac

+ (NSString *)title {
    return @"Mac OS";
}

- (NSString *)imageName {
    return @"imac.png";
}

- (NSString *)titleNorth {
    return @"Volume Up";
}

- (NSString *)titleEast {
    return @"Turn off screen";
}

- (NSString *)titleWest {
    return @"Mute";
}

- (NSString *)titleSouth {
    return @"Volume Down";
}

@end
