//
//  TTModalSupportView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModalSupportView : NSViewController {
    TTAppDelegate *appDelegate;
}

- (IBAction)closeModal:(id)sender;

@end
