//
//  TTModeWebMenuView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModeWebMenuView : NSVisualEffectView
<NSTableViewDelegate, NSTableViewDataSource> {
    TTAppDelegate *appDelegate;
    NSTableView *tableView;
    NSArray *menuOptions;
    NSInteger highlightedRow;
}

@property (nonatomic) IBOutlet NSLayoutConstraint *offsetConstraint;
@property (nonatomic) IBOutlet NSTableView *tableView;
@property (nonatomic) IBOutlet NSScrollView *scrollView;
@property (nonatomic) IBOutlet NSClipView *clipView;;

- (void)slideIn;
- (void)slideOut;
- (void)menuUp;
- (void)menuDown;

@end
