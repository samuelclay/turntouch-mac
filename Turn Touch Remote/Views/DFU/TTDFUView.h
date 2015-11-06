//
//  TTDFUView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DFUOperations.h"
#import "TTAppDelegate.h"
#import "TTDevice.h"

@interface TTDFUView : NSStackView <NSStackViewDelegate, DFUOperationsDelegate> {
    TTAppDelegate *appDelegate;

    TTDevice *currentDevice;
}

-(void)performDFU:(TTDevice *)device;

@end
