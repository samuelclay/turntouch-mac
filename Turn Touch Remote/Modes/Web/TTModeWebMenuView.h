//
//  TTModeWebMenuView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTModeWebMenuView : NSVisualEffectView
<NSTableViewDelegate, NSTableViewDataSource> {
    NSTableView *tableView;
    NSArray *menuOptions;
}

@property (nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic) IBOutlet NSTableView *tableView;
@property (nonatomic) IBOutlet NSScrollView *scrollView;
@property (nonatomic) IBOutlet NSClipView *clipView;;

- (void)slideIn;
- (void)slideOut;

@end
