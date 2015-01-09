//
//  TTOptionsView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/26/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTOptionsModeTitle.h"
#import "TTOptionsActionTitle.h"
#import "TTOptionsDetailView.h"

@class TTAppDelegate;
@class TTOptionsModeTitle;
@class TTOptionsActionTitle;
@class TTOptionsDetailView;
@class TTOptionsDetailViewController;

@interface TTOptionsView : NSView {
    TTAppDelegate *appDelegate;
    TTOptionsModeTitle *modeTitleView;
    TTOptionsActionTitle *actionTitleView;
}

@property (nonatomic) NSScrollView *scrollView;
@property (nonatomic) TTOptionsDetailViewController *modeOptionsViewController;
@property (nonatomic) TTOptionsDetailView *actionOptionsView;

- (void)redrawOptions;

@end
