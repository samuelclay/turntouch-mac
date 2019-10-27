//
//  TTPanelController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBackgroundView.h"
#import "TTStatusItemView.h"
#import "TTPanelDelegate.h"
#import "TTPanelArrowView.h"
#import "TTPanelStates.h"

#pragma mark -

@class TTBackgroundView;

@interface TTPanelController : NSWindowController <NSWindowDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet TTBackgroundView *backgroundView;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic) BOOL preventClosing;
@property (nonatomic, unsafe_unretained, readonly) id<TTPanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<TTPanelControllerDelegate>)delegate;
- (NSRect)statusRectForWindow:(NSWindow *)window;

- (void)openPanel;
- (BOOL)closePanel;
- (void)openModal:(TTModalPairing)modal;

@end
