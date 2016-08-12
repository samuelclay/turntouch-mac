//
//  TTDeviceTitleView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDeviceTitleView.h"

@implementation TTDeviceTitleView

@synthesize device;
@synthesize progress;

- (instancetype)initWithDevice:(TTDevice *)_device {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        device = _device;
        hoverActive = NO;

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        latestVersion = [[prefs objectForKey:@"TT:firmware:version"] integerValue];

        changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:[NSString stringWithFormat:@"Upgrade to v%ld", (long)latestVersion]];
        [changeButton setAction:@selector(beginUpgrade:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        
        settingsButton = [[TTSettingsButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
        [self buildSettingsMenu:YES];
        [settingsButton setTarget:self];
        [settingsButton setMenu:settingsMenu];
        [self addSubview:settingsButton];
        
        progress = [[NSProgressIndicator alloc] init];
        [progress setStyle:NSProgressIndicatorBarStyle];
        [progress setDisplayedWhenStopped:NO];
        [progress setUsesThreadedAnimation:YES];
        [progress setMinValue:0];
        [progress setMaxValue:100];
        [self addSubview:progress];
        
        [self setupTitleAttributes];
        [self createTrackingArea];
    }
    
    return self;
}

- (void)createTrackingArea {
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self drawBackground];
//    NSLog(@"Drawing %@: %@.", NSStringFromRect(self.frame), device);
    
    NSImage *remoteIcon;
    NSPoint imagePoint;
    remoteIcon = [NSImage imageNamed:@"remote_graphic"];
    [remoteIcon setSize:NSMakeSize(28, 28)];
    CGFloat offset = (NSHeight(self.frame)/2) - (remoteIcon.size.height/2);
    imagePoint = NSMakePoint(8, offset);

    if (hoverActive || isMenuVisible) {
        settingsButton.hidden = NO;
        CGFloat offsetY = (NSHeight(self.frame)/2) - (settingsButton.image.size.height/2);
        settingsButton.frame = NSMakeRect(0, offsetY, settingsButton.image.size.width*2.55, settingsButton.image.size.height);
    } else {
        settingsButton.hidden = YES;
        [remoteIcon drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                          remoteIcon.size.width, remoteIcon.size.height)];
    }
    
    NSSize titleSize = [device.nickname sizeWithAttributes:titleAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + remoteIcon.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [device.nickname drawAtPoint:titlePoint withAttributes:titleAttributes];
    
    NSString *buttonText = [self updateButtonTitle];
    NSSize buttonSize = [buttonText sizeWithAttributes:@{NSFontNameAttribute: [NSFont fontWithName:@"Effra" size:13]}];
    NSRect buttonFrame = NSMakeRect(NSWidth(self.frame) - buttonSize.width*1.25 - 12,
                                    8,
                                    buttonSize.width*1.25, NSHeight(self.frame) - 8*2);
    changeButton.frame = buttonFrame;
    
    progress.frame = buttonFrame;

    [self setChangeButtonTitle:buttonText];
}

- (void)drawBackground {
//    [NSColorFromRGB(0xAFAFAF) set];
//    NSRectFill(self.bounds);
}

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:title attributes:nil];
    [changeButton setAttributedTitle:attributedString];
}

- (void)setupTitleAttributes {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);

    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow
                        };
    textSize = [device.nickname sizeWithAttributes:titleAttributes];
}

- (void)beginUpgrade:(id)sender {
    NSLog(@"Begin upgrade: %@", device);
    
    device.inDFU = YES;
    [changeButton setHidden:YES];
    [progress setIndeterminate:YES];
    [progress startAnimation:nil];
    [appDelegate.panelController.backgroundView.deviceTitlesView performDFU:device];
}

- (NSString *)updateButtonTitle {
    NSString *buttonText;
    if (device.isFirmwareOld) {
        buttonText = [NSString stringWithFormat:@"Upgrade to v%ld", (long)latestVersion];
        [changeButton setUseAltStyle:NO];
        [changeButton setEnabled:YES];
    } else {
        buttonText = [NSString stringWithFormat:@"All set with v%d", device.firmwareVersion];
        [changeButton setUseAltStyle:YES];
        [changeButton setEnabled:NO];
    }
    return buttonText;
}

- (void)disableUpgrade {
    [changeButton setEnabled:NO];
    if (!self.device.isFirmwareOld) return;
    [changeButton setTitle:@"Waiting..."];
}

- (void)enableUpgrade {
    if (device.isFirmwareOld) {
        [changeButton setEnabled:YES];
    }
    NSString *buttonText = [self updateButtonTitle];
    [changeButton setTitle:buttonText];
}



#pragma mark - Mouse

- (void)mouseEntered:(NSEvent *)theEvent {
    hoverActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    hoverActive = NO;
    [self setNeedsDisplay:YES];
}


#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!settingsMenu) {
        settingsMenu = [[NSMenu alloc] initWithTitle:@"Remote Menu"];
        [settingsMenu setDelegate:self];
        [settingsMenu setAutoenablesItems:NO];
    } else {
        [settingsMenu removeAllItems];
    }
    
    TTDeviceList *foundDevices = appDelegate.bluetoothMonitor.foundDevices;
    for (TTDevice *device in foundDevices) {
        if (device.state != TTDeviceStateConnected && device.state != TTDeviceStateConnecting) continue;
        if (device.uuid || device.nickname) {
            menuItem = [[NSMenuItem alloc] initWithTitle:(device.nickname ? device.nickname : device.uuid)
                                                  action:@selector(openDevicesDialog:) keyEquivalent:@""];
            [menuItem setTarget:self];
            [settingsMenu addItem:menuItem];
        }
        
        NSString *batteryLevel = [NSString stringWithFormat:@"Battery level: %d%%",
                                  (int)device.batteryPct.intValue];
        menuItem = [[NSMenuItem alloc] initWithTitle:batteryLevel action:@selector(openDevicesDialog:) keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [menuItem setTarget:self];
        if (device.isPaired && device.batteryPct.intValue <= 0) {
            [menuItem setTitle:@"Connecting to remote..."];
            [menuItem setEnabled:NO];
        } else if (!device.isPaired) {
            [menuItem setTitle:@"Pairing with remote..."];
            [menuItem setEnabled:NO];
        }
        [settingsMenu addItem:menuItem];
        
        
        [settingsMenu addItem:[NSMenuItem separatorItem]];
    }
    if (!foundDevices.count) {
        menuItem = [[NSMenuItem alloc] initWithTitle:@"No remotes connected" action:nil keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [settingsMenu addItem:menuItem];
        
        [settingsMenu addItem:[NSMenuItem separatorItem]];
    }
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Add a new remote..."
                                          action:@selector(openPairingDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    [settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                          action:@selector(openSettingsDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"How it works"
                                          action:@selector(openFTUXDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Contact support"
                                          action:@selector(openSupportDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"About Turn Touch"
                                          action:@selector(openAboutDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    [settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Turn Touch Remote"
                                          action:@selector(quit:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSImage *image = [NSImage imageNamed:@"settings"];
    [image setSize:NSMakeSize(18, 18)];
    [menuItem setImage:image];
    [settingsMenu insertItem:menuItem atIndex:0];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
}

- (void)openSettingsDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_DEVICES];
}

- (void)openPairingDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_PAIRING];
}

- (void)openFTUXDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_FTUX];
}

- (void)openAboutDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_ABOUT];
}

- (void)openSupportDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_SUPPORT];
}

- (void)openDevicesDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_DEVICES];
}

- (void)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}


@end
