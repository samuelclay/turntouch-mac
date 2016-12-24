//
//  TTModeHueRandom.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/15/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTSegmentedControl.h"
#import "TTModeHuePicker.h"

@class TTModeHue;

@interface TTModeHueRandomOptions : TTModeHuePicker

@property (nonatomic) IBOutlet TTSegmentedControl *segRandomColors;
@property (nonatomic) IBOutlet TTSegmentedControl *segRandomBrightness;
@property (nonatomic) IBOutlet TTSegmentedControl *segRandomSaturation;
@property (nonatomic) IBOutlet TTSegmentedControl *doubleTapSegRandomColors;
@property (nonatomic) IBOutlet TTSegmentedControl *doubleTapSegRandomBrightness;
@property (nonatomic) IBOutlet TTSegmentedControl *doubleTapSegRandomSaturation;

- (IBAction)changeRandomColors:(id)sender;
- (IBAction)changeRandomBrightness:(id)sender;
- (IBAction)changeRandomSaturation:(id)sender;

@end
