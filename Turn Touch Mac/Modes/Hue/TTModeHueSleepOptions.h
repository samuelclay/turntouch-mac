//
//  TTModeHueSleepOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTModeHuePicker.h"

extern NSString *const kHueDuration;
extern NSString *const kHueDoubleTapDuration;

@class TTModeHue;

@interface TTModeHueSleepOptions : TTModeHuePicker

@property (nonatomic) IBOutlet NSTextField *durationLabel;
@property (nonatomic) IBOutlet NSSlider *durationSlider;
@property (nonatomic) IBOutlet NSTextField *doubleTapDurationLabel;
@property (nonatomic) IBOutlet NSSlider *doubleTapDurationSlider;

- (IBAction)didChangeDuration:(id)sender;


@end
