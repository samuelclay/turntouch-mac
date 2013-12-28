//
//  TTOptionsActionTitle.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondView.h"

@class TTAppDelegate;

@interface TTOptionsActionTitle : NSView {
    TTAppDelegate *appDelegate;
    NSDictionary *titleAttributes;
    TTDiamondView *diamondView;
}


@end
