//
//  TTModeHueSceneRandom.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/15/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTSegmentedControl.h"

@class TTModeHue;

@interface TTModeHueSceneRandomOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet TTSegmentedControl *segRandomColors;
@property (nonatomic) IBOutlet TTSegmentedControl *segRandomBrightness;
@property (nonatomic) IBOutlet TTSegmentedControl *segRandomSaturation;

- (IBAction)changeRandomColors:(id)sender;
- (IBAction)changeRandomBrightness:(id)sender;
- (IBAction)changeRandomSaturation:(id)sender;

@end
