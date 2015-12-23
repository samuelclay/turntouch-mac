//
//  TTModeAlarmSnooze.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeAlarmSnoozeOptions.h"
#import "TTModeAlarmClock.h"

@implementation TTModeAlarmSnoozeOptions

@synthesize durationSlider;
@synthesize durationLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger snoozeDuration = [[self.action optionValue:kAlarmSnoozeDuration] integerValue];
    // Run in TTModeMusic:
    // NSInteger volumeJump = [[NSAppDelegate.modeMap actionOptionValue:kMusicVolumeJump inDirection:direction] integerValue];
    
    [durationSlider setIntegerValue:snoozeDuration];
    [self updateSnoozeDurationLabel];
}

- (void)updateSnoozeDurationLabel {
    NSInteger snoozeDuration = [[self.action optionValue:kAlarmSnoozeDuration] integerValue];
    
    [durationLabel setStringValue:[NSString stringWithFormat:@"%ld min", (long)snoozeDuration]];
}

- (IBAction)slideDuration:(id)sender {
    [self.action changeActionOption:kAlarmSnoozeDuration to:[NSNumber numberWithInteger:durationSlider.integerValue]];
    
    [self updateSnoozeDurationLabel];
}

@end
