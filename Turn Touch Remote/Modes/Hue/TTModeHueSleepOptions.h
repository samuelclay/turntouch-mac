//
//  TTModeHueSleepOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

extern NSString *const kHueScene;
extern NSString *const kHueDuration;

@class TTModeHue;

@interface TTModeHueSleepOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSTextField *durationLabel;
@property (nonatomic) IBOutlet NSSlider *durationSlider;

- (IBAction)didChangeDuration:(id)sender;


@end
