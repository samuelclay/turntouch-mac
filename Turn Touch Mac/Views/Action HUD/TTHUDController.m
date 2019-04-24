
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

@property (nonatomic, strong) NSBlockOperation *modeOperation;
@property (nonatomic, strong) NSBlockOperation *actionOperation;

@end

@implementation TTHUDController

- (instancetype)init {
    if (self = [super init]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.modeHUDController = [[TTModeHUDWindowController alloc]
                             initWithWindowNibName:@"TTModeHUDView"];
        self.actionHUDController = [[TTActionHUDWindowController alloc]
                               initWithWindowNibName:@"TTActionHUDView"];
    }
    return self;
}

- (BOOL)showActionHud {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"TT:pref:show_action_hud"];
}

- (BOOL)hudEnabled {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"TT:pref:enable_hud"];
}

- (BOOL)showModeHud {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"TT:pref:show_mode_hud"];
}

#pragma mark - Toasts

- (void)toastActiveMode {
    if (![self showModeHud]) return;
    
    [self.modeHUDController fadeIn:YES];
    
    if (self.modeOperation) [self.modeOperation cancel];
    
    self.modeOperation = [self performBlock:^{
        [self.modeHUDController fadeOut:nil];
    } afterDelay:2.5 cancelPreviousRequest:YES];
}

- (void)holdToastActiveMode:(BOOL)animate {
    if (![self showModeHud]) return;

    if (self.modeOperation) [self.modeOperation cancel];

    [self.modeHUDController fadeIn:animate];
}

- (void)activateHudMenu {
    if (self.modeOperation) [self.modeOperation cancel];
    
    if ([self hudEnabled]) {
        [self.modeHUDController fadeIn:YES];
    } else {
        [self releaseToastActiveMode];
    }
}

- (void)releaseToastActiveMode {
    [self.modeHUDController fadeOut:nil];
}

- (void)teaseMode:(TTModeDirection)direction {
    if (![self showModeHud]) return;

    [self.modeHUDController teaseMode:direction];
}

- (void)hideModeTease {
    [self.modeHUDController fadeOut:nil];
}

- (void)toastActiveAction:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (![self showActionHud]) return;

    TTMode *mode = NSAppDelegate.modeMap.selectedMode;
    mode.action = [[TTAction alloc] initWithActionName:[mode actionNameInDirection:direction] direction:direction];
    ActionLayout layout = [mode layoutInDirection:direction];
    NSTimeInterval delay = layout == ACTION_LAYOUT_IMAGE_TITLE ? 2.5 : 0.9;
    if (!actionName) actionName = [mode actionNameInDirection:direction];
    
    [self.actionHUDController fadeIn:actionName inDirection:direction];
    
    if (self.actionOperation) [self.actionOperation cancel];
    
    self.actionOperation = [self performBlock:^{
        [self.actionHUDController slideOut:nil];
    } afterDelay:delay cancelPreviousRequest:YES];
}

- (void)toastDoubleAction:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (![self showActionHud]) return;

    TTMode *mode = NSAppDelegate.modeMap.selectedMode;
    mode.action = [[TTAction alloc] initWithActionName:[mode actionNameInDirection:direction] direction:direction];
    ActionLayout layout = [mode layoutInDirection:direction];
    NSTimeInterval delay = layout == ACTION_LAYOUT_IMAGE_TITLE ? 2.5 : 1.25;
    
    [self.actionHUDController fadeIn:actionName inDirection:direction withMode:nil buttonMoment:BUTTON_MOMENT_DOUBLE];
    
    if (self.actionOperation) [self.actionOperation cancel];
    
    self.actionOperation = [self performBlock:^{
        [self.actionHUDController slideOut:nil];
    } afterDelay:delay cancelPreviousRequest:YES];
}

- (void)holdToastActiveAction:(NSString *)actionName inDirection:(TTModeDirection)direction {
    if (![self showActionHud]) return;

    if (self.actionOperation) [self.actionOperation cancel];
    
    if (direction == NO_DIRECTION) {
        [self.actionHUDController fadeOut:nil];
    } else {
        [self.actionHUDController fadeIn:actionName inDirection:direction withMode:nil buttonMoment:BUTTON_MOMENT_PRESSDOWN];
    }
}

- (void)releaseToastActiveAction {
    [self.actionHUDController slideOut:nil];
}

@end
