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

@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;

@end

@implementation TTModeIftttTriggerActionOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.settingsButton setImage:[NSImage imageNamed:@"settings"]];
    self.modeIfttt = (TTModeIfttt *)self.action.mode;
    [self buildSettingsMenu:YES];
}

- (IBAction)clickRecipeButton:(id)sender {
    [self.modeIfttt registerTriggers:^{
        TTModeIftttAuthViewController *iftttAuthViewController = [[TTModeIftttAuthViewController alloc] init];
        iftttAuthViewController.modeIfttt = self.modeIfttt;
        
        self.authPopover = [[NSPopover alloc] init];
        [self.authPopover setContentSize:NSMakeSize(420, 480)];
        [self.authPopover setBehavior:NSPopoverBehaviorTransient];
        [self.authPopover setAnimates:YES];
        [self.authPopover setContentViewController:iftttAuthViewController];
        
        NSRect entryRect = [sender convertRect:((NSButton *)sender).bounds
                                        toView:self.appDelegate.panelController.backgroundView];
        
        iftttAuthViewController.authPopover = self.authPopover;
        [self.authPopover showRelativeToRect:entryRect
                                 ofView:self.appDelegate.panelController.backgroundView
                          preferredEdge:NSMinYEdge];
        
        [iftttAuthViewController openRecipe:self.action.direction];
    }];
}


#pragma mark - Settings menu

- (IBAction)showIftttMenu:(id)sender {
    [NSMenu popUpContextMenu:self.settingsMenu
                   withEvent:[NSApp currentEvent]
                     forView:sender];
}

- (IBAction)replaceRecipe:(id)sender {
    [self.modeIfttt registerTriggers:^{
        [self.modeIfttt purgeRecipe:self.action.direction callback:^{
            [self clickRecipeButton:self.chooseButton];
        }];
    }];
}

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !self.isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!self.settingsMenu) {
        self.settingsMenu = [[NSMenu alloc] initWithTitle:@"Action Menu"];
        [self.settingsMenu setDelegate:self];
        [self.settingsMenu setAutoenablesItems:NO];
    } else {
        [self.settingsMenu removeAllItems];
    }
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Replace This Recipe..." action:@selector(replaceRecipe:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    self.isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    self.isMenuVisible = NO;
}

@end
