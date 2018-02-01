
//  TTHUDController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTHUDController.h"
#import "NSObject+CancelableBlocks.h"
#import "TTMode.h"

@interface TTHUDController ()

@end

@implementation TTHUDController

@synthesize modeHUDController;
@synthesize actionHUDController;

- (instancetype)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        modeHUDController = [[TTModeHUDWindowController alloc]
                             initWithWindowNibName:@"TTModeHUDView"];
        actionHUDController = [[TTActionHUDWindowController alloc]
                               initWithWindowNibName:@"TTActionHUDView"];
    }
    return self;
}

- (BOOL)showActionHud {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"TT:pref:show_action_hud"];
}

- (BOOL)showModeHud {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"TT:pref:show_mode_hud"];
}

#pragma mark - Toasts

- (void)toastActiveMode {
    if (![self showModeHud]) return;
    
    [modeHUDController fadeIn:YES];
    
    if (modeOperation) [modeOperation cancel];
    
    modeOperation = [self performBlock:^{
        [modeHUDController fadeOut:nil];
    } afterDelay:2.5 cancelPreviousRequest:YES];
}

- (void)holdToastActiveMode:(BOOL)animate {
    if (![self showModeHud]) return;

    if (modeOperation) [modeOperation cancel];

    [modeHUDController fadeIn:animate];
}

- (void)activateHudMenu {
    if (modeOperation) [modeOperation cancel];
    
    [modeHUDController fadeIn:YES];
}

- (void)releaseToastActiveMode {
    [modeHUDController fadeOut:nil];
}

- (void)teaseMode:(TTModeDirection)direction {
    if (![self showModeHud]) return;

    [modeHUDController teaseMode:direction];
}

- (void)hideModeTease {
    [modeHUDController fadeOut:nil];
}

- (void)toastActiveAction:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (![self showActionHud]) return;

    TTMode *mode = NSAppDelegate.modeMap.selectedMode;
    ActionLayout layout = [mode layoutInDirection:direction];
    NSTimeInterval delay = layout == ACTION_LAYOUT_IMAGE_TITLE ? 2.5 : 0.9;
    if (!actionName) actionName = [mode actionNameInDirection:direction];
    
    [actionHUDController fadeIn:actionName inDirection:direction];
    
    if (actionOperation) [actionOperation cancel];
    
    actionOperation = [self performBlock:^{
        [actionHUDController slideOut:nil];
    } afterDelay:delay cancelPreviousRequest:YES];
}

- (void)toastDoubleAction:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (![self showActionHud]) return;

    TTMode *mode = NSAppDelegate.modeMap.selectedMode;
    ActionLayout layout = [mode layoutInDirection:direction];
    NSTimeInterval delay = layout == ACTION_LAYOUT_IMAGE_TITLE ? 2.5 : 1.25;
    
    [actionHUDController fadeIn:actionName inDirection:direction withMode:nil buttonMoment:BUTTON_MOMENT_DOUBLE];
    
    if (actionOperation) [actionOperation cancel];
    
    actionOperation = [self performBlock:^{
        [actionHUDController slideOut:nil];
    } afterDelay:delay cancelPreviousRequest:YES];
}

- (void)holdToastActiveAction:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (![self showActionHud]) return;

    if (actionOperation) [actionOperation cancel];
    
    if (direction == NO_DIRECTION) {
        [actionHUDController fadeOut:nil];
    } else {
        [actionHUDController fadeIn:actionName inDirection:direction withMode:nil buttonMoment:BUTTON_MOMENT_PRESSDOWN];
    }
}

- (void)releaseToastActiveAction {
    [actionHUDController slideOut:nil];
}

@end
