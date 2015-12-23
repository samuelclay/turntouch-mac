//
//  TTBatchActionHeaderView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTBatchActionHeaderView : NSView {
    TTAppDelegate *appDelegate;
    NSDictionary *titleAttributes;
    NSImage *modeImage;
}

@property (nonatomic) TTMode *mode;
@property (nonatomic) TTAction *batchAction;

- (instancetype)initWithTempMode:(TTMode *)_mode;
- (instancetype)initWithBatchAction:(TTAction *)_batchAction;

@end
