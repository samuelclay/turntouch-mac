//
//  TTModeHuePushlink.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/9/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueOptions.h"
#import "TTModeHuePushlink.h"
#import <HueSDK_OSX/HueSDK.h>

@interface TTModeHuePushlink ()

@end

@implementation TTModeHuePushlink

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)setProgress:(NSNumber *)progressPercentage {
    [self.progressView setDoubleValue:[progressPercentage doubleValue]];
}

@end
