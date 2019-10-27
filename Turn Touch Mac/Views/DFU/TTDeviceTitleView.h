//
//  TTDeviceTitleView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTChangeButtonView.h"

@interface TTDeviceTitleView : NSView <NSMenuDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) TTDevice *device;
@property (nonatomic) NSProgressIndicator *progress;

- (instancetype)initWithDevice:(TTDevice *)_device;
- (void)disableUpgrade;
- (void)enableUpgrade;
- (void)setProgressPercentage:(CGFloat)percentage;
- (void)startIndeterminateProgress;

@end
