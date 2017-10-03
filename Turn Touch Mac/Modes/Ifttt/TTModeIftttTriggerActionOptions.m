//
//  TTModeIftttTriggerActionOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttTriggerActionOptions.h"
#import "TTModeIftttAuthViewController.h"

@interface TTModeIftttTriggerActionOptions ()

@end

@implementation TTModeIftttTriggerActionOptions

@synthesize modeIfttt;
@synthesize authPopover;
@synthesize settingsButton;
@synthesize chooseButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [settingsButton setImage:[NSImage imageNamed:@"settings"]];
    modeIfttt = (TTModeIfttt *)self.action.mode;
    [self buildSettingsMenu:YES];
}

- (IBAction)clickRecipeButton:(id)sender {
    [modeIfttt registerTriggers:^{
        TTModeIftttAuthViewController *iftttAuthViewController = [[TTModeIftttAuthViewController alloc] init];
        iftttAuthViewController.modeIfttt = self.modeIfttt;
        
        authPopover = [[NSPopover alloc] init];
        [authPopover setContentSize:NSMakeSize(420, 480)];
        [authPopover setBehavior:NSPopoverBehaviorTransient];
        [authPopover setAnimates:YES];
        [authPopover setContentViewController:iftttAuthViewController];
        
        NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                        toView:appDelegate.panelController.backgroundView];
        
        iftttAuthViewController.authPopover = authPopover;
        [authPopover showRelativeToRect:entryRect
                                 ofView:appDelegate.panelController.backgroundView
                          preferredEdge:NSMinYEdge];
        
        [iftttAuthViewController openRecipe:self.action.direction];
    }];
}


#pragma mark - Settings menu

- (IBAction)showIftttMenu:(id)sender {
    [NSMenu popUpContextMenu:settingsMenu
                   withEvent:[NSApp currentEvent]
                     forView:sender];
}

- (IBAction)replaceRecipe:(id)sender {
    [modeIfttt registerTriggers:^{
        [self.modeIfttt purgeRecipe:self.action.direction callback:^{
            [self clickRecipeButton:chooseButton];
        }];
    }];
}

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!settingsMenu) {
        settingsMenu = [[NSMenu alloc] initWithTitle:@"Action Menu"];
        [settingsMenu setDelegate:self];
        [settingsMenu setAutoenablesItems:NO];
    } else {
        [settingsMenu removeAllItems];
    }
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Replace this recipe..." action:@selector(replaceRecipe:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
}

@end
