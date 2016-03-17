//
//  TTModalSupportView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTSegmentedControl.h"

@interface TTModalSupportView : NSViewController <NSTextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) IBOutlet TTSegmentedControl *supportSegmentedControl;
@property (nonatomic) IBOutlet NSTextField *supportLabel;
@property (nonatomic) IBOutlet NSTextField *supportComment;
@property (nonatomic) IBOutlet NSTextField *supportEmail;

- (IBAction)closeModal:(id)sender;
- (IBAction)chooseSupportSegmentedControl:(id)sender;
- (void)submitSupport;

@end
