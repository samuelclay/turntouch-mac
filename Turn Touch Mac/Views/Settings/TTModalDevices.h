//
//  TTModalDevices.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModalDevices : NSViewController
<NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet NSTableView *devicesTable;

- (IBAction)closeModal:(id)sender;

@end
