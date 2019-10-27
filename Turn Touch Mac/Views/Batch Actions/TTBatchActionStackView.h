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

@interface TTBatchActionStackView : NSStackView <NSStackViewDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) NSString *tempMode;
@property (nonatomic, strong) NSMutableArray *actionOptionsViewControllers;
@property (nonatomic, strong) NSMutableDictionary *changeActionMenuViewControllers;
@property (nonatomic, strong) NSMutableDictionary *changeActionMenuViewConstraints;

- (void)toggleChangeActionMenu:(TTAction *)batchAction visible:(BOOL)visible;
- (void)assembleViews:(BOOL)animated;

@end
