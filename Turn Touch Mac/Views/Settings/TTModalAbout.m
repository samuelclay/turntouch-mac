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
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    [self.versionLabel setStringValue:[NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
}

- (void)closeModal:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

- (void)checkForUpdates:(id)sender {
    // The shared updater is owned by the app delegate (see TTAppDelegate), so it
    // outlives this view controller. The nib used to instantiate its own SUUpdater
    // top-level object, which was released right after the view loaded, leaving the
    // button targeting a dead object -> clicking did nothing.
    [self.appDelegate checkForUpdates:sender];
}

@end
