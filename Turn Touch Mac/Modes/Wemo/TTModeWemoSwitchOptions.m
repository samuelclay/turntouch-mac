//
//  TTModeWemoSwitchOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemoSwitchOptions.h"
#import "TTModeWemoSwitchDevice.h"
#import "TTModeWemo.h"

@interface TTModeWemoSwitchOptions ()

@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;

@end

@implementation TTModeWemoSwitchOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeWemo = ((TTModeWemo *)self.mode);
    [self.modeWemo setDelegate:self];

    self.spinner.hidden = YES;
    self.refreshButton.hidden = NO;
    [self.refreshButton setImage:[NSImage imageNamed:@"settings"]];
    
    [self buildSettingsMenu:YES];
    [self selectDevices];
}

- (void)redrawTable {
    for (NSView *deviceRow in self.devicesStack.views) {
        [self.devicesStack removeView:deviceRow];
    }
    
    for (TTModeWemoDevice *device in TTModeWemo.foundDevices) {
        TTModeWemoSwitchDevice *deviceRow = [[TTModeWemoSwitchDevice alloc] initWithDevice:device];
        deviceRow.delegate = self;
        [self.devicesStack addView:deviceRow inGravity:NSStackViewGravityTop];
        [deviceRow redraw];
    }
    
    [self.devicesStack setNeedsDisplay:YES];
}

#pragma mark - Wemo Delegate

- (void)changeState:(TTWemoState)wemoState withMode:(TTModeWemo *)modeWemo {
    NSLog(@" Changing Wemo state: %lu", wemoState);
    
    if (wemoState == WEMO_STATE_CONNECTED) {
        self.spinner.hidden = YES;
        self.refreshButton.hidden = NO;
    }
    
    [self selectDevices];
}

- (void)selectDevices {
    [self.modeWemo ensureDevicesSelected];
    
    if (TTModeWemo.foundDevices.count == 0) {
        if (TTModeWemo.wemoState == WEMO_STATE_CONNECTING) {
            [self.noticeLabel setStringValue:@"Searching for Wemo devices..."];
            [self.noticeLabel setTextColor:[NSColor darkGrayColor]];
            self.spinner.hidden = NO;
            self.refreshButton.hidden = YES;
        } else {
            [self.noticeLabel setStringValue:@"No Wemo devices found"];
            [self.noticeLabel setTextColor:[NSColor lightGrayColor]];
            self.spinner.hidden = YES;
            self.refreshButton.hidden = NO;
        }
        self.noticeLabel.hidden = NO;
    } else {
        self.noticeLabel.hidden = YES;
    }
    
    [self redrawTable];
}

- (IBAction)refreshDevices:(id)sender {
    self.spinner.hidden = NO;
    [self.spinner startAnimation:nil];
    self.refreshButton.hidden = YES;
    
    [self.modeWemo refreshDevices];
}

- (IBAction)purgeDevices:(id)sender {
    [self.modeWemo resetKnownDevices];
    [self selectDevices];
    [self refreshDevices:sender];
}

#pragma mark - Table View delegate and data source

- (void)toggleDevice:(TTModeWemoDevice *)device {
    NSMutableArray *selectedDevices = [[self.action optionValue:kWemoSelectedSerials] mutableCopy];
    
    if ([selectedDevices containsObject:device.serialNumber]) {
        [selectedDevices removeObject:device.serialNumber];
    } else {
        [selectedDevices addObject:device.serialNumber];
    }
    
    [self.action changeActionOption:kWemoSelectedSerials to:selectedDevices];
}

- (BOOL)isSelected:(TTModeWemoDevice *)device {
    NSArray *selectedDevices = [self.action optionValue:kWemoSelectedSerials];
    return [selectedDevices containsObject:device.serialNumber];
}


#pragma mark - Settings menu

- (IBAction)showWemoSwitchMenu:(id)sender {
    [NSMenu popUpContextMenu:self.settingsMenu
                   withEvent:[NSApp currentEvent]
                     forView:sender];
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
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Search for New Devices..." action:@selector(refreshDevices:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    [self.settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Remove All and Search..." action:@selector(purgeDevices:) keyEquivalent:@""];
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
