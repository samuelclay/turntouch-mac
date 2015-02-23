//
//  TTHUDController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeHUDWindowController.h"
#import "TTActionHUDWindowController.h"
#import "TTAppDelegate.h"

@class TTModeHUDWindowController;
@class TTActionHUDWindowController;

@interface TTHUDController : NSObject {
    TTAppDelegate *appDelegate;
    NSBlockOperation *modeOperation;
    NSBlockOperation *actionOperation;
    
}

@property (nonatomic) IBOutlet TTModeHUDWindowController *modeHUDController;
@property (nonatomic) IBOutlet TTActionHUDWindowController *actionHUDController;

- (void)toastActiveMode;
- (void)holdToastActiveMode:(BOOL)animate;
- (void)releaseToastActiveMode;
- (void)teaseMode:(TTModeDirection)direction;
- (void)hideModeTease;
- (void)toastActiveAction:(TTModeDirection)direction;
- (void)holdToastActiveAction:(TTModeDirection)direction;
- (void)releaseToastActiveAction;

@end
