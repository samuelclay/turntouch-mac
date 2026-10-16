//
//  TTModeNanoleafSleepOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@class TTModeNanoleaf;

@interface TTModeNanoleafSleepOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSTextField *durationLabel;
@property (nonatomic) IBOutlet NSSlider *durationSlider;
@property (nonatomic) IBOutlet NSTextField *doubleTapDurationLabel;
@property (nonatomic) IBOutlet NSSlider *doubleTapDurationSlider;

- (IBAction)didChangeDuration:(id)sender;

@end
