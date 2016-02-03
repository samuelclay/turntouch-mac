//
//  TTHUDMenuView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/28/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTAppDelegate;

@protocol TTHUDMenuDelegate <NSObject>

@required

@optional
- (NSArray *)menuOptions;
- (NSInteger)menuInitialPosition;
- (NSInteger)menuWidth;

@end

@interface TTHUDMenuView : NSVisualEffectView
<TTHUDMenuDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    TTAppDelegate *appDelegate;
    NSTableView *tableView;
    NSInteger highlightedRow;
}

@property (nonatomic) IBOutlet NSLayoutConstraint *offsetConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic) IBOutlet NSTableView *tableView;
@property (nonatomic) IBOutlet NSScrollView *scrollView;
@property (nonatomic) IBOutlet NSClipView *clipView;
@property (nonatomic) id<TTHUDMenuDelegate> delegate;

- (void)slideIn;
- (void)slideOut;
- (void)menuUp;
- (void)menuDown;
- (void)selectMenuItem;

@end
