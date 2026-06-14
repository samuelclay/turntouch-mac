//
//  TTModeNanoleafSleepOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleaf.h"
#import "TTModeNanoleafSleepOptions.h"

@implementation TTModeNanoleafSleepOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger sceneDuration = [[self.action optionValue:kNanoleafDuration
                                           inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    [self.durationSlider setIntegerValue:sceneDuration];
    [self updateSliderLabel:NO];

    NSInteger doubleTapSceneDuration = [[self.action optionValue:kNanoleafDoubleTapDuration
                                                    inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    [self.doubleTapDurationSlider setIntegerValue:doubleTapSceneDuration];
    [self updateSliderLabel:YES];
}

#pragma mark - Actions

- (IBAction)didChangeDuration:(id)sender {
    NSInteger duration = self.durationSlider.integerValue;
    [self.action changeActionOption:kNanoleafDuration to:[NSNumber numberWithInteger:duration]];
    [self updateSliderLabel:NO];

    NSInteger doubleTapDuration = self.doubleTapDurationSlider.integerValue;
    [self.action changeActionOption:kNanoleafDoubleTapDuration to:[NSNumber numberWithInteger:doubleTapDuration]];
    [self updateSliderLabel:YES];
}

- (void)updateSliderLabel:(BOOL)doubleTap {
    NSInteger duration = doubleTap ? self.doubleTapDurationSlider.integerValue : self.durationSlider.integerValue;

    NSString *durationString;
    if (duration == 0)        durationString = @"Immediate";
    else if (duration == 1)   durationString = @"1 second";
    else if (duration < 60)   durationString = [NSString stringWithFormat:@"%@ seconds", @(duration)];
    else if (duration < 60*2) durationString = @"1 minute";
    else                      durationString = [NSString stringWithFormat:@"%@ minutes", @(duration/60)];

    [(doubleTap ? self.doubleTapDurationLabel : self.durationLabel) setStringValue:durationString];
}

@end
