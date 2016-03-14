//
//  TTModalFTUXViewController.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/13/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTPanelStates.h"

@interface TTModalFTUXView : NSViewController {
    TTAppDelegate *appDelegate;
    TTModalFTUX modalFTUX;
}

@property (nonatomic) IBOutlet NSBox *box;
@property (nonatomic) IBOutlet NSTextField *labelTitle;
@property (nonatomic) IBOutlet NSTextField *labelSubtitle;
@property (nonatomic) IBOutlet NSImageView *imageView;
@property (nonatomic) IBOutlet NSButton *closeButton;

- (instancetype)initWithFTUX:(TTModalFTUX)modalFTUX;
- (IBAction)closeModal:(id)sender;

@end
