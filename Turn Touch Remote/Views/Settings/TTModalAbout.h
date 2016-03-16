//
//  TTModalAbout.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModalAbout : NSViewController {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet NSTextField *versionLabel;

- (IBAction)closeModal:(id)sender;

@end
