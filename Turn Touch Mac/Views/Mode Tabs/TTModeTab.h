//
//  TTModeTab.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTModeMap.h"
#import "TTDiamondView.h"
#import "TTMode.h"

@class TTAppDelegate;
@class TTDiamondView;
@class TTMode;

@interface TTModeTab : NSView <NSMenuDelegate>

@property (nonatomic, strong) TTAppDelegate *appDelegate;

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction;

@end
