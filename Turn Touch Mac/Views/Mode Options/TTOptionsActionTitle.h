//
//  TTOptionsActionTitle.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondView.h"
#import "TTChangeButtonView.h"

@class TTAppDelegate;

@interface TTOptionsActionTitle : NSView <NSTextFieldDelegate> {
    TTAppDelegate *appDelegate;
    TTDiamondView *diamondView;
    TTChangeButtonView *changeButton;
    NSButton *renameButton;
    NSTextField *titleLabel;
    NSLayoutConstraint *titleWidthConstraint;
    BOOL editingTitle;
}

@property (nonatomic) IBOutlet TTChangeButtonView *changeButton;

@end
