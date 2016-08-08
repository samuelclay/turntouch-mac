//
//  TTModeNews.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeNewsWindowController.h"

typedef enum {
    TTModeNewsStateBrowser = 0,
    TTModeNewsStateMenu = 1,
} TTModeNewsState;

@interface TTModeNews : TTMode {
    TTModeNewsWindowController *newsWindowController;
    TTModeNewsState state;
    BOOL closed;
    BOOL timerActive;
}

- (BOOL)checkClosed;
- (void)startHideMouseTimer;

@end
