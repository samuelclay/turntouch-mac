//
//  TTModeAlarmSnooze.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/14/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailView.h"

@interface TTModeAlarmSnoozeOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSTextField *durationLabel;
@property (nonatomic) IBOutlet NSSlider *durationSlider;

- (IBAction)slideDuration:(id)sender;

@end
