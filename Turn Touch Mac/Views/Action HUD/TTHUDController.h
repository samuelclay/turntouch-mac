//
//  TTHUDController.h
//  Turn Touch Remote
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
- (void)toastActiveAction:(NSString *)actionName inDirection:(TTModeDirection)direction;
- (void)toastDoubleAction:(NSString *)actionName inDirection:(TTModeDirection)direction;
- (void)holdToastActiveAction:(NSString *)actionName inDirection:(TTModeDirection)direction;
- (void)releaseToastActiveAction;

@end
