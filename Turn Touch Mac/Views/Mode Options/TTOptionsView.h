//
//  TTOptionsView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/26/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTOptionsActionTitle.h"
#import "TTOptionsDetailView.h"

@class TTAppDelegate;
@class TTOptionsModeTitle;
@class TTOptionsActionTitle;
@class TTOptionsDetailView;
@class TTOptionsDetailViewController;

@interface TTOptionsView : NSView

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) NSScrollView *scrollView;
@property (nonatomic) TTOptionsDetailViewController *modeOptionsViewController;
@property (nonatomic) TTOptionsDetailViewController *actionOptionsViewController;

- (void)redrawOptions;

@end
