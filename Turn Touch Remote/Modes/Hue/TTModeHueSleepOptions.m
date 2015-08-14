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

@interface TTModeHueSleepOptions ()

@end

@implementation TTModeHueSleepOptions

@synthesize durationLabel;
@synthesize durationSlider;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger sceneDuration = [[appDelegate.modeMap actionOptionValue:kHueDuration] integerValue];
    [durationSlider setIntegerValue:sceneDuration];
    [self updateSliderLabel];
}

#pragma mark - Actions

- (IBAction)didChangeDuration:(id)sender {
    NSInteger duration = durationSlider.integerValue;
    
    [appDelegate.modeMap changeActionOption:kHueDuration to:[NSNumber numberWithInteger:duration]];
    [self updateSliderLabel];
}

- (void)updateSliderLabel {
    NSInteger duration = durationSlider.integerValue;
    
    NSString *durationString;
    if (duration == 0)       durationString = @"Immediate";
    else if (duration == 1)  durationString = @"1 second";
    else if (duration < 60)  durationString = [NSString stringWithFormat:@"%@ seconds", @(duration)];
    else if (duration < 60*2) durationString = @"1 minute";
    else                     durationString = [NSString stringWithFormat:@"%@ minutes", @(duration/60)];
    
    [durationLabel setStringValue:durationString];
}

@end
