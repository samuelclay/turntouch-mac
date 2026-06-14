//
//  TTModeKasaSwitchOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaSwitchOptions.h"
#import "TTModeKasaSwitchDevice.h"

@interface TTModeKasaSwitchOptions ()

@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;

@end

@implementation TTModeKasaSwitchOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeKasa = ((TTModeKasa *)self.mode);
    [self.modeKasa setDelegate:self];

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

    for (TTModeKasaDevice *device in TTModeKasa.foundDevices) {
        TTModeKasaSwitchDevice *deviceRow = [[TTModeKasaSwitchDevice alloc] initWithDevice:device];
        deviceRow.delegate = self;
        [self.devicesStack addView:deviceRow inGravity:NSStackViewGravityTop];
        [deviceRow redraw];
    }

    [self.devicesStack setNeedsDisplay:YES];
}

#pragma mark - Kasa Delegate

- (void)changeState:(TTKasaState)kasaState withMode:(TTModeKasa *)modeKasa {
    if (kasaState == KASA_STATE_CONNECTED) {
        self.spinner.hidden = YES;
        self.refreshButton.hidden = NO;
    }

    [self selectDevices];
}

- (void)selectDevices {
    [self.modeKasa ensureDevicesSelected];

    if (TTModeKasa.foundDevices.count == 0) {
        if (TTModeKasa.kasaState == KASA_STATE_CONNECTING) {
            [self.noticeLabel setStringValue:@"Searching for Kasa devices..."];
            [self.noticeLabel setTextColor:[NSColor darkGrayColor]];
            self.spinner.hidden = NO;
            self.refreshButton.hidden = YES;
        } else {
            [self.noticeLabel setStringValue:@"No Kasa devices found"];
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

    [self.modeKasa refreshDevices];
}

- (IBAction)purgeDevices:(id)sender {
    [self.modeKasa resetKnownDevices];
    [self selectDevices];
    [self refreshDevices:sender];
}

- (IBAction)enterCredentials:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"TP-Link Kasa Credentials"];
    [alert setInformativeText:@"Enter your TP-Link/Kasa account credentials for newer devices that use KLAP authentication."];
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];

    NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 58)];

    NSTextField *usernameField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 32, 300, 22)];
    usernameField.placeholderString = @"Email / Username";

    NSDictionary *creds = [TTModeKasa loadCredentials];
    if (creds) {
        usernameField.stringValue = creds[@"username"];
    }

    NSSecureTextField *passwordField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 4, 300, 22)];
    passwordField.placeholderString = @"Password";

    [accessoryView addSubview:usernameField];
    [accessoryView addSubview:passwordField];
    [alert setAccessoryView:accessoryView];

    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSString *username = usernameField.stringValue;
        NSString *password = passwordField.stringValue;
        if (username.length > 0 && password.length > 0) {
            [TTModeKasa saveCredentialsUsername:username password:password];
            [self.modeKasa refreshDevices];
        }
    }
}

#pragma mark - Device Selection

- (void)toggleDevice:(TTModeKasaDevice *)device {
    NSMutableArray *selectedDevices = [[self.action optionValue:kKasaSelectedSerials] mutableCopy];

    NSString *identifier = device.deviceId ?: device.macAddress;
    if (!identifier) return;

    if ([selectedDevices containsObject:identifier]) {
        [selectedDevices removeObject:identifier];
    } else {
        [selectedDevices addObject:identifier];
    }

    [self.action changeActionOption:kKasaSelectedSerials to:selectedDevices];
}

- (BOOL)isSelected:(TTModeKasaDevice *)device {
    NSArray *selectedDevices = [self.action optionValue:kKasaSelectedSerials];
    NSString *identifier = device.deviceId ?: device.macAddress;
    return identifier && [selectedDevices containsObject:identifier];
}

#pragma mark - Settings Menu

- (IBAction)showKasaSwitchMenu:(id)sender {
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

    if ([TTModeKasa hasKLAPDevices]) {
        [self.settingsMenu addItem:[NSMenuItem separatorItem]];

        menuItem = [[NSMenuItem alloc] initWithTitle:@"Enter TP-Link Credentials..." action:@selector(enterCredentials:) keyEquivalent:@""];
        [menuItem setEnabled:YES];
        [menuItem setTarget:self];
        [self.settingsMenu addItem:menuItem];
    }
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
