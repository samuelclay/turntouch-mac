//
//  TTHUDController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTHUDWindowController.h"
#import "TTAppDelegate.h"

@class TTHUDWindowController;

@interface TTHUDController : NSObject {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet TTHUDWindowController *hudViewController;

- (void)toastActiveMode;
- (void)toastActiveAction;

@end
