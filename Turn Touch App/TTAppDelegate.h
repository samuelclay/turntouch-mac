//
//  TTAppDelegate.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMenubarController.h"
#import "TTPanelDelegate.h"
#import "TTPanelController.h"
#import "TTSerialMonitor.h"
#import "TTDiamond.h"

@class TTPanelController;

@interface TTAppDelegate : NSObject
<NSApplicationDelegate, TTPanelControllerDelegate>

@property (nonatomic, strong) TTMenubarController *menubarController;
@property (nonatomic, strong, readonly) TTPanelController *panelController;
@property (nonatomic, strong) TTSerialMonitor *serialMonitor;
@property (nonatomic) TTDiamond *diamond;

- (IBAction)togglePanel:(id)sender;

@end
