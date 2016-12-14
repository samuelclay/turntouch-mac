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

@interface TTOptionsActionTitle : NSView {
    TTAppDelegate *appDelegate;
    NSDictionary *titleAttributes;
    TTDiamondView *diamondView;
    TTChangeButtonView *changeButton;
}

@property (nonatomic) IBOutlet TTChangeButtonView *changeButton;

@end
