//
//  TTButtonTimer.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTDiamond.h"

@class TTAppDelegate;

@interface TTButtonTimer : NSObject {
    TTAppDelegate *appDelegate;
    TTMode activeMode;
    NSTimer *activeModeTimer;
}

- (void)readButtons:(NSArray *)buttons;
- (void)activeModeTimerFire:(NSTimer *)timer;
- (void)selectActiveMode;
- (void)activateButton;
- (void)deactivateButton;

@end
