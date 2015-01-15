//
//  TTModeHueSceneEarlyEvening.h
//  Turn Touch App
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

extern NSString *const kHueScene;
extern NSString *const kHueDuration;

@class TTModeHue;

@interface TTModeHueSceneOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSPopUpButton *scenePopup;
@property (nonatomic) IBOutlet NSTextField *durationLabel;
@property (nonatomic) IBOutlet NSSlider *durationSlider;

- (IBAction)didChangeScene:(id)sender;
- (IBAction)didChangeDuration:(id)sender;

@end
