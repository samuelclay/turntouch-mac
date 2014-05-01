//
//  TTModeMenuItem.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuItem.h"

@implementation TTModeMenuItem

- (void)loadView {
    appDelegate = [NSApp delegate];
    NSRect collectionRect = appDelegate.panelController.backgroundView.modeMenu.frame;
    [self setView:[[TTModeMenuItemView alloc]
                   initWithFrame:NSMakeRect(0, 0,
                                            NSWidth(collectionRect) / 2, MENU_ITEM_HEIGHT)]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [(TTModeMenuItemView *)[self view] setModeName:(NSString *)representedObject];
}

@end
