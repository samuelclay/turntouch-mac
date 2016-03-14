//
//  TTModalFTUXViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/13/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalFTUXView.h"

@interface TTModalFTUXView ()

@end

@implementation TTModalFTUXView

@synthesize labelTitle;
@synthesize labelSubtitle;
@synthesize imageView;

- (instancetype)initWithFTUX:(TTModalFTUX)_modalFTUX {
    self = [super initWithNibName:@"TTModalFTUXView" bundle:nil];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        modalFTUX = _modalFTUX;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (modalFTUX == MODAL_FTUX_INTRO) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_action"]];
        [labelTitle setStringValue:@"Here's how it works"];
        [labelSubtitle setStringValue:@""];
    } else if (modalFTUX == MODAL_FTUX_ACTIONS) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_change_action"]];
        [labelTitle setStringValue:@"Each button performs an action"];
        [labelSubtitle setStringValue:@""];
    } else if (modalFTUX == MODAL_FTUX_MODES) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_mode"]];
        [labelTitle setStringValue:@"Press and hold"];
        [labelSubtitle setStringValue:@""];
    } else if (modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_doubletap"]];
        [labelTitle setStringValue:@"Each button can do multiple actions"];
        [labelSubtitle setStringValue:@""];
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_change_mode"]];
        [labelTitle setStringValue:@"Customize each button"];
        [labelSubtitle setStringValue:@""];
    }
}

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
