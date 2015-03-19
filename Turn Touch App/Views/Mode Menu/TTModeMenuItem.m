//
//  TTModeMenuItem.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuCollectionView.h"
#import "TTModeMenuItem.h"

@implementation TTModeMenuItem

- (void)loadView {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    NSRect collectionRect;
    TTModeMenuCollectionView *cv = (TTModeMenuCollectionView *)self.collectionView;

    if (cv.menuType == MODE_MENU_TYPE) {
        collectionRect = appDelegate.panelController.backgroundView.modeMenu.frame;
    } else if (cv.menuType == ACTION_MENU_TYPE) {
        collectionRect = appDelegate.panelController.backgroundView.actionMenu.frame;
    }
    [self setView:[[TTModeMenuItemView alloc]
                   initWithFrame:NSMakeRect(0, 0,
                                            NSWidth(collectionRect) / 2,
                                            MENU_ITEM_HEIGHT)]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    if ([appDelegate.modeMap.availableModes containsObject:representedObject]) {
        [(TTModeMenuItemView *)[self view] setModeName:representedObject];
    } else if ([appDelegate.modeMap.availableActions containsObject:representedObject]) {
        [(TTModeMenuItemView *)[self view] setActionName:representedObject];
    }
}

@end
