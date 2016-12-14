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
    NSRect collectionRect = {0};
    TTModeMenuCollectionView *cv = (TTModeMenuCollectionView *)self.collectionView;
    
    menuType = cv.menuType;
    if (cv.menuType == MODE_MENU_TYPE || cv.menuType == ADD_MODE_MENU_TYPE) {
        collectionRect = appDelegate.panelController.backgroundView.modeMenu.frame;
    } else if (cv.menuType == ACTION_MENU_TYPE || cv.menuType == ADD_ACTION_MENU_TYPE) {
        collectionRect = appDelegate.panelController.backgroundView.actionMenu.frame;
    }
    [self setView:[[TTModeMenuItemView alloc]
                   initWithFrame:NSMakeRect(0, 0,
                                            NSWidth(collectionRect) / 2,
                                            MENU_ITEM_HEIGHT)]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    if (!representedObject) return;
    
    if ([representedObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *object = (NSDictionary *)representedObject;
        menuType = [[object objectForKey:@"type"] intValue];
        if (menuType == ADD_MODE_MENU_TYPE) {
            [(TTModeMenuItemView *)[self view] setAddModeName:representedObject];
        } else if (menuType == ADD_ACTION_MENU_TYPE) {
            [(TTModeMenuItemView *)[self view] setAddActionName:representedObject];
        }
    } else if ([appDelegate.modeMap.availableModes containsObject:representedObject]) {
        [(TTModeMenuItemView *)[self view] setModeName:representedObject];
    } else if ([appDelegate.modeMap.availableActions containsObject:representedObject]) {
        [(TTModeMenuItemView *)[self view] setActionName:representedObject];
    }
}

@end
