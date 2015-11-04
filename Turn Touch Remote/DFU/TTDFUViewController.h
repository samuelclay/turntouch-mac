//
//  TTDFUViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/3/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DFUOperations.h"
#import "TTAppDelegate.h"

@interface TTDFUViewController : NSViewController <DFUOperationsDelegate> {
    TTAppDelegate *appDelegate;
}

@end
