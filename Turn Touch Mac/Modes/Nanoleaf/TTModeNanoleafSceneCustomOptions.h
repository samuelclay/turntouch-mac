//
//  TTModeNanoleafSceneOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@class TTModeNanoleaf;

@interface TTModeNanoleafSceneCustomOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSPopUpButton *scenePopup;
@property (nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (nonatomic) IBOutlet NSButton *refreshButton;
@property (nonatomic) IBOutlet NSPopUpButton *doubleTapScenePopup;
@property (nonatomic) IBOutlet NSProgressIndicator *doubleTapSpinner;
@property (nonatomic) IBOutlet NSButton *doubleTapRefreshButton;

- (IBAction)didChangeScene:(id)sender;
- (IBAction)didClickRefresh:(id)sender;

@end
