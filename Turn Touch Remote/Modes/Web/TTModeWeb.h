//
//  TTModeWeb.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "TTModeWebWindowController.h"

typedef enum {
    TTModeWebStateBrowser = 0,
    TTModeWebStateMenu = 1,
} TTModeWebState;

@interface TTModeWeb : TTMode {
    TTModeWebWindowController *webWindowController;
    TTModeWebState state;
}

@end
