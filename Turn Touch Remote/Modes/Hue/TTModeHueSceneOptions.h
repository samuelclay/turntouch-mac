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
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic) IBOutlet NSButton *refreshButton;

- (IBAction)didChangeScene:(id)sender;
- (IBAction)didClickRefresh:(id)sender;

@end
