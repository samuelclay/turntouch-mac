//
//  TTModeGoveeSwitchOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGoveeSwitchOptions.h"
#import "TTModeGoveeSwitchDevice.h"

@interface TTModeGoveeSwitchOptions ()

@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;

@end

@implementation TTModeGoveeSwitchOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    self.modeGovee = ((TTModeGovee *)self.mode);
    [self.modeGovee setDelegate:self];

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

    for (TTModeGoveeDevice *device in TTModeGovee.foundDevices) {
        TTModeGoveeSwitchDevice *deviceRow = [[TTModeGoveeSwitchDevice alloc] initWithDevice:device];
        deviceRow.delegate = self;
        [self.devicesStack addView:deviceRow inGravity:NSStackViewGravityTop];
        [deviceRow redraw];
    }

    [self.devicesStack setNeedsDisplay:YES];
}

#pragma mark - Govee Delegate

- (void)changeState:(TTGoveeState)goveeState withMode:(TTModeGovee *)modeGovee {
    if (goveeState == GOVEE_STATE_CONNECTED) {
        self.spinner.hidden = YES;
        self.refreshButton.hidden = NO;
    }

    [self selectDevices];
}

- (void)fetchStatusUpdate:(NSString *)status {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fetchStatusUpdate:status];
        });
        return;
    }
    [self.noticeLabel setStringValue:status];
}

- (void)selectDevices {
    [self.modeGovee ensureDevicesSelected];

    if (TTModeGovee.foundDevices.count == 0) {
        if (TTModeGovee.goveeState == GOVEE_STATE_CONNECTING) {
            [self.noticeLabel setStringValue:@"Fetching Govee devices..."];
            [self.noticeLabel setTextColor:[NSColor darkGrayColor]];
            self.spinner.hidden = NO;
            self.refreshButton.hidden = YES;
        } else {
            [self.noticeLabel setStringValue:@"No Govee devices found"];
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

    [self.modeGovee refreshDevices];
}

- (IBAction)purgeDevices:(id)sender {
    [self.modeGovee resetKnownDevices];
    [self selectDevices];
    [self refreshDevices:sender];
}

- (IBAction)changeApiKey:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Govee API Key"];
    [alert setInformativeText:@"Enter your Govee API key (from Govee Home App > Settings > My Profile > Apply for API Key)"];
    [alert addButtonWithTitle:@"Save"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *apiKeyField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 22)];
    apiKeyField.placeholderString = @"API Key";

    NSString *existingKey = [TTModeGovee loadApiKey];
    if (existingKey) {
        apiKeyField.stringValue = existingKey;
    }

    [alert setAccessoryView:apiKeyField];

    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        NSString *apiKey = [apiKeyField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (apiKey.length > 0) {
            [TTModeGovee saveApiKey:apiKey];
            [[TTModeGovee apiClient] setApiKey:apiKey];
            [self.modeGovee refreshDevices];
        }
    }
}

#pragma mark - Device Selection

- (void)toggleDevice:(TTModeGoveeDevice *)device {
    NSMutableArray *selectedDevices = [[self.action optionValue:kGoveeSelectedDevices] mutableCopy];

    NSString *identifier = device.deviceId;
    if (!identifier) return;

    if ([selectedDevices containsObject:identifier]) {
        [selectedDevices removeObject:identifier];
    } else {
        [selectedDevices addObject:identifier];
    }

    [self.action changeActionOption:kGoveeSelectedDevices to:selectedDevices];
}

- (BOOL)isSelected:(TTModeGoveeDevice *)device {
    NSArray *selectedDevices = [self.action optionValue:kGoveeSelectedDevices];
    NSString *identifier = device.deviceId;
    return identifier && [selectedDevices containsObject:identifier];
}

#pragma mark - Settings Menu

- (IBAction)showGoveeSwitchMenu:(id)sender {
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

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Refresh Devices..." action:@selector(refreshDevices:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];

    [self.settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Remove All and Refresh..." action:@selector(purgeDevices:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];

    [self.settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Change API Key..." action:@selector(changeApiKey:) keyEquivalent:@""];
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
