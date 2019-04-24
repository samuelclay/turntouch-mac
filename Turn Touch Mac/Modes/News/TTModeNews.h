//
//  TTModeNews.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/8/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeNewsWindowController.h"
#import "TTModeNewsNewsBlur.h"

typedef enum {
    TTModeNewsStateBrowser = 0,
    TTModeNewsStateMenu = 1,
} TTModeNewsState;

@interface TTModeNews : TTMode

@property (nonatomic) TTModeNewsNewsBlur *newsblur;

- (BOOL)checkClosed;
- (void)startHideMouseTimer;

@end
