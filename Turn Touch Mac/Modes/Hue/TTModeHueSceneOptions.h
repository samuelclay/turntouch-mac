//
//  TTModeHueSceneEarlyEvening.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTModeHuePicker.h"

extern NSString *const kHueRoom;
extern NSString *const kHueScene;
extern NSString *const kDoubleTapHueScene;

@class TTModeHue;

@interface TTModeHueSceneOptions : TTModeHuePicker

@property (nonatomic) IBOutlet NSPopUpButton *scenePopup;
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic) IBOutlet NSButton *refreshButton;
@property (nonatomic) IBOutlet NSPopUpButton *doubleTapScenePopup;
@property (nonatomic) IBOutlet NSProgressIndicator *doubleTapSpinner;
@property (nonatomic) IBOutlet NSButton *doubleTapRefreshButton;

- (IBAction)didChangeScene:(id)sender;
- (IBAction)didClickRefresh:(id)sender;

@end
