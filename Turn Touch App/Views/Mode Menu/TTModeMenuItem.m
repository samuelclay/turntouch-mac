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
                                            NSWidth(collectionRect) / 2, 48)]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [(TTModeMenuContainer *)[self view] setModeName:(NSString *)representedObject];
}

//- (void)changeModeDropdown:(id)sender {
//    NSString *newModeClassName = [appDelegate.modeMap.availableModeClassNames
//                                  objectAtIndex:[sender indexOfSelectedItem]];
//    [appDelegate.modeMap changeDirection:modeDirection toMode:newModeClassName];
//    isModeChangeActive = NO;
//    [self setupMode];
//    [self setNeedsDisplay:YES];
//}
//
//- (void)hidePopupMenu {
//    if (isModeChangeActive) {
//        isModeChangeActive = NO;
//        [self setNeedsDisplay:YES];
//    }
//}

@end
