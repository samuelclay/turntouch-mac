//
//  TTBatchActionStackView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTBatchActionStackView : NSStackView
<NSStackViewDelegate> {
    TTAppDelegate *appDelegate;
    NSLayoutConstraint *tempHeaderConstraint;
}

@property (nonatomic) NSString *tempMode;

- (void)assembleViews;

@end
