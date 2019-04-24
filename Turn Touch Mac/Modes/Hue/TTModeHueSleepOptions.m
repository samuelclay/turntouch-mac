//
//  TTModeHueSleepOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueSleepOptions.h"
#import <HueSDK_OSX/HueSDK.h>

NSString *const kHueDuration = @"hueDuration";
NSString *const kHueDoubleTapDuration = @"hueDoubleTapDuration";

@interface TTModeHueSleepOptions ()

@end

@implementation TTModeHueSleepOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger sceneDuration = [[self.action optionValue:kHueDuration inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    [self.durationSlider setIntegerValue:sceneDuration];
    [self updateSliderLabel:NO];
    
    NSInteger doubleTapSceneDuration = [[self.action optionValue:kHueDoubleTapDuration inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    [self.doubleTapDurationSlider setIntegerValue:doubleTapSceneDuration];
    [self updateSliderLabel:YES];
}

#pragma mark - Actions

- (IBAction)didChangeDuration:(id)sender {
    NSInteger duration = self.durationSlider.integerValue;
    [self.action changeActionOption:kHueDuration to:[NSNumber numberWithInteger:duration]];
//    [appDelegate.modeMap changeActionOption:kHueDuration to:[NSNumber numberWithInteger:duration]];
    [self updateSliderLabel:NO];

    NSInteger doubleTapDuration = self.doubleTapDurationSlider.integerValue;
    [self.action changeActionOption:kHueDoubleTapDuration to:[NSNumber numberWithInteger:doubleTapDuration]];
//    [appDelegate.modeMap changeActionOption:kHueDoubleTapDuration to:[NSNumber numberWithInteger:doubleTapDuration]];
    [self updateSliderLabel:YES];
}

- (void)updateSliderLabel:(BOOL)doubleTap {
    NSInteger duration = doubleTap ? self.doubleTapDurationSlider.integerValue : self.durationSlider.integerValue;
    
    NSString *durationString;
    if (duration == 0)       durationString = @"Immediate";
    else if (duration == 1)  durationString = @"1 second";
    else if (duration < 60)  durationString = [NSString stringWithFormat:@"%@ seconds", @(duration)];
    else if (duration < 60*2) durationString = @"1 minute";
    else                     durationString = [NSString stringWithFormat:@"%@ minutes", @(duration/60)];
    
    [(doubleTap ? self.doubleTapDurationLabel : self.durationLabel) setStringValue:durationString];
}

@end
