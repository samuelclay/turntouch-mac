//
//  TTDiamondLabels.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondLabel.h"
#import "TTDiamondView.h"

@class TTAppDelegate;
@class TTDiamondLabel;

@interface TTDiamondLabels : NSView

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) NSRect diamondRect;
@property (nonatomic, readwrite) BOOL interactive;
@property (nonatomic, readwrite) BOOL isHud;

- (id)initWithInteractive:(BOOL)_interactive;
- (id)initWithInteractive:(BOOL)_interactive isHud:(BOOL)_isHud;
- (void)setMode:(TTMode *)mode;
- (void)pressedChange:(NSButton *)sender;

@end
