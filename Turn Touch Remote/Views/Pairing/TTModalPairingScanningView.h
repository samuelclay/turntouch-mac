//
//  TTModalPairingScanningView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"

@interface TTModalPairingScanningView : NSViewController    {
    TTAppDelegate *appDelegate;
    NSTimer *countdownTimer;
    NSTimeInterval spinnerBeginTime;
}

@property (nonatomic) IBOutlet NSBox *titleBox;
@property (nonatomic) IBOutlet NSTextField *labelPressButtons;
@property (nonatomic) IBOutlet NSProgressIndicator *countdownIndicator;
@property (nonatomic) IBOutlet NSView *diamondViewPlaceholder;
@property (nonatomic) IBOutlet TTDiamondView *diamondView;
@property (nonatomic) IBOutlet NSView *spinnerScanning;
@property (nonatomic) IBOutlet NSTextField *labelScanning;
@property (nonatomic) IBOutlet NSButton *closeButton;

- (IBAction)closeModal:(id)sender;

@end
