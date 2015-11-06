//
//  TTDFUView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTDFUView : NSView <NSStackViewDelegate> {
    TTAppDelegate *appDelegate;
    NSStackView *stackView;
}

@end
