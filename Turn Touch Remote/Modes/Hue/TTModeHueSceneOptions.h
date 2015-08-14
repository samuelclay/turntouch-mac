//
//  TTModeHueSceneEarlyEvening.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

extern NSString *const kHueScene;

@class TTModeHue;

@interface TTModeHueSceneOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSPopUpButton *scenePopup;

- (IBAction)didChangeScene:(id)sender;

@end
