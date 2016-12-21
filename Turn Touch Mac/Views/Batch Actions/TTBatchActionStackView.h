//
//  TTBatchActionStackView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMenuContainer.h"

extern const NSInteger BATCH_ACTION_HEADER_HEIGHT;

@class TTModeMenuContainer;

@interface TTBatchActionStackView : NSStackView
<NSStackViewDelegate> {
    TTAppDelegate *appDelegate;
    NSLayoutConstraint *tempHeaderConstraint;
    
    NSString *changeActionBatchActionKey;
}

@property (nonatomic) NSString *tempMode;
@property (nonatomic, strong) NSMutableArray *actionOptionsViewControllers;
@property (nonatomic, strong) NSMutableDictionary *changeActionMenuViewControllers;
@property (nonatomic, strong) NSMutableDictionary *changeActionMenuViewConstraints;

- (void)toggleChangeActionMenu:(NSString *)batchActionKey withMode:(TTMode *)mode;
- (void)assembleViews:(BOOL)animated;

@end
