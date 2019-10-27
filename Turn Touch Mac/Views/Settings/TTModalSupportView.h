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
#import "TTPairingSpinner.h"

@interface TTModalSupportView : NSViewController <NSTextFieldDelegate, NSTextViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet TTSegmentedControl *supportSegmentedControl;
@property (nonatomic) IBOutlet NSTextField *supportLabel;
@property (nonatomic) IBOutlet NSTextView *supportComment;
@property (nonatomic) IBOutlet NSTextField *supportEmail;
@property (nonatomic) IBOutlet TTPairingSpinner *spinner;
@property (nonatomic) IBOutlet NSImageView *successImage;

- (IBAction)closeModal:(id)sender;
- (IBAction)chooseSupportSegmentedControl:(id)sender;
- (void)submitSupport;

@end
