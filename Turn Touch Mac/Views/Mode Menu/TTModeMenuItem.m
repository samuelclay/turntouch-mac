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
    
    [self setView:[[TTModeMenuItemView alloc]
                   initWithFrame:NSMakeRect(0, 0,
                                            0, MENU_ITEM_HEIGHT)]];
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
        } else if (menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
            [(TTModeMenuItemView *)[self view] setChangeActionName:representedObject];
        }
    } else if ([appDelegate.modeMap.availableModes containsObject:representedObject]) {
        [(TTModeMenuItemView *)[self view] setModeName:representedObject];
    } else if ([appDelegate.modeMap.availableActions containsObject:representedObject]) {
        [(TTModeMenuItemView *)[self view] setActionName:representedObject];
    }
}

@end
