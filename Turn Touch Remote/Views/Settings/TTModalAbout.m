//
//  TTModalAbout.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalAbout.h"

@interface TTModalAbout ()

@end

@implementation TTModalAbout

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (TTAppDelegate *)[NSApp delegate];
}

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
