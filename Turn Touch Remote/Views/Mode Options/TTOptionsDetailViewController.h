//
//  TTOptionsViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTTabView.h"
#import "TTAction.h"

@class TTAppDelegate;
@class TTAction;

@interface TTOptionsDetailViewController : NSViewController <NSTabViewDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet TTTabView *tabView;
@property (nonatomic) TTMenuType menuType;
@property (nonatomic) TTAction *action;
@property (nonatomic) TTMode *mode;


- (void)animateBlock:(void (^)())block;

@end
